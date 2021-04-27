#!/bin/bash

#---------------------------------------------------------------------
# Install Package List
#---------------------------------------------------------------------

# 1. Default Package
# 2. etc

#---------------------------------------------------------------------
# 1. Default Package
#---------------------------------------------------------------------
 
    yum -y update --exclude=kernel*
    yum -y install lsb glibc bash openssh-*  dstat sysstat git ntp wget telnet nmap unzip gcc-c++ jq
