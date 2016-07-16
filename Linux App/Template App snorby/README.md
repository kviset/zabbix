# Описание
Файл *Template App snorby.xml* добавляет темплейт *Template App snorby*, предназначенный для мониторинга Web-приложения snorby. 
*Template App snorby* состоит в группах: *Templates*, *Templates App* и *Templates Custom*.

С использованием данного темплейта осуществляется мониторинг:
- наличие обновлений Web-приложение;
- запущенности delayed_job;
- изменение конфигурации;
- лог-файлы;

# Установка
## Требования
```
 ~# aptitude install git-core
```

## Настройка
Для того чтобы логи snorby.pl в режиме обновления записывались в отдельный файл, необходимо создать файл /etc/rsyslog.d/snorby.conf и перезагрузить rsyslog:
```
 ~# cat >/etc/rsyslog.d/snorby.conf <<EOL
if (\$programname == 'snorby.pl') then {
  /var/log/zabbix/snorby.log
  stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроить ротацию логов для нового файла. Для этого создайте файл /etc/logrotate.d/zabbix-snorby следующего содержания:
```
 ~# cat > /etc/logrotate.d/zabbix-snorby <<EOL
/var/www/snorby/log/delayed_job.log
/var/www/snorby/log/production.log
{
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 nobody zabbix
}
/var/log/zabbix/snorby.log
{
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
Так как обновление занимает слишком много времени, то будем его выполнять через cron. Для этого откроем файл /etc/crontab и добавим туда следующие строки:
```
#snorby remotes update
00 0	* * *	root	/usr/lib/zabbix/agentscripts/snorby.pl update /var/www/snorby 1
```

## Установка

```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App snorby/snorby.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App snorby/snorby.pl' && \
chown zabbix snorby.pl && chmod 550 snorby.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template App snorby*
