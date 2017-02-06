#!/bin/sh


## Set env variables
ARGS=1
if [ $# -ne "$ARGS" ]
        then
        echo "Usage details: `basename $0` <ORACLE_SID>.
                Please, check /etc/oratab for correct value of ORACLE_SID"
        exit 1
fi


export ORACLE_SID=$1

if [ ! -f ~/local/.${ORACLE_SID} ]; then
 mailx -s "Can not setup ${ORACLE_SID} environments for $0" andrey.hudyakov@gmail.com < /dev/null
    exit 1
fi
. ~/local/.${ORACLE_SID}


LOGFILE=${RMAN_LOG}/${DB_NAME}_arch_`date +'%d-%m-%Y_%H%M'`.log
LOCK_FILE=${RMAN_LOG}/rman_backup${ORACLE_SID}.lock

###############
touch $LOGFILE;
exec >>$LOGFILE 2>&1

if [ -f $LOCK_FILE ]; then
  echo "Process locked.............error!!!!!!!!!!!"
    exit 1
else
  touch $LOCK_FILE && echo "Created lock file.......ok!"
fi

#mount backup destination
if ( ! /usr/bin/sudo /bin/mount -o hard\,nointr\,nolock\,rsize\=32768\,wsize\=32768\,tcp\,actimeo\=0\,vers\=3\,timeo\=600 192.168.99.10\:/opt/filestore/orabackup /mnt/orabackup) ; then
     echo "Mount network share is FAILED" >> $LOGFILE
     mailx -S from="${_mail_from}" -s "Mount network share is FAILED. `date '+%d-%m-%Y %H:%M'`" $EMAIL_DBA < $LOGFILE
     rm -f $LOCK_FILE
     exit 1
fi

echo `date` "bk_arch pid-"$$ > $LOCK_FILE
#rman target /@PEREC_R_STB_SYS catalog /@rman_rep_r  <<EOF
rman target / <<EOF
RUN{
backup archivelog all not backed up format '${_rman_arc}/arch_%T_%U.bcp' tag 'ARCH';
}
EOF

#unmount
while (sudo /bin/umount /mnt/orabackup) > /dev/null 2>&1; do
     :
done

rm -f $LOCK_FILE
echo "Lock file drop..............ok!" 2>& 1 #| tee -a $LOGFILE

error_cnt=(`grep ERROR $LOGFILE| wc -l`)
if [ ${error_cnt} -ne 0 ]; then
	mailx -S from="${_mail_from}" -s "Backup of archivelog FAILED. `date '+%d-%m-%Y %H:%M'`" $EMAIL_DBA < $LOGFILE
	exit 1
fi

exit 0
