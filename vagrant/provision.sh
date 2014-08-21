#!/bin/sh

#
# iptables off
#
/sbin/iptables -F
/sbin/service iptables stop
/sbin/chkconfig iptables off


#
# yum repository
#
rpm -ivh http://ftp.riken.jp/Linux/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
rpm -ivh http://dl.iuscommunity.org/pub/ius/stable/CentOS/6/x86_64/ius-release-1.0-13.ius.centos6.noarch.rpm
#yum -y update


#
# ntp
#
yum -y install ntp
/sbin/service ntpd start
/sbin/chkconfig ntpd on


#
# php
#
yum -y install php php-cli php-pdo php-mbstring php-mcrypt php-pecl-memcache php-mysql php-devel php-common php-pgsql php-pear php-gd php-xml php-pecl-xdebug php-pecl-apc
touch /var/log/php.log && chmod 666 /var/log/php.log
cp -a /vagrant/php.ini /etc/php.ini


#
# Apache
#
cp -a /vagrant/httpd.conf /etc/httpd/conf/
/sbin/service httpd restart
/sbin/chkconfig httpd on


#
# MySQL
#
yum -y install http://repo.mysql.com/mysql-community-release-el6-4.noarch.rpm
yum -y install mysql-community-server
cp -a /vagrant/my.cnf /etc/my.cnf
chmod 644 /etc/my.cnf
/sbin/service mysqld restart
/sbin/chkconfig mysqld on

mysql -u root -e "create database app default charset utf8"
mysql -u root -e "create database test_app default charset utf8"


#
# Composer
#
if [ -f /share/composer.json ]; then
  cd /share && curl -s http://getcomposer.org/installer | php
  /usr/bin/php /share/composer.phar install --dev
  yes | php /share/Vendor/cakephp/cakephp/lib/Cake/Console/cake.php bake project app
  cp -a /vagrant/cakephp/Config/database.php /share/app/Config/database.php
  cp -a /vagrant/cakephp/Config/bootstrap.php /share/app/Config/bootstrap.php
  #cp -a /vagrant/cakephp/Config/email.php /share/app/Config/email.php
  cp -a /vagrant/cakephp/webroot/index.php /share/app/webroot/index.php
  cp -a /vagrant/cakephp/webroot/test.php /share/app/webroot/test.php
fi

