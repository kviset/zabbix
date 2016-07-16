# Описание
Файл *Template App pacemaker* содержит темплейты *Template App Pacemaker* и *Template App Pacemaker node*, которые состоят в группах *Templates*, *Templates App* и *Templates Custom*.

*Template App Pacemaker* - предназначен для общего мониторинга состояния отказоустойчивого кластера.

*Template App Pacemaker node* - предназначен для мониторинга состояния ноды отказоустойчивого кластера.

С использованием данных темплейтов осуществляется мониторинг:
- общего состояния кластера (количество нод, ресурсов и их состояния);
- версии и контрольной суммы;
- запущенности процессов;
- файлов логов;

# Установка
## Требования
Необходима установка следующих пакетов:
```
 ~# aptitude install xml2
```

## Настройка
Добавим пользователя zabbix в группу haclient:
```
 ~# usermod -a -G haclient zabbix
```
Перенаправим забиси логов Pacemaker в отдельный файл:
```
 ~# cat >/etc/rsyslog.d/pacemaker.conf <<EOL
if ((\$programname == 'crmd') \\
or (\$programname == 'pengine') \\
or (\$programname == 'crm_verify') \\
or (\$programname == 'pacemaker_remoted') \\
or (\$programname == 'corosync') \\
or (\$programname == 'attrd') \\
or (\$programname == 'pacemakerd') \\
or (\$programname == 'cib') \\
or (\$programname == 'lrmd') \\
or (\$programname == 'stonithd')) then {
	/var/log/pacemaker.log
	stop
}
EOL
~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроим ротацию логов:
```
 ~# cat > /etc/logrotate.d/pacemaker <<EOL
/var/log/pacemaker.log {
    compress
    dateext
    weekly
    rotate 99
    maxage 365
    notifempty
    missingok
    copytruncate
}
EOL
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App pacemaker/pacemaker.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App pacemaker/pacemaker.pl'
chown zabbix pacemaker.pl && chmod 550 pacemaker.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте все ноды кластера в темплейте *Template App Pacemaker node*. Для
мониторинга общего состояния создайте хост и в качестве IP адреса укажите 
VIP кластера. Данный хост добавьте в темплейт *Template App Pacemaker*.
