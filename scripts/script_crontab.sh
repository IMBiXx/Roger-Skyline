#!/bin/sh

CRON_FILE=/etc/crontab
CHECK_FILE=/root/.crontab-checker

if [ ! -f $CHECK_FILE ] || [ "`md5sum < $CRON_FILE`" != "`cat $CHECK_FILE`" ]
then
	echo "The crontab file has been modified !" | mail -s "root: crontab modified" root
	md5sum < $CRON_FILE > $CHECK_FILE;
	chmod 700 $CHECK_FILE;
fi
