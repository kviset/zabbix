# Описание
Файл *Template Rmt speedtest.xml* содержит темплейт *Template Rmt speedtest*, который состоит в группах *Templates*, *Templates Rmt* и *Templates Custom*.
И предназначен для тестирования скорости соединения с интернет.

## Макросы
```text
{$SPEEDTEST_ID} ⇒ 4358_5029_6386
```
Данный макрос перечисляет ID серверов с которыми будет производиться тестирование скорости разделенный символом '_'. Список серверов можно получить командой:
```
 ~# speedtest-cli --list
```

# Установка
## Требуется
```
zsender.pl версии не ниже 0.3.8
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).


Установка следующих пакетов:
```
 ~# aptitude install speedtest-cli
```

## Настройка
Для того чтобы логи speedtest.pl записывались в отдельный файл, необходимо создать файл /etc/rsyslog.d/speedtest.conf и перезагрузить rsyslog:
```
 ~# cat >/etc/rsyslog.d/speedtest.conf <<EOL
if (\$programname == 'speedtest.pl') then {
	/var/log/zabbix/speedtest.log
	stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроить ротацию логов для нового файла. Для этого создайте файл /etc/logrotate.d/zabbix-speedtest следующего содержания:
```
 ~# cat > /etc/logrotate.d/zabbix-speedtest <<EOL
/var/log/zabbix/speedtest.log {
    daily
    rotate 7
    compress
    delaycompress
    missingok
    notifempty
    create 0640 zabbix zabbix
}
EOL
```
Так как выполнение скрипта speedtest.pl занимает слишком много времени, то его запуск осуществляется через cron. Для этого откроем файл /etc/crontab и добавим туда следующие строки:
```
#zabbix bandwidth measurement
00 *	* * *	zabbix	/usr/lib/zabbix/agentscripts/speedtest.pl
```

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Remote/Template Rmt speedtest/speedtest.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Remote/Template Rmt speedtest/speedtest.pl' && \
chown zabbix speedtest.pl && chmod 550 speedtest.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавьте хост в *Template Rmt speedtest*
