#!/bin/sh

if [ ! -f ~/local/.${ORACLE_SID} ]; then
 mailx -s "Can not setup ${ORACLE_SID} environments for $0" andrey.hudyakov@gmail.com < /dev/null
    exit 1
fi
. ~/local/.${ORACLE_SID}

export db_name=${DB_NAME}


mount_nfs()
{
case $1 in
    perec)
      local BACKUP_HOST=
    ;;
	DUREMAR)
      local BACKUP_HOST=
    ;;
    *)
      echo "There is no mountpoint defined for ${1} database."
	  exit 1
	  ;;
  esac


if ( ! /usr/bin/sudo /bin/mount -o hard\,nointr\,nolock\,rsize\=32768\,wsize\=32768\,tcp\,actimeo\=0\,vers\=3\,timeo\=600 ${BACKUP_HOST}\:/opt/filestore/orabackup /mnt/orabackup ) ; then
     (printf "%s\n" "Mount network share from ${BACKUP_HOST} for ${DB_NAME} database backup is FAILED";) | mailx -S from="${_mail_from}" -s "Mount network share is FAILED." $EMAIL_DBA
     exit 1
fi
}