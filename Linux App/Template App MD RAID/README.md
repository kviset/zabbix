# Описание

Файл *Template App MD RAID.xml* добавляет темплейт *Template App MD RAID*, который состоит в группах: *Templates*, *Templates App* и *Templates Custom*.

*Template App MD RAID* предназначен для мониторинга состояния MD RAID. C использованием данного темплейта осуществляется мониторинг:
- состояние и количество дисков в MD RAID;
- статус синхронизации

Темплейт выполнен на основе [Template MD RAID](https://github.com/krom/zabbix_template_md)

## Требования

```
zsender.pl версии не ниже 0.3.8
```

# Установка
Удалите имеющийся в zabbix темплейт *Template App MD RAID*.

```
~# cd /etc/zabbix/zabbix_agentd.d && \
rm userparameter_mysql.conf && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App MD RAID/mdraid.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App MD RAID/mdraid.pl' && \
chown zabbix mdraid.pl && chmod 550 mdraid.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавляем хост в темплейт Template App MD RAID.
