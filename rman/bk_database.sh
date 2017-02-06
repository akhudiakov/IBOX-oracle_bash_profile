#!/bin/sh

## Set env variables
ARGS=2
if [ $# -ne "$ARGS" ]
        then
        echo "Usage details: `basename $0` <ORACLE_SID> <backup level>.
                Please, check /etc/oratab for correct value of ORACLE_SID"
        exit 1
fi


export ORACLE_SID=$1

if [ ! -f ~/local/.${ORACLE_SID} ]; then
 mailx -s "Can not setup ${ORACLE_SID} environments for $0" andrey.hudyakov@gmail.com < /dev/null
    exit 1
fi
. ~/local/.${ORACLE_SID}

#set local env variables
BC_LEVEL=$2
LOGFILE=${RMAN_LOG}/${DB_NAME}_INC_${BC_LEVEL}_`date +'%d-%m-%Y_%H%M'`.log
LOCK_FILE=${RMAN_LOG}/rman_backup${ORACLE_SID}.lock

##############
touch $LOGFILE
exec >>$LOGFILE 2>&1

if [ -f $LOCK_FILE ]; then
  echo "Process locked.............ERROR!!!!!!!!!!!"
  exit 1
else
  touch $LOCK_FILE && echo "Created lock file.......ok!"
fi

#mount backup destination
if ( ! /usr/bin/sudo /bin/mount -o hard\,nointr\,nolock\,rsize\=32768\,wsize\=32768\,tcp\,actimeo\=0\,vers\=3\,timeo\=600 192.168.99.10\:/opt/filestore/orabackup /mnt/orabackup ) ; then
     echo "Mount network share is FAILED" > $LOGFILE
     mailx -S from="${_mail_from}" -s "Mount network share is FAILED." $EMAIL_DBA < $LOGFILE
     exit 1
fi

echo `date` "bk_inkr pid-"$$ > $LOCK_FILE
#rman target /@PEREC_R_STB_SYS catalog /@rman_rep_r  <<EOF
rman target / <<EOF
SPOOL LOG TO $LOGFILE;
#RESYNC CATALOG FROM DB_UNIQUE_NAME PEREC_R;
#RESYNC CATALOG FROM DB_UNIQUE_NAME PEREC_R_STB;
RUN {
backup as compressed backupset incremental level ${BC_LEVEL} database format '${_rman_dbf}/incr${BC_LEVEL}_%U.bcp' tag 'INCR_${BC_LEVEL}' plus archivelog format '${_rman_arc}/arch_%T_%U.bcp' tag 'INCR_${BC_LEVEL}' delete all input;
backup current controlfile format '${_rman_ctr_spf}/ctrl_%U.bcp' tag 'INCR_${BC_LEVEL}';
backup spfile format '${_rman_ctr_spf}/spfl_%U.bcp' tag 'INCR_${BC_LEVEL}';
delete noprompt obsolete;
}
SPOOL LOG off;

EOF

#unmount backup destination
while (sudo /bin/umount /mnt/orabackup) > /dev/null 2>&1; do
     :
done

rm -f $LOCK_FILE
echo "Lock file drop..............ok!" 2>& 1 #| tee -a $LOGFILE

error_cnt=(`grep ERROR $LOGFILE| wc -l`)
if [ ${error_cnt} -ne 0 ]; then
        mailx -S from="${_mail_from}" -s  "Backup ERROR! INCR_${BC_LEVEL} `date '+%d-%m-%Y %H:%M'`" $EMAIL_DBA < $LOGFILE
	exit 1
fi

exit 0
