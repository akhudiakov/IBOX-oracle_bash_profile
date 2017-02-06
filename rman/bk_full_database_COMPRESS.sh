#!/bin/sh
echo `date`
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1
export ORACLE_SID=PEREC
export PATH=$ORACLE_HOME/bin:$PATH
export NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251
LOGFILE=/home/oracle/LOGS_BACKUP/${ORACLE_SID}_full`date +'%Y_%m_%d_%H:%M'`.log
LOCK_FILE=/home/oracle/LOGS_BACKUP/rman_backup${ORACLE_SID}.lock
MAIL='a.bobrov@ibox.ua'
touch $LOGFILE
if [ -f $LOCK_FILE ]; then
  echo "Process locked.............error!!!!!!!!!!!"
  exit 1
else
  touch $LOCK_FILE && echo "Created lock file.......ok!"
fi
echo `date` "bk_full pid-"$$ > $LOCK_FILE
rman target / <<EOF
SPOOL LOG TO $LOGFILE;
RUN {
backup as compressed backupset incremental level 0 database format '/u04/backup/full_%U.bcp' tag 'HOT_DB_0' plus archivelog format '/u04/backup/arc_%U.bcp' delete all input;
delete noprompt obsolete;
}
SPOOL LOG off;
EOF

rm -f $LOCK_FILE
echo "Lock file drop..............ok!"
mail -s "Backup FULL_DB `date +%H:%M_%d.%m.%Y`" $MAIL < $LOGFILE

echo `date`
