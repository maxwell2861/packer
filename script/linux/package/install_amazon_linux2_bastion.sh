#!/bin/bash

#---------------------------------------------------------------------
# Install Package List
#---------------------------------------------------------------------

# 1. Default Package
# 2. Qcon
# 3. etc..


#---------------------------------------------------------------------
# 1. Default Package
#---------------------------------------------------------------------
 
yum -y update --exclude=kernel*
yum -y install lsb glibc bash openssh-* sysstat dstat git chrony wget telnet nmap unzip gcc-c++ jq python-pip python-wheel

#----------------------------------------------------------------------
# 2. Qcon
#----------------------------------------------------------------------

mkdir -p /maxwell/set/qcon

mv ./role/.aws_credentials /maxwell/set/qcon/
mv ./role/awsEC2-Query.sh /maxwell/set/qcon/
mv ./role/econ /maxwell/set/qcon/
mv ./role/qcon.sh /maxwell/set/qcon/

chmod 777 /maxwell/set/qcon/qcon.sh
ln -s /maxwell/set/qcon/qcon.sh /usr/bin/qcon
ls -al /maxwell/set/qcon/
chown -R root.root /maxwell/set/qcon

