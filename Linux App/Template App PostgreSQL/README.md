# Описание
Файл *Template App PostgreSQL.xml* добавляет темплейт *Template App PostgreSQL*, предназначенный для мониторинга БД PostgreSQL.
 *Template App PostgreSQL* состоит в группах: Templates, Templates App и Templates Custom.

Темпелйт выполнен на основе [pg-monz](http://pg-monz.github.io/pg_monz/index-en.html).

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- запущенности;
- версии и контрольной суммы сервиса.

## Макросы
```text
{$PGCACHEHIT_THRESHOLD}		⇒90
{$PGCHECKPOINTS_THRESHOLD}	⇒10
{$PGCONNECTIONS_THRESHOLD}	⇒95
{$PGDBSIZE_THRESHOLD}		⇒1073741824
{$PGDEADLOCK_THRESHOLD}		⇒0
{$PGLOGDIR}			⇒/usr/local/pgsql/data/pg_log
{$PGPATH}			⇒value
{$PGSLOWQUERY_COUNT_THRESHOLD}	⇒10
{$PGSLOWQUERY_TIME_THRESHOLD}	⇒10
{$PGTEMPBYTES_THRESHOLD}	⇒8388608
```

# Установка
## Настройка

Разрешение доступа пользователю zabbix:
```
 ~# sudo -u postgres psql -d postgres
psql (X.X.XX)
Type "help" for help.

postgres=# CREATE ROLE zabbix WITH LOGIN;
postgres=# GRANT SELECT ON ALL TABLES IN SCHEMA public TO zabbix;
postgres=# \q
```
Создайте файл для конфигурирования скрипта мониторинга */usr/lib/zabbix/psqlconf.pm* следующего содержания:
```
 ~# cat > /usr/lib/zabbix/psqlconf.pm <<EOF
package psqlconf;

\$PGDATABASE="postgres";

1;
EOF
 ~# chown zabbix /usr/lib/zabbix/psqlconf.pm && chmod 440 /usr/lib/zabbix/psqlconf.pm 
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App PostgreSQL/psql.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App PostgreSQL/psql.pl' && \
chown zabbix psql.pl && chmod 550 psql.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template App PostgreSQL*
