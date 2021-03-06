#!/bin/bash -x

# $proviant_ip, $proviant_user, $proviant_port $DC_ID to obtain from job parameter
# $fuel_master_pass, $fuel_master_user, $FUEL_IP  - obtain them from proviant details

# Get FUEL_IP from proviant
FUEL_IP=`ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null ${proviant_user}@${proviant_ip} -p ${proviant_port} proviant-dc-details --dc $DC_ID | grep 'Master: hostname:' | awk '{print $7}' | awk -F"://" '{print $2}'`
fuel_master_user=`ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null ${proviant_user}@${proviant_ip} -p ${proviant_port} proviant-dc-details --dc $DC_ID | sed -e '1,/fuel-master-ssh-credentials/d' | head -1 | awk {'print $1'}`
fuel_master_pass=`ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null ${proviant_user}@${proviant_ip} -p ${proviant_port} proviant-dc-details --dc $DC_ID | sed -e '1,/fuel-master-ssh-credentials/d' | head -1 | awk {'print $2'} | awk -F"'" '{print $2}'`

# Wait untill OpenStack deployment is done
count=250
while [[ $count -ne 0 ]] ; do
    echo "=== Waiting when OpenStack env is operational.. left $count attempts"
    status=`sshpass -p $fuel_master_pass ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null -oRSAAuthentication=no -oPubkeyAuthentication=no $fuel_master_user@$FUEL_IP fuel env --env 1 | tail -1 | awk {'print $3'}`
    if [ "$status" = "operational" ]; then
	echo "=== OpenStack env is $status"
	break
    fi
    if [ "$status" = "error" ]; then
	echo "=== Error! Deployment failed."
	exit 1
    fi
    let count=count-1
    sleep 60
done


sshpass -p$fuel_master_pass \
ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null -oRSAAuthentication=no -oPubkeyAuthentication=no \
$fuel_master_user@$FUEL_IP "rm -rf /var/log/job-reports; mkdir -p /var/log/job-reports; fuel health --env 1 --check $ostf_checks |tee /var/log/job-reports/ostf.log"

sshpass -p$fuel_master_pass \
scp -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null -oRSAAuthentication=no -oPubkeyAuthentication=no \
$fuel_master_user@$FUEL_IP:/var/log/job-reports/ostf.log ostf.log


echo "==============" >> ostf.log

ostf_status=`cat ostf.log | grep failure | wc -l`
if [ "$ostf_status" -eq "0" ]; then
    echo "All tests passed." >> ostf.log
else
    echo "$ostf_status test(s) failed!" >> ostf.log
    echo "Refer to log for details."
#    exit 1
fi

# Correct symlinks

if [ "$(tail -n1 ostf.log)" = "All tests passed." ]; then
    if [ -z "$BUILD_NUMBER_ISO" ]; then
	echo "BUILD_NUMBER_ISO is unset, nothing to do with symlinks"
	exit 0
    fi
    ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null \
-oRSAAuthentication=no -p$STORAGE_PORT root@$STORAGE_IP "rm -f /store/fuel_ref/rc; ln -s /store/fuel_ref/build_${BUILD_NUMBER_ISO} /store/fuel_ref/rc"
else
    if [ -z "$BUILD_NUMBER_ISO" ]; then
	echo "BUILD_NUMBER_ISO is unset, nothing to do with symlinks"
	exit 1
    fi
    ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null \
-oRSAAuthentication=no -p$STORAGE_PORT root@$STORAGE_IP "rm -f /store/fuel_ref/staging; ln -s /store/fuel_ref/$PREVIOUS_BUILD /store/fuel_ref/staging"
    ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null \
-oRSAAuthentication=no -p$STORAGE_PORT root@$STORAGE_IP "rm -f /store/fuel_ref/test; ln -s /store/fuel_ref/$PREVIOUS_BUILD /store/fuel_ref/test"
    exit 1
fi
