#! /bin/bash

echo "Installing Zabbix agent..."
yum install -y http://repo.zabbix.com/zabbix/3.2/rhel/7/x86_64/zabbix-release-3.2-1.el7.noarch.rpm
yum install -y zabbix-agent
sed -i -e 's/\(^Server=\)\(.*\)/\1192\.168\.50\.101/' /etc/zabbix/zabbix_agentd.conf
sed -i -e 's/\(^ServerActive=.*\)/#\1/' /etc/zabbix/zabbix_agentd.conf
systemctl start zabbix-agent

