#!/bin/bash
export PREFIX=${PREFIX}
export se_id=${SEUSER}
export dba_id=${DBAUSER}
export dev_id=${DEVUSER}
export AZURE_STORAGE_ACCOUNT=${STORAGE_ACCOUNT}
export AZURE_STORAGE_KEY=${STORAGE_KEY}

#-----------------------------------------------
# 1. Azure CLI Install
#------------------------------------------------
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc

sudo sh -c 'echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'

yum -y install azure-cli

#-----------------------------------------------
# 2. User Create 
#-----------------------------------------------
users=($OS_USER admin1)
for i in "${users[@]}"; do
    useradd -m $i     
    rm -rf /root/$i
    mkdir -p /home/$i/.ssh
    chmod 700 /home/$i/.ssh
    chown -R $i.$i /home/$i/.ssh
    su -c 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" > /dev/null 2>&1' - $i 
    az storage blob upload -f /home/$i/.ssh/id_rsa.pub -c auth -n $i-id_rsa.pub
    echo "$i        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/$i
    chage -d 0 $i
done

#-----------------------------------------------
# 3. SSH Setting
#-----------------------------------------------

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g'  /etc/ssh/sshd_config
echo 'Port 22' >> /etc/ssh/sshd_config
#sed -i "s/PermitRootLogin forced-commands-only/PermitRootLogin without-password/g" /etc/ssh/sshd_config
#echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

#----------------------------------------------------
# 3. Default Directory 
#----------------------------------------------------

mkdir -p /maxwell/set/{backup,script,auth,package}

#-----------------------------------------------
# 4. Service Disable
#-----------------------------------------------

for i in netfs nfslock rpcbind sendmail firewalld
do
    systemctl stop $i > /dev/null 2>&1
    systemctl disable $i > /dev/null 2>&1
done

#-----------------------------------------------
# 5. vim colorset 
#-----------------------------------------------

wget https://raw.githubusercontent.com/huyz/dircolors-solarized/master/dircolors.ansi-light -O /usr/etc/.dircolors
echo 'alias vi="vim"' >> /etc/bashrc
echo 'export PS1="\[\e[36;1m\]\u@\[\e[33;1m\]\h:\[\e[37;1m\][\$PWD]\\$ "' >> /etc/bashrc 
echo 'eval `dircolors /usr/etc/.dircolors`' >> /etc/bashrc
echo 'set paste' >> /etc/vimrc

#-----------------------------------------------
# 6. Disabled SELinux 
#-----------------------------------------------

sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
 
#----------------------------------------------
# 7. move openfile limit.conf
#----------------------------------------------

mv ~/package/common/limits.conf /etc/security/limits.conf