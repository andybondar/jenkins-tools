#!/bin/bash -x

if [ -z "$BUILD_NUMBER_ISO" ]; then
    echo "BUILD_NUMBER_ISO is unset, nothing to do with symlinks"
    exit 0
fi

if [ "$(tail -n1 ostf.log)" = "All tests passed." ]; then 
    ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null \
-oRSAAuthentication=no -p$STORAGE_PORT root@$STORAGE_IP "rm -f /store/fuel_ref/rc; ln -s /store/fuel_ref/$BUILD_NUMBER_ISO /store/fuel_ref/rc"
else
    ssh -oConnectTimeout=5 -oStrictHostKeyChecking=no -oCheckHostIP=no -oUserKnownHostsFile=/dev/null \
-oRSAAuthentication=no -p$STORAGE_PORT root@$STORAGE_IP "rm -f /store/fuel_ref/test; ln -s /store/fuel_ref/$PREVIOUS_BUILD /store/fuel_ref/test"
fi
