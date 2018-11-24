#!/bin/bash
#show processlist有问题 
# |grep -v "Sleep|awk{print $1} ..."
for i in `mysql -hlocalhost -uroot -proot -BNe  "show processlist;"`
do 
	echo ${i}
done
