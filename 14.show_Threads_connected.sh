#!/bin/bash
#show processlist有问题 
# |grep -v "Sleep|awk{print $1} ..."

while [ TRUE ]; do
	mysql -h127.0.0.1 -uroot -proot -BNe  "show status like 'Threads_connected';"
	sleep 2
	clear
done
echo "finished"
