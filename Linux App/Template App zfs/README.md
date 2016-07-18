# Описание
Файл *Template App zfs.xml* содержит *Template App zfs*, который состоит в группах *Templates*, *Templates App* и *Templates Custom* и предназначен 
для мониторинга zfs на ОС Linux. Темплейт выполнен на основе [этого темплейта](https://share.zabbix.com/operating-systems/linux/zfs-on-linux).
Были применены следующие исправления:
- переименован параметр *meta_size* в *metadata_size*

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- версии;

# Установка
## Настройка
Необходимо установить zsender.pl.

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App zfs/zfs.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App zfs/zfs.pl' && \
chown zabbix zfs.pl && chmod 550 zfs.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавим хост в *Template App zfs*.
