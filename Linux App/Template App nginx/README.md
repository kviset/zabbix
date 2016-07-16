# Описание
Файл *Template App nginx.xml* добавляет темплейт *Template App Nginx*, предназначенный для мониторинга сервиса nginx. *Template App Nginx* состоит в группах: Templates, Templates App и Templates Custom.

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- изменения конфигурации;
- access и error лог-файлов, их содержимого и размера;
- запущенности;
- версии и контрольной суммы сервиса.

## Макросы
```text
{$NGINX_ACCESSLOG}	⇒/var/log/nginx/access.log
{$NGINX_BIN}		⇒nginx
{$NGINX_CONF}		⇒/etc/nginx
{$NGINX_CON_NUM}	⇒2
{$NGINX_ERRORLOG}	⇒/var/log/nginx/error.log
{$NGINX_REQ_NUM}	⇒5
{$NGINX_URL}		⇒https://127.0.0.1/nginx-stats
```

# Установка
## Требования
```
 ~# aptitude install curl
```

## Настройка
Добавим в конфигурацию nginx следующие строки:
```
location = /nginx-stats {
stub_status on;
access_log off;
allow 127.0.0.1;
deny all;
}
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App nginx/nginx.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App nginx/nginx.pl' && \
chown zabbix nginx.pl && chmod 550 nginx.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template App Nginx*
