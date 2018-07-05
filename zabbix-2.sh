#! /bin/bash

echo "Installing Zabbix agent..."
yum install -y http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y zabbix-agent
sed -i -e 's/\(^Server.*=\)\(.*\)/\1192\.168\.50\.101/' /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent
yum install -y zabbix-sender
yum install -y zabbix-get
yum install -y java-1.8.0-openjdk
wget http://ftp.byfly.by/pub/apache.org/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz
mkdir /opt/tomcat
tar xvf apache-tomcat-8.5.32.tar.gz -C /opt/tomcat --strip-components=1

echo "Installing tools for Java Monitoring"
yum install -y zabbix-java-gateway
systemctl start zabbix-java-gateway
systemctl enable zabbix-java-gateway

echo "Autoregistering..."
/vagrant/auto.sh
