# Описание

Файл *Template App apt-cacher-ng.xml* добавляет *Template App apt-cacher-ng*, который состоит в группах: *Templates*, *Templates App* и *Templates Custom*.

*Template App apt-cacher-ng* предназначен для мониторинга сервиса *apt-cacher-ng*. С использованием данного темплейта осуществляется мониторинг:
- логов ошибок apt-cacher-ng;
- логов доступа к apt-cacher-ng, сообщений содержащих ошибки;
- размера кеша apt-cacher-ng;
- изменения конфигурации apt-cacher-ng;
- контрольной суммы apt-cacher-ng.

# Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App apt-cacher-ng/apt-cacher-ng.conf'
 ~# /etc/init.d/zabbix-agent restart
```

Добавляем хост в темплейт Template App apt-cacher-ng.
