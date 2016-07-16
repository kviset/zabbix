# Описание

Файл *Template HW SMART.xml* добавляет *Template HW SMART*, предназначенный для мониторинга параметров SMART HDD на ОС Linux.

*Template HW SMART* состоит в группах: *Templates*, *Templates Hardware* и *Templates Custom*.

*Template HW SMART* производит автоматический поиск доступных hdd и добавляет соответствующие итемы и триггеры в систему мониторинга 
zabbix. Использование данного темплейта возможно только на физических серверах.

# Установка
## Требования
```
zsender.pl версии не ниже 0.3.3
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).

```
 ~# aptitude install smartmontools
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW SMART/smart.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW SMART/smart.pl' && \
chown zabbix smart.pl && chmod 550 smart.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template HW SMART*
