#!/bin/bash
export PIP_DISABLE_PIP_VERSION_CHECK=1
echo -e "\n#------------------------------------------------------------------------"
echo -e "# OS INFO"
echo -e "#------------------------------------------------------------------------\n"

echo -e " OS IMAGE       :    $(cat /etc/system-release)"
echo -e " Kernel Version :    $(uname -a |awk {'print $3'}) \n"

echo -e "\n#------------------------------------------------------------------------"
echo -e "# Installed Common Package List"
echo -e "#------------------------------------------------------------------------"

packages=(jq tree dstat sysstat glibc-devel glibc-static telnet chef)
for i in "${packages[@]}"; do
    echo -e "\n$i:" $(yum list $i|awk {'print $2'}|grep -v plugin |grep -v Packages)
done
echo -e "\nawscli:" $(pip show awscli|grep Version |awk {'print $2'}) > /dev/null 2>&1
echo -e "$(az 2>/dev/null --version |head -n 1)"


echo -e "\n#------------------------------------------------------------------------"
echo -e "# Cronjob List [/etc/cron.d/]"
echo -e "#------------------------------------------------------------------------"

ls -al /etc/cron.d/|awk {'print $9'}

echo -e "\n\n#------------------------------------------------------------------------"

#----------------------------------------------------------------------
# Clean Up
#----------------------------------------------------------------------

rm -rf ./{cript,role}   > /dev/null 2>&1
rm -rf /tmp/*   > /dev/null 2>&1

echo -e "#-----------------------------------------------------------------------"
echo -e "\n# Clean up Temporary Files [tmp , User Directory]" 
echo -e "#-----------------------------------------------------------------------"

userdel -r packer > /dev/null 2>&1