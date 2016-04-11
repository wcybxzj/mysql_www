#!/bin/bash

if [[ $(whoami) != "root" ]]; then
	echo "must be root"
	exit
fi


#mount 
umount /net &>> log_file
mount|grep '/net'
if [[ $? -eq 1 ]]; then
mount -t iso9660 -o loop /root/centos6u6.iso /net
fi

#yum
rm -rf /etc/yum.repos.d/*
echo '[Centos6u6]' > /etc/yum.repos.d/centos6u6.repo
echo 'name=Centos6u6'>>/etc/yum.repos.d/centos6u6.repo
echo 'baseurl=file:///net'>>/etc/yum.repos.d/centos6u6.repo
echo 'gpgcheck=0'>>/etc/yum.repos.d/centos6u6.repo
echo 'enabled=1'>>/etc/yum.repos.d/centos6u6.repo
yum clean all
yum makecache
yum install -y gcc gcc-c++ ncurses-devel readline-devel cmake
