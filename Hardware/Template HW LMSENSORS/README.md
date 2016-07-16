# Описание

Файл *Template HW LMSENSORS.xml* добавляет *Template HW LMSENSORS*, предназначенный для мониторинга температуры на встроенных сенсорах ЦПУ и чипсет. *Template HW LMSENSORS* состоит в
группах: *Templates*, *Templates Hardware* и *Templates Custom*. 

*Template HW LMSENSORS* производит автоматический поиск датчиков температуры, доступных для мониторинга в системе, и автоматически настраивает триггеры допустимой температуры.
Использование данного темплейта возможно только на физических серверах.

# Установка
## Требования 
```
zsender.pl версии не ниже 0.3.8
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).

```
 ~# aptitude install lm-sensors
```

## Настройка
Выполните команду:
```
sensors-detect
```
и следуйте полученным инструкциям.

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW LMSENSORS/lmsensors.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW LMSENSORS/lmsensors.pl' && \
chown zabbix lmsensors.pl && chmod 550 lmsensors.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template HW LMSENSORS*
