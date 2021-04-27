#!/bin/bash
export PREFIX=${PREFIX}
export OS_USER=${OS_USER}
export AZURE_STORAGE_ACCOUNT=${STORAGE_ACCOUNT}
export AZURE_STORAGE_KEY=${STORAGE_KEY}

#-----------------------------------------------
# 0. Azure CLI Install
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
# 1. User Create ( SEUSER / DBAUSER / DEVUSER)
#-----------------------------------------------

users=($OS_USER)
for i in "${users[@]}"; do
    useradd -m $i
    mkdir -p /home/$i/.ssh
    chmod 700 /home/$i/.ssh   
    az storage blob download -f /home/$i/.ssh/id_rsa.pub -c auth -n $i-id_rsa.pub
    cat /home/$i/.ssh/id_rsa.pub > /home/$i/.ssh/authorized_keys
    rm -rf /home/$i/.ssh/id_rsa.pub
    echo -e "\n#  User $i Create #\n"
    chmod 600 /home/$i/.ssh/authorized_keys
    chown -R $i.$i /home/$i/.ssh
    echo "$i        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/$i
done

#----------------------------------------------------
# 2. Default Directory 
#----------------------------------------------------
echo -e "#--------------------------------------------"
echo -e "\n# $PREFIX Create Default Directory #\n"
echo -e "#--------------------------------------------"

mkdir -p /maxwell/set/{backup,script,auth,package}

#-----------------------------------------------
# 3. Service Disable
#-----------------------------------------------
echo '#---------------------------------------------'
echo '# Chkconfig Disabled Daemon'
echo '#---------------------------------------------'

for i in netfs nfslock rpcbind sendmail firewalld
do
    systemctl stop $i > /dev/null 2>&1
    systemctl disable $i > /dev/null 2>&1
done

#-----------------------------------------------
# 4. vim colorset 
#-----------------------------------------------

wget https://raw.githubusercontent.com/huyz/dircolors-solarized/master/dircolors.ansi-light -O /usr/etc/.dircolors
echo 'alias vi="vim"' >> /etc/bashrc
echo 'export PS1="\[\e[36;1m\]\u@\[\e[33;1m\]\h:\[\e[37;1m\][\$PWD]\\$ "' >> /etc/bashrc 
echo 'eval `dircolors /usr/etc/.dircolors`' >> /etc/bashrc
echo 'set paste' >> /etc/vimrc

#-----------------------------------------------
# 5. Disabled SELinux 
#-----------------------------------------------
echo '#---------------------------------------------'
echo '# Disabled SELinux'
echo '#---------------------------------------------'
sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
 
#----------------------------------------------
# 6. move openfile limit.conf
#----------------------------------------------

mv ~/package/common/limits.conf /etc/security/limits.conf