# Описание

Файл *Template HW nvidia.xml* добавляет *Template HW nvidia*, предназначенный для мониторинга NVIDIA GPU на ОС Linux.

*Template HW nvidia* состоит в группах: *Templates*, *Templates Hardware* и *Templates Custom*.

*Template HW nvidia* производит автоматический поиск доступных gpu и добавляет соответствующие итемы и триггеры в систему мониторинга 
zabbix. Использование данного темплейта возможно только на физических серверах.

*Template HW nvidia* производит мониторинг:
 - Производительности
 - температуры (триггер с автонастройкой)
 - потребляемой мощности
 - ошибок ECC
 - версии прошивки

# Установка
## Требования
```
zsender.pl версии не ниже 0.3.9
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).

```
 ~# aptitude install nvidia-smi libxml-simple-perl
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW nvidia/nvidia.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW nvidia/nvidia.pl' && \
chown zabbix nvidia.pl && chmod 550 nvidia.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template HW nvidia*
