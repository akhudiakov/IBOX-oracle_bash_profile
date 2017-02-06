#!/bin/bash

ARGS=1
if [ $# -ne "$ARGS" ]
        then
        echo "Usage details: `basename $0` ORACLE_SID.
                Please, check /etc/oratab for correct value of ORACLE_SID"
        exit 1
fi

ORACLE_SID=$1
if [ ! -f ~/local/.${ORACLE_SID} ]; then
print "Can not setup ${ORACLE_SID} environments for $0"
    exit 1
fi
. ~/local/.${ORACLE_SID}


$ORACLE_HOME/bin/sqlplus -S "/as sysdba" <<EOF
shu immediate
EOF

$ORACLE_HOME/bin/lsnrctl stop


# start Transparent gateway listener
#export ORACLE_HOME=/u01/app/oracle/product/gateway
#export TNS_ADMIN=/u01/app/oracle/product/gateway/network/admin
#$ORACLE_HOME/bin/lsnrctl stop LISTENER_GW
