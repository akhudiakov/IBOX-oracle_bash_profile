#!/bin/bash
export ORACLE_HOME=/u01/app/oracle/product/11.2.0.4/db_1
export ORACLE_SID=PEREC
$ORACLE_HOME/bin/sqlplus -S "/as sysdba"<< EOF
exec dbms_backup_restore.refreshagedfiles;
EOF
