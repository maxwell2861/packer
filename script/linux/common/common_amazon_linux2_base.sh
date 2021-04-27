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

users=($OS_USER admin1 admin2)
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
# 2. Service Disable
#-----------------------------------------------

for i in netfs nfslock rpcbind sendmail firewalld
do
    systemctl stop $i > /dev/null 2>&1
    systemctl disable $i > /dev/null 2>&1
done

#----------------------------------------------
# 3. vim colorset 
#----------------------------------------------

wget https://raw.githubusercontent.com/huyz/dircolors-solarized/master/dircolors.ansi-light -O /usr/etc/.dircolors
echo 'alias vi="vim"' >> /etc/bashrc
echo 'export PS1="\[\e[36;1m\]\u@\[\e[32;1m\]\h:\[\e[37;1m\][\$PWD]\\$ "' >> /etc/bashrc 
echo 'eval `dircolors /usr/etc/.dircolors`' >> /etc/bashrc

#----------------------------------------------
# 4. TCP  BottleNeck Bandwidth and RTT
#----------------------------------------------

modprobe tcp_bbr
modprobe sch_fq
sysctl -w net.ipv4.tcp_congestion_control = bbr

cat << EOF >> /etc/sysconfig/modules/tcpcong.modules  
#!/bin/bash

#--------------------------------------------------------------------------------
# TCP Bottleneck Bandwidth and RTT
#               https://aws.amazon.com/ko/amazon-linux-ami/2017.09-release-notes/
#--------------------------------------------------------------------------------

exec /sbin/modprobe tcp_bbr > /dev/null 2> & 1
exec /sbin/modprobe sch_fq > /dev/null 2> & 1

EOF

chmod 755 /etc/sysconfig/modules/tcpcong.modules
echo "net.ipv4.tcp_congestion_control = bbr">> /etc/sysctl.d/00-tcpcong.conf

 
#----------------------------------------------
# 5. move openfile limit.conf
#----------------------------------------------

mv ~/package/common/limits.conf /etc/security/limits.conf