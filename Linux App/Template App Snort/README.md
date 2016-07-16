# Описание
Файл *Template App Snort.xml* добавляет темплейт *Template App Snort*, предназначенный для мониторинга IPS/IDS Snort. *Template App Snort* состоит в группах: Templates, Templates App и Templates Custom.

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- количества обнаруженных угроз;
- устанавливать и мониторить установку обновления сигнатур;
- лог-файлы;
- мониторинг запущенности.

# Установка
## Настройка
Создадим конфигурационный файл для скрипта snort.pl:
```
 ~# cat > /usr/lib/zabbix/snortconf.pm <<EOF
package snortconf;

@INSTNAME   	= (
		"instance_1",
		"instance_2",
		);

@STATS      	= (
                "/var/log/snort/inst1/snort.stats",
                "/var/log/snort/inst2/snort.stats"
		);

@UPDATEFILES	= (
		"pulledpork.conf",
		"disablesid.conf",
		"dropsid.conf",
		"enablesid.conf",
		"modifysid.conf",
		"snort.conf",
		"threshold.conf",
		);

@UPDATESRC	= (
		"https://SERVERNAME/path/inst1/",
		"https://SERVERNAME/path/inst2/"
		);

@UPDATEDST	= (
		"/etc/snort/inst1/",
		"/etc/snort/inst2/"
		);

@UPDATERULE	= (
		"pulledpork.pl -c /etc/snort/inst1/pulledpork.conf",
		"pulledpork.pl -c /etc/snort/inst2/pulledpork.conf"
		);

@RESTART	= (
		"/etc/init.d/ips-inst1 restart",
		"/etc/init.d/ips-inst2 restart"
		);

1;
EOF
```
Установим права на файл с конфигурацией:
```
 ~# chown zabbix /usr/lib/zabbix/snortconf.pm && chmod 440 /usr/lib/zabbix/snortconf.pm
```

Необходимо включить логирования состояния snort. Для этого в файл /etc/snort/snort.conf необходимо добавить следующие строки:
```
preprocessor perfmonitor: \
  time 30 file /var/log/snort/snort.stats
```

Для того чтобы логи snort.pl в режиме обновления записывались в отдельный файл, необходимо создать файл /etc/rsyslog.d/snort.conf и перезагрузить rsyslog:
```
 ~# cat >/etc/rsyslog.d/update-snort.conf <<EOL
if (\$programname == 'snort.pl') then {
  /var/log/zabbix/snort.log
  stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроить ротацию логов для нового файла. Для этого создайте файл /etc/logrotate.d/zabbix-snort следующего содержания:
```
 ~# cat > /etc/logrotate.d/zabbix-snort <<EOL
/var/log/zabbix/snort.log
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
#snort update
00 0	* * *	root	/usr/lib/zabbix/agentscripts/snort.pl update 1
```
## Установка

```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Snort/snort.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Snort/snort.pl' && \
chown zabbix snort.pl && chmod 550 snort.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт Template App Snort
