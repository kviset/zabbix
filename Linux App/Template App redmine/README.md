# Описание
Файл *Template App redmine.xml* добавляет *Template App redmine*, который состоит в группах *Templates*, *Templates App* и 
*Templates Custom*.

*Template App redmine* предназначен для мониторинга:
- обновлений redmine;
- изменения ее конфигурации;
- количества пользователей;
- лог-файлов;

# Установка
## Требования
Необходима установка следующих пакетов:
```
 ~# aptitude install git-core
```

Настроим запись логов скрипта проверки обновлений в отдельный файл:
```
 ~# cat >/etc/rsyslog.d/redmine.conf <<EOL
if (\$programname == 'redmine.pl') then {
  /var/log/zabbix/redmine.log
  stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроим ротацию данных логов:
```
 ~# cat > /etc/logrotate.d/zabbix-redmine <<EOL
/var/www/redmine/log/production.log
{
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 redmine zabbix
}
/var/log/zabbix/redmine.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root zabbix
}
EOL
```
Так как обновление репозиториев redmine занимает слишком много времени, то будем его выполнять через cron. Для этого откроем файл /etc/crontab и добавьте туда следующие строки:
```
#redmine remotes update
00 0	* * *	root	/usr/lib/zabbix/agentscripts/redmine.pl update /var/www/redmine/ 1
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App redmine/redmine.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App redmine/redmine.pl && \
chown zabbix redmine.pl && chmod 550 redmine.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавьте хост в *Template App redmine*.
