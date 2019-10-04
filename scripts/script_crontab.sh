#!/bin/sh

cat /etc/crontab > /root/scripts/new
DIFF=$(diff new tmp)
if [ "$DIFF" != "" ]; then
	cp mail_type.txt mail.txt
	diff new tmp >> mail.txt
	sudo sendmail -vt < ./mail.txt
	rm -f /root/scripts/tmp
	cp /root/scripts/new /root/scripts/tmp
fi
