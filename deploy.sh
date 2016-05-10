#!/bin/bash
SELINUX=true
UPDATE=true
USERNAME=apauser
PATHTOTAR=/root/app.tar
GROUPNAME=www-app
APPSDIR=/home/${USERNAME}/apps
SERVERNAME=127.0.0.1
ERRORLOG=${APPSDIR}/error.log
PORT=80
PATHTOSQLDUMP=${APPSDIR}/sisdb.sql
echo "Bringing up network..."
echo "
DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=dhcp
ONBOOT=yes
" > /etc/sysconfig/network-scripts/ifcfg-eth0
echo "" > /etc/sysconfig/iptables
service network restart
service iptables restart
if $UPDATE
then
echo "update system..."
yum update -y
fi
echo "Installing packages..."
yum install -y php php-mysql mysql-server httpd
SERVLINE=`grep -no "ServerName" /etc/httpd/conf/httpd.conf | grep -o [0-9]*`
echo "set autostart services..."
chkconfig httpd on
chkconfig mysqld on
echo "starting services..."
service httpd start
service mysqld start
echo "Setting Servername=${SERVERNAME} and Port=8080"
touch $ERRORLOG
echo "
<VirtualHost *:${PORT}>
        DocumentRoot $APPSDIR
        ServerName $SERVERNAME
        ErrorLog $ERRORLOG
</VirtualHost>
" >> /etc/httpd/conf/httpd.conf
sed -i "${SERVLINE}i\ ServerName ${SERVERNAME}:${PORT}" /etc/httpd/conf/httpd.conf
echo "Done config httpd!"
echo "Create user $USERNAME and group ${GROUPNAME}..."
groupadd $GROUPNAME
useradd $USERNAME -g $GROUPNAME
mkdir -p $APPSDIR
if  $SELINUX
then
        echo "Installing SELinux manage tools"
        yum install -y policycoreutils-python
        echo "Apply change to $APPSDIR: " 
        semanage fcontext --add --type httpd_sys_content_t "${APPSDIR}(/.*)?"
        restorecon $APPSDIR
        echo "Done!"
else
        echo "Turning off Selinux..."
        setenforce 0
fi
chown -R :${GROUPNAME} $APPSDIR
chmod -R 755 /home/${USERNAME}
echo "Untar app to $APPSDIR"
tar xC $APPSDIR -f $PATHTOTAR
echo "Restarting httpd"
service httpd restart
echo "Unpacking done!"
echo "Creating MySQL user, db.."
echo "
create database sisdb;
grant all privileges on sisdb.* to 'sisuser'@'localhost' identified by 'sispass';
flush privileges;
" > /tmp/configmysql.sql
mysql -u root < /tmp/configmysql.sql
rm -f /tmp/configmysql.sql
echo "restore dump from ${PATHTOSQLDUMP}"
mysql -u sisuser -psispass sisdb < $PATHTOSQLDUMP
echo "All done! Please, check your app on ${SERVERNAME}:${PORT}"
