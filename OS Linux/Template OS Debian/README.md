# Описание

Файл *Template OS Debian.xml* добавляет два темплейта: Template OS Debian public и Template OS Debian private, который состоит в группах: Templates, Templates OS и Templates Custom.

*Template OS Debian public* - предназначен для хранения общих итемов и тригеров. Наследует Template OS Linux

*Template OS Debian private* - предназначен для хранения итемов и триггеров Вашей инфраструктуры. Наследует Template OS Debian public. Также в этом темплейте можно производить модификации (включения/отключения) итемов и триггеров темплейтов Template OS Debian public и Template OS Linux.

Данное разделение выполнено с целью упрощения механизма обновления темплейтов.

С использованием данного темплейта осуществляется мониторинг:
- производительности ОС;
- основных лог-файлов (auth.log, syslog, wtmp), осуществляется мониторинг содержимого, размера файлов
- чек-суммы основных конфигурационных файлов и исполняемых программ
- не установленных обновлений и необходимости перезагрузки ОС.

## Макросы 

Для темплейта Template OS Debian public используются следующие макросы:
```text
{$ROTATETIMEDOWN} => 012500
{$ROTATETIMEUP}   => 015600
```

# Установка
## Требования

```
zsender.pl версии не ниже 0.3.1
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).

## Настройки

Разрешим доступ ко всем портам с локального интерфейса:
```
 ~# iptables -A INPUT -i lo -j ACCEPT
 ~# /etc/init.d/netfilter-persistent save
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/OS Linux/Template OS Debian/linux.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/OS Linux/Template OS Debian/linux.pl' && \
chown zabbix linux.pl && chmod 550 linux.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавляем хост в темплейт Template OS Debian private.
