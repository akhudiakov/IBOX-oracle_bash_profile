#!/bin/bash
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/db_1
export ORACLE_SID=PEREC
export PATH=$ORACLE_HOME/bin:$PATH
export NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251

$ORACLE_HOME/bin/sqlplus -s "sys/************@PEREC_R as sysdba" <<EOF > /dev/null 2>&1
alter system archive log current;
exit;
EOF
