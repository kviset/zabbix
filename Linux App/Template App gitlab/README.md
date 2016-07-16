# Описание
Файл *Template App gitlab.xml* добавляется темплейт *Template App gitlab* предназначенный для мониторинга gitlab, установленного из omnibus deb пакета. *Template App gitlab* состоит в группах: Templates, Templates App и Templates Custom.

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- запущенности;
- версии и контрольной суммы сервиса;
- изменения конфигурации.

## Макросы
В данном темплейте переопределяются значения макросов из наследуемых темплейтов.

# Установка
## Требования
Требуется установить темплейты:
- Template App nginx
- Template App PostgreSQL
- Template App Redis
- Template App Unicorn

## Настройка
Откройте файл */etc/gitlab/gitlab.rb* и добавьте в него следующие строки:
```
 unicorn['worker_memory_limit_max'] = "400 * 1 << 20"
...
 web_server['external_users'] = ['zabbix']
...
 nginx['custom_gitlab_server_config'] = "location = /nginx-stats {\nstub_status on;\naccess_log off;\nallow 127.0.0.1;\ndeny all;\n}\n"
...
 nginx['log_format'] = '[$time_iso8601] $remote_addr - $remote_user "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'
```
Запустим конфигурацию и перезапустим gitlab:
```
 ~# gitlab-ctl reconfigure
 ~# gitlab-ctl restart
```

## Установка
Добавьте хост в темплейт *Template App gitlab*
