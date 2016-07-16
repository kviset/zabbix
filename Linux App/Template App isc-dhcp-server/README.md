# Описание

Файл *Template App isc-dhcp-server.xml* добавляет *Template App isc-dhcp-server*, который состоит в группах: Templates, Templates App и Templates Custom и предназначен для монитоинга isc-dhcp-server.

С использованием данного темплейта zabbix осуществляет мониторинг:
- запущености сервиса;
- логов сервиса;
- изменение конфигурации;
- версии и контрольной суммы сервиса.

## Требуется 

```
zsender.pl версии 0.3.7 или старше
```

Настроим сохранение логов isc-dhcp-server в отдельный файл. Для этого создадим файл /etc/rsyslog.d/dhcpd.conf с помощью следующей команды:
```
 ~# cat >/etc/rsyslog.d/dhcpd.conf <<EOL
if (\$programname == 'dhcpd') then {
  /var/log/dhcpd.log
  stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```

Настроим ротацию логов для нового файла:
```
 ~# cat > /etc/logrotate.d/dhcpd <<EOL
/var/log/dhcpd.log
{
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root zabbix
}
EOL
```

# Установка

Импортируем темплейт *Template App isc-dhcp-server.xml* в zabbix сервер.

Скачаем файл dhcp.conf в директорию /etc/zabbix/zabbix_agentd.d и перегрузим zabbix-agent:
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App isc-dhcp-server/dhcp.conf'
 ~# /etc/init.d/zabbix-agent restart
[ ok ] Restarting zabbix-agent (via systemctl): zabbix-agent.service.
``` 

Добавим хост в темплейт *Template App isc-dhcp-server*
