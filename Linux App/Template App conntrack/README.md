# Описание
Файл *Template App conntrack.xml* содержит *Template App conntrack*, который состоит в группах *Templates*, *Templates App* и *Templates Custom*. 
*Template App conntrack* предназначен для мониторинга сервиса conntrack.

Осуществляется мониторинг:
- версии и контрольной суммы conntrackd;
- запущенность процесса;
- изменения конфигурации.

# Установка
```
~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App conntrack/conntrack.conf'
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост к темплейту *Template App conntrack*.
