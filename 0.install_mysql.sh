#!/bin/bash
#rm /etc/my.cnf
#先运行yum.sh
#su -mysql
#0.install_mysql.sh /home/mysql/mysql-5.1.72 5172 5.1.72

if [[ $(whoami) != "mysql" ]]; then
	echo "must be mysql user"
	exit
fi

log_file=log.mysql
err_file=err.mysql
bpath=$1
port=$2
mysql_version=$3
home_base="/home/mysql/"
if [[ $# -ne 3 ]]; then
	echo "./0.install_mysql.sh 安装路径(/home/mysql5.1.72) 端口(5172) 大版本号(5.1.72, 5.5.35, 5.6.21)"
	exit
fi

rm $log_file $err_file &>/tmp/mysql.log

rm -rf $bpath
mkdir -p $bpath 2>$err_file || exit

mysql_package_dir=$home_base"/mysql/"
mysql_version_dir="mysql-"$mysql_version
tar_gz_name="mysql-$mysql_version.tar.gz"
[[ ! -f $mysql_package_dir"/mysql-$mysql_version.tar.gz" ]] &&
echo $mysql_package_dir"/mysql-$mysql_version.tar.gz dont exists" >>$err_file && exit

if [[ ! -d $mysql_package_dir"/etc" ]];then
	cp -rf /mnt/hgfs/shangguan/mysql/vmsare_share/etc/ /home/mysql/mysql
fi

cd $mysql_package_dir
rm -rf $mysql_version_dir
tar -zxvf "$mysql_package_dir/mysql-$mysql_version.tar.gz" 1>$log_file 2>>$err_file
cd $mysql_version_dir

if [[ $mysql_version ==  "5.1.72" ]]; then
	./configure  --prefix=${bpath} --with-unix-socket-path=${bpath}/tmp/mysql.sock \
	--with-plugins=partition,csv,archive,federated,innobase,innodb_plugin,myisam,heap \
	--with-charset=utf8 \
	--without-docs \
	--without-man \
	--with-client-ldflags=-static 'CFLAGS=-g -O3' 'CXXFLAGS=-g -O3' \
	--with-extra-charsets=gbk,utf8,ascii,big5,latin1,binary \
	--enable-assembler \
	--enable-local-infile \
	--enable-profiling  \
	--enable-thread-safe-client
else
	echo '5.5 or 5.6'
fi

echo 'configure complete' > $log_file

cpu_num=`cat /proc/cpuinfo| grep "physical id"| sort| uniq| wc -l`
make -j $cpu_num
echo 'make complete' > $log_file
make install
echo 'make isnstall complete' > $log_file

cd $bpath
mkdir etc log tmp var
case $mysql_version
	5.1.72)
	mysql_big_version=5.1
	;;
	5.5.35)
	mysql_big_version=5.5
	;;
	5.6.21)
	mysql_big_version=5.6
	;;
esac

cp $mysql_package_dir/etc/${mysql_big_version}/my.cnf ${bpath}/etc/

#6.创建系统表
$bpath/bin/mysql_install_db --user=mysql
#7.获得mysql.server，并启动
cp $bpath/share/mysql/mysql.server $bpath/bin/
$bapth/mysql.server start
#8.设置root密码
$bpath/mysqladmin -uroot password root
#9.清理空账号
$bpath/bin/mysql -uroot -proot -e "delete from mysql.user where User=''"
#10.导入数据
$bpath/bin/mysql -uroot -proot -e "source /mnt/hgfs/shangguan/mysql/vmsare_share/sakila_employees/sakila_db/sakila_schema.sql;"
$bpath/bin/mysql -uroot -proot -e "source /mnt/hgfs/shangguan/mysql/vmsare_share/sakila_employees/sakila_db/sakila_data.sql;"
