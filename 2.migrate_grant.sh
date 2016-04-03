#!/bin/bash
#迁移grant脚本
for i in `/home/mysql/mysql/bin/mysql -hlocalhost -uroot -proot -BNe  "select concat(user,'@',host) from mysql.user"`
do 
	/home/mysql/mysql/bin/mysql -hlocalhost -uroot -proot -proot \
	-BNe "show grants for ${i}"|awk '{print $0";"}'; 
done
