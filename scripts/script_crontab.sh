#!/bin/sh

cat /etc/crontab > /root/scripts/new
DIFF=$(diff new tmp)
if [ "$DIFF" != "" ]; then
	echo "Subject: The crontab file has been modified !" | sudo sendmail -v valecart@student.42.fr
	rm -f /root/scripts/tmp
	cp /root/scripts/new /root/scripts/tmp
fi
