#!/bin/bash
yum -y install epel* rrdtool rrdtool-perl perl-core perl mod_fcgid perl-CPAN
yum -y install httpd httpd-devel gcc make curl wget
yum -y install libxml2-devel libpng-devel glib pango pango-devel \
freetype freetype-devel fontconfig cairo cairo-devel \
libart_lgpl libart_lgpl-devel
yum -y install perl-Sys-Syslog podofo  mod_fcgid bind-utils
yum -y install perl perl-Net-Telnet perl-Net-DNS perl-LDAP perl-libwww-perl \
perl-RadiusPerl perl-IO-Socket-SSL perl-Socket6 perl-CGI-SpeedyCGI \
perl-FCGI perl-CGI-SpeedCGI perl-Time-HiRes perl-ExtUtils-MakeMaker \
perl-RRD-Simple rrdtool rrdtool-per

#wget http://ys-d.ys168.com/413941031/U6jHgXu52466H3XK5MVH/smokeping.pid
#wget http://ys-d.ys168.com/413941021/S7hLstr63543M6UHOU8/smokeping-2.7.3.tar.gz
#wget http://ys-d.ys168.com/413941021/S7hLfTu52466H3XK4MV5/fping-4.2-2.el8.x86_64.rpm
rpm -ivh --force fping-4.2-2.el8.x86_64.rpm

tar -zxvf smokeping-2.7.3.tar.gz -C /opt/
cd /opt/smokeping-2.7.3
./configure --prefix=/opt/smokeping
/usr/bin/gmake install

mkdir /opt/smokeping/{data,cache,var}
touch /var/log/smokeping.log

touch /opt/smokeping/etc/slave_secrets
echo "Zmcc\!\@\#idc.com" >> /opt/smokeping/etc/slave_secrets
sed -i "s:\\\:"":g" /opt/smokeping/etc/slave_secrets
chmod 600 /opt/smokeping/etc/slave_secrets
chown -R apache. /opt/smokeping/
chmod a+s /opt/smokeping/{data,cache,var}

setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/sysconfig/selinux
systemctl mask firewalld
systemctl stop firewalld
iptables -I INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -I INPUT -s 111.1.49.100 -j ACCEPT
service iptables save
service iptables restart

echo "/opt/smokeping/bin/smokeping --master-url=http://111.1.49.100:8088/smokeping/smokeping.fcgi --cache-dir=/opt/smokeping/cache --shared-secret=/opt/smokeping/etc/slave_secrets --logfile=/tmp/slave.log" >>/etc/rc.local

/opt/smokeping/bin/smokeping --master-url=http://111.1.49.100:8088/smokeping/smokeping.fcgi --cache-dir=/opt/smokeping/cache --shared-secret=/opt/smokeping/etc/slave_secrets --logfile=/tmp/slave.log
