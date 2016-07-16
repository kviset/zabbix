# Описание
Файл *Template App Apache2.xml* добавляет темплейт *Template App Apache2*, предназначенный для мониторинга сервиса apache2. *Template App Apache2* состоит в группах: Templates, Templates App и Templates Custom.

С использованием данного темплейта осуществляется мониторинг:
- производительности с использованием модуля server-status;
- access.log. В zabbix записываются все записи с кодом ответа, не соответсвующим 200 и 304;
- error.log;
- конфигурации;
- версии и чек-суммы apache2.

## Макросы 

Для темплейта Template App Apache2 используются следующие макросы:
```Text
 {$APACHE_REQ_NUM} = 5
 {$APACHE_STATS_URL} = http://127.0.0.1/server-status
```
Они определенны в темплейте. В случае если для какого-то хоста данные значения необходимо изменить, их можно переопределить.

## Требования
```
 zsender.pl версии не ниже 0.3.2
```
```
 ~# aptitude install curl
```

# Установка

```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Apache2/apache.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Apache2/apache.pl' && \
chown zabbix apache.pl && chmod 550 apache.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт Template App Apache2
