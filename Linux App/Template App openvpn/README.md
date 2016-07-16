# Описание
Файл *Template App OpenVPN.xml* содержит *Template App OpenVPN server* и *Template App OpenVPN clients*, которые состоят в группах 
*Templates*, *Templates App* и *Templates Custom* и предназначены для мониторинга сериса openvpn и клиентов.

С использованием данного темплейта осуществляется мониторинг:
- лог-файлов;
- изменения конфигурации;
- версии;
- количества зарегистрированных и онлайн пользователей.
- производительности

# Установка

## Настройка 

В конфишурацию сервера добавте строку:
```
management localhost 7505
```
и перезагрузите 
```
 ~# /etc/init.d/openvpn restart
```
Создайте файл для конфигурирования скрипта мониторинга */usr/lib/zabbix/ovpnconf.pm* следующего содержания:
```
 ~# cat > /usr/lib/zabbix/ovpnconf.pm <<EOF
package ovpnconf;

\$OVPN_HOST		= '127.0.0.1';
\$OVPN_MGMT_PORT	= 7505;
\$OVPN_MGMT_PASSWORD	= "";
\$OVPN_AUTH_MODE        = "ldap";
\$OVPN_AUTH_CONF        = "/etc/openvpn/auth/ldap.conf";

1;
EOF
 ~# chown zabbix /usr/lib/zabbix/ovpnconf.pm && chmod 440 /usr/lib/zabbix/ovpnconf.pm 
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App openvpn/openvpn.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App openvpn/openvpn.pl' && \
chown zabbix openvpn.pl && chmod 550 openvpn.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавим хост в *Template App OpenVPN server*.
