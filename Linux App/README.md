# Установка

Установка необходимых пакетов:
```
 ~# aptitude install zabbix-sender
```

Настройка sudo:
```
 ~# visudo
 > zabbix  ALL=NOPASSWD: ALL
```

Настройка групп пользователя zabbix:
```
 ~# usermod -a -G adm zabbix && \
usermod -a -G utmp zabbix
```

создание директорий:
```
 ~# mkdir -p /usr/lib/zabbix/agentscripts && \
mkdir /usr/lib/zabbix/backup && \
chown -R zabbix /usr/lib/zabbix && \
mkdir /var/lib/zabbix && chown zabbix /var/lib/zabbix/
```

## Установка zsender
```
 ~# cd /usr/lib/zabbix && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/zsender.pl' && \
chown zabbix zsender.pl && chmod 440 zsender.pl
```

После этого можно использовать темплейты из данной директории.
