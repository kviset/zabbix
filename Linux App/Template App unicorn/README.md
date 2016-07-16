# Описание
Файл *Template App unicorn.xml* добавляет темплейт *Template App unicorn*, предназначенный для мониторинга web-сервера unicorn. *Template App unicorn* состоит в группах: Templates, Templates App и Templates Custom.

С использованием данного темплейта осуществляется мониторинг:
- запущенности;
- изменения конфигурации.

## Макросы
```text
{$UNICORN_CONF}		⇒/etc/unicorn.rb
{$UNICORN_ERRLOG}	⇒/var/log/unicorn_stderr.log
```

# Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App unicorn/unicorn.conf'
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template App unicorn*
