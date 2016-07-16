# Описание
Файл *Template App mediawiki.xml* добавляет *Template App mediawiki*, который состоит в группах *Templates*, *Templates App* и *Templates Custom*.

*Template App mediawiki* предназначен для мониторинга обновлений mediawiki и изменения ее конфигурации.

# Установка
## Требования
Необходима установка следующих пакетов:
```
 ~# aptitude install git-core
```

Настроим запись логов скрипта проверки обновлений в отдельный файл:
```
 ~# cat >/etc/rsyslog.d/mediawiki.conf <<EOL
if (\$programname == 'mediawiki.pl') then {
	/var/log/zabbix/mediawiki.log
	stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроим ротацию данных логов:
```
 ~# cat > /etc/logrotate.d/zabbix-mediawiki <<EOL
/var/log/zabbix/mediawiki.log {
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
Так как обновление репозиториев mediawiki занимает слишком много времени, то будем его выполнять через cron. Для этого откроем файл /etc/crontab и добавим туда следующие строки:
```
#mediawiki remotes update
00 0	* * *	root	/usr/lib/zabbix/agentscripts/mediawiki.pl update /var/www/wiki/ 1
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App mediawiki/mediawiki.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App mediawiki/mediawiki.pl' && \
chown zabbix mediawiki.pl && chmod 550 mediawiki.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавьте хост в *Template App mediawiki*.
