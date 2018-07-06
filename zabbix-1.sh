#! /bin/bash

echo "Installing MariaDB..."
yum install -y mariadb mariadb-server
/usr/bin/mysql_install_db --user=mysql
systemctl start mariadb

echo "Creating initial database..."
mysql -uroot <<EOF 
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbixdb';
EOF

echo "Installing and configuring Zabbix Server..."
yum install -y http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y zabbix-server-mysql zabbix-web-mysql
zcat /usr/share/doc/zabbix-server-mysql-*/create.sql.gz | mysql -uzabbix -pzabbixdb zabbix
sed -i -e 's/\(.*\)\(DBPassword=\)\(.*\)/\2zabbixdb/' /etc/zabbix/zabbix_server.conf
sed -i -e 's/\(.*\)\(php_value date\.timezone\)\(.*\)/\t\2 Europe\/Minsk/' /etc/httpd/conf.d/zabbix.conf
sed -i -e 's/\(^Alias.*\)/#\1\n<VirtualHost *:80>\nDocumentRoot \/usr\/share\/zabbix\n<\/VirtualHost>/' /etc/httpd/conf.d/zabbix.conf
cp /vagrant/zabbix.conf.php /etc/zabbix/web
systemctl start httpd
systemctl start zabbix-server

echo "Installing Zabbix agent..."
yum install -y zabbix-agent
systemctl start zabbix-agent


