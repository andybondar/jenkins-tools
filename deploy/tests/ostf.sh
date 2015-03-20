#!/bin/bash -x

# $proviant_ip, $proviant_user, $proviant_port $DC_ID to obtain from job parameter
# $fuel_master_pass, $fuel_master_user, $FUEL_IP  - obtain them from proviant details

echo "Proviant IP: $proviant_ip"
echo "Proviant user: $proviant_user"
echo "Proviant port: $proviant_port"

# Get FUEL_IP from proviant
FUEL_IP=`ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null ${proviant_user}@${proviant_ip} -p ${proviant_port} proviant-dc-details --dc $DC_ID | grep 'Master: hostname:' | awk '{print $7}' | awk -F"://" '{print $2}'`
fuel_master_user=`ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null ${proviant_user}@${proviant_ip} -p ${proviant_port} proviant-dc-details --dc $DC_ID | sed -e '1,/fuel-master-ssh-credentials/d' | head -1 | awk {'print $1'}`
fuel_master_pass=`ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null ${proviant_user}@${proviant_ip} -p ${proviant_port} proviant-dc-details --dc $DC_ID | sed -e '1,/fuel-master-ssh-credentials/d' | head -1 | awk {'print $2'}`



echo "Fuel IP: $FUEL_IP"
echo "Fuel logun: $fuel_master_user"
echo "Fuel pass: $fuel_master_pass"

#sshpass -p$fuel_master_pass \
#ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null -oRSAAuthentication=no -oPubkeyAuthentication=no \
#$fuel_master_user@$FUEL_IP 'rm -rf /var/log/job-reports; mkdir -p /var/log/job-reports; fuel health --env 1 --check sanity,smoke |tee /var/log/job-reports/ostf.log'