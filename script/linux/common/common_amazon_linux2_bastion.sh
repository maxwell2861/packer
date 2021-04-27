#!/bin/bash
export PREFIX=${PREFIX}
export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
export AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
export OS_USER=${OS_USER}
export BUCKET_NAME=${S3BUCKET}

#-----------------------------------------------
# 1. User Create 
#-----------------------------------------------

users=($OS_USER admin1)
for i in "${users[@]}"; do
    useradd -m $i     
    rm -rf /root/$i
    mkdir -p /home/$i/.ssh
    chmod 700 /home/$i/.ssh
    chown -R $i.$i /home/$i/.ssh
    su -c 'ssh-keygen -t rsa -f ~/.ssh/id_rsa -P "" > /dev/null 2>&1' - $i 
    aws s3 cp /home/$i/.ssh/id_rsa.pub s3://$BUCKET_NAME/auth/$i-id_rsa.pub
    aws s3 cp /home/$i/.ssh/id_rsa s3://$BUCKET_NAME/auth/$i-id_rsa
    echo "$i        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/$i
    chage -d 0 $i
done


#-----------------------------------------------
# 1. User Create 
#-----------------------------------------------

users=($ADMIN admin2 admin3)
for i in "${users[@]}"; do
    useradd -m $i
    mkdir -p /home/$i/.ssh
    chmod 700 /home/$i/.ssh
    aws s3 cp s3://$BUCKET_NAME/auth/$i-id_rsa.pub /home/$i/.ssh/id_rsa.pub
    cat /home/$i/.ssh/id_rsa.pub > /home/$i/.ssh/authorized_keys
    rm -rf /home/$i/.ssh/id_rsa.pub
    chmod 600 /home/$i/.ssh/authorized_keys
    chown -R $i.$i /home/$i/.ssh
    echo "$i        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/$i
done


#-----------------------------------------------
# 2. SSH Setting
#-----------------------------------------------

sed -i 's/#Port 22/Port 5822/g'  /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g'  /etc/ssh/sshd_config
sed -i "s/PermitRootLogin forced-commands-only/PermitRootLogin without-password/g" /etc/ssh/sshd_config
sed -i 's/ssh_pwauth: false/ssh_pwauth: true/g'  /etc/cloud/cloud.cfg.d/00_defaults.cfg
echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config
sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers

#-----------------------------------------------
# 3. Service Disable
#-----------------------------------------------

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

 
#----------------------------------------------
# 5. move openfile limit.conf
#----------------------------------------------

mv ~/package/common/limits.conf /etc/security/limits.conf