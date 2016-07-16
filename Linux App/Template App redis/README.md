# Описание
Файл *Template App Redis.xml* добавляется темплейт *Template App Redis* предназначенный для мониторинга БД Redis. *Template App Redis*
состоит в группах: Templates, Templates App и Templates Custom.

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- запущенности;
- версии и контрольной суммы сервиса;
- изменения конфигурации.

## Макросы
```text
{$REDIS_BIN}	⇒redis-server
{$REDIS_CONF}	⇒/etc/redis/redis.conf
{$REDIS_URI}	⇒redis://localhost:6379
```

# Установка
## Требования
 Установите пакеты:
```
 ~# aptitude install libredis-perl
```
## Настройка

Установите макрос *{$REDIS_URI}* в соответствии со способом подключения к redis. Возможны следующие форматы записи:
```
redis://localhost:6379 - подключение через TCP сокет.
unix://path/to/sock    - подключение через unix сокет.
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App redis/redis.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App redis/redis.pl' && \
chown zabbix redis.pl && chmod 550 redis.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template App Redis*
