# Описание

Файл *Template App MySQL.xml* добавляет темплейт *Template App MySQL*, который состоит в группах: *Templates*, *Templates App* и *Templates Custom*.

*Template App MySQL* предназначен для мониторинга сервиса mysql. Выполнен на основе скрипта *mysqltunner*. С использованием данного темплейта осуществляется мониторинг:
- производительности mysql;
- изменения конфигурации;
- версии и контрольной суммы mysqld;

В данной версии не поддерживается мониторинг состояния slave. Это планируется реализовать в будущих версиях.

## Макросы

```text
{$MYSQLINTERVAL} => 60 - интервал сбора данных
```

## Требования

```
zsender.pl версии не ниже 0.3.2
```

# Установка

## Настройка

Добавим пользователя MySQL с правами для просмотра статистических данных:
```
 ~# mysql -p
Enter password: 
...
mysql> CREATE USER 'zmon'@'localhost' IDENTIFIED BY '********';
Query OK, 0 rows affected (0.02 sec)

mysql> GRANT SELECT ON *.* TO 'zmon'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql>flush privileges;
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW grants FOR zmon@localhost;
+--------------------------------------------------------------------------------------------------------------+
| Grants for zmon@localhost                                                                                    |
+--------------------------------------------------------------------------------------------------------------+
| GRANT SELECT ON *.* TO 'zmon'@'localhost' IDENTIFIED BY PASSWORD '*****************************************' |
+--------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

Создайте файл /usr/lib/zabbix/.my.cnf следующего содержания:
```
[client]
user=zmon
password=********
```

Проверяем работоспособность:
```
~# su zabbix -s /bin/bash
 ~$ HOME=/usr/lib/zabbix mysqladmin extended-status
+------------------------------------------+---------------+
| Variable_name                            | Value         |
+------------------------------------------+---------------+
| Aborted_clients                          | 104           |
| Aborted_connects                         | 0             |
| Binlog_cache_disk_use                    | 0             |
| Binlog_cache_use                         | 0             |
...
```

## Установка
Удалите имеющийся в zabbix темплейт *Template App MySQL*.

```
~# cd /etc/zabbix/zabbix_agentd.d && \
rm userparameter_mysql.conf && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App MySQL/mysql.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App MySQL/mysql.pl' && \
chown zabbix mysql.pl && chmod 550 mysql.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавляем хост в темплейт Template App MySQL.
