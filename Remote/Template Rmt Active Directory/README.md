# Описание

Файл *Template Rmt Active Directory.xml* добавляет Template Rmt Active Directory, который состоит в группах: *Templates*, 
*Templates Rmt* и *Templates Custom*.

*Template Rmt Active Directory* предназначен для общего мониторинга состояния различных AD (Windows AD, Samba4 AD). Мониторинг 
осуществляется вызовом скриптов внешних проверок. Т.е. Скрипты выполняются на сервере zabbix или zabbix-proxy. Осуществляется 
мониторинг следующих параметров:
- количество пользователей, групп, политик;
- изменения членов групп;
- изменение версии политик.

Темплейт может быть добавлен к любому хосту. Я рекомендую создать для этого отдельный хост или добавить темплейт непосредственно 
к серверу AD.

Первый час после добавление темплейта будет появляться триггер *AD: ad_run.pl contain failed msg* - это вызвано тем, что discovery 
не добавило необходимые итемы, а runner уже пытается их отправить через zsender.

## Требование

```
zsender.pl версии не ниже 0.3.3
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).

На сервере zabbix или zabbix-proxy должны быть установлены следующие пакеты
```
 ~# aptitude install zabbix-sender libstring-crc32-perl winbind
```

Сервер zabbix или zabbix-proxy должен быть включен в AD.

# Устанвока
## Настройка

В случае если сервер zabbix или zabbix-proxy включен в AD с использованием sssd, то необходимо добавить следующие строки в файл smb.conf:
```
winbind use default domain = yes
```
## Установка
```
~# cd /usr/lib/zabbix/externalscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Remote/Template Rmt Active Directory/ad_discovery.pl' && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Remote/Template Rmt Active Directory/ad_run.pl && \
chown zabbix ad_*.pl && chmod 550 ad_*.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавим хост контроллера домена или другой в темплейт Template Rmt Active Directory
