#!/bin/bash

export ORACLE_SID=PEREC

if [ ! -f ~/local/.${ORACLE_SID} ]; then
print "Can not setup ${ORACLE_SID} environments for $0"
    exit 1
fi
. ~/local/.${ORACLE_SID}


ARGS=0
#--Check argument numbers
if [ $# -eq "$ARGS" ] 
then
	echo "Wrong arguments number"
      exit 1
fi

$ORACLE_HOME/bin/sqlplus -S "/as sysdba" <<EOF
alter tablespace ${1} add datafile size 100M autoextend on next 1M maxsize 31G;
EOF
