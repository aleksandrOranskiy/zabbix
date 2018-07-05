#! /bin/bash

echo "Receiving a key..."
json_key='{"jsonrpc":"2.0","method":"user.login","id":1,"auth":null,"params":{"user":"Admin","password":"zabbix"}}'
curl -d $json_key -H "Content-Type: application/json" -X POST http://192.168.50.101/api_jsonrpc.php > temp.json

key=$(sed -e 's/^.*"result":"\([^"]*\)".*$/\1/' temp.json)
hostname=$(hostname)

echo "Creating a hostgroup..."

json_temp='{"jsonrpc":"2.0","method":"hostgroup.get","params":{"output":"extend","filter":{"name":"CloudHosts"}},"auth":"'$key'","id":1}'
curl -d $json_temp -H "Content-Type: application/json" -X POST http://192.168.50.101/api_jsonrpc.php > group_zabbix
gid=$(sed -e 's/^.*"groupid":"\([^"]*\)".*$/\1/' group_zabbix)

if ! grep 'groupid' group_zabbix; then 
    json_group='{"jsonrpc":"2.0","method":"hostgroup.create","auth":"'$key'","params":{"name":"CloudHosts"},"id":1}' 
    curl -d $json_group -H "Content-Type: application/json" -X POST http://192.168.50.101/api_jsonrpc.php -v > group_zabbix
    gid=$(sed -e 's/^.*"groupids":\["\([^"]*\)".*$/\1/' group_zabbix)
fi


echo "Creating a template..."

json_temp='{"jsonrpc":"2.0","method":"template.get","params":{"output":"extend","filter":{"host":["Custom"]}},"auth":"'$key'","id":1}'
curl -d $json_temp -H "Content-Type: application/json" -X POST http://192.168.50.101/api_jsonrpc.php > template_zabbix
tid=$(sed -e 's/^.*"templateid":"\([^"]*\)".*$/\1/' template_zabbix)

if ! grep 'host' template_zabbix; then
    json_template='{"jsonrpc":"2.0","method":"template.create","auth":"'$key'","params":{"host":"Custom","groups":{"groupid":"'$gid'"}},"id":1}'
    curl -d $json_template -H "Content-Type: application/json" -X POST http://192.168.50.101/api_jsonrpc.php > template_zabbix
    tid=$(sed -e 's/^.*"templateids":\["\([^"]*\)"\].*$/\1/' template_zabbix)
fi

ip=$(hostname -I | cut -d' ' -f2)

echo "Creating a host..."
json_host='{"jsonrpc":"2.0","method":"host.create","params":{"host":"'$hostname'","interfaces":[{"type":1,"main":1,"useip":1,"ip":"'$ip'","dns":"","port":"10050"}],"groups":[{"groupid":"'$gid'"}],"templates":[{"templateid":"'$tid'"}]},"auth":"'$key'","id":1}'
curl -d $json_host -H "Content-Type: application/json" -X POST http://192.168.50.101/api_jsonrpc.php > host
