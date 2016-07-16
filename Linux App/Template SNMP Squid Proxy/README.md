# Описание

Файл *Template SNMP Squid Proxy.xml* добавляет *Template SNMP Squid Proxy*, который состоит в группах: *Templates*, *Templates App* и *Templates Custom*. И предназначен для мониторинга squid proxy через SNMP.

*Template SNMP Squid Proxy* выполнен на основе одноименного темплейта Stephen Fritz [Project Page](https://share.zabbix.com/index.php?option=com_mtree&task=att_download&link_id=281&cf_id=37).
В данной реализации добавлен мониторинг:
- версии и контрольной суммы;
- изменения конфигурации;
- логов cache.log и access.log.

## Макросы

Для темплейта *Template SNMP Squid Proxy* используются следующие макросы:
```text
{$SQUID_SNMP_COMMUNITY} => <COMMUNITYNAME>
{$SQUID_SNMP_PORT} => 3401
```

# Установка
## Настройка

Добавьте следующие строки в файл */etc/squid3/squid.conf*:
```
snmp_port 3401
acl zabbix_server src <ZABBIXSERVERIP>/32
acl snmppublic snmp_community <COMMUNITYNAME>
snmp_access allow snmppublic zabbix_server
snmp_access deny all
```
И перезапустите squid:
```
/etc/init.d/dquid3 restart
```

## Установка

```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template SNMP Squid Proxy/squid.conf'
 ~# /etc/init.d/zabbix-agent restart
```
Добавьте хост в темплейт *Template SNMP Squid Proxy*
