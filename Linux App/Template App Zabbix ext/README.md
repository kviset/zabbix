# Описание
Файл *Template App Zabbix ext.xml* содержит *Template App Zabbix ext*, который состоит в группах *Templates*, *Templates App* и *Templates Custom*.

*Templates App Zabbix ext* является расширением для стандартных *Template App Zabbix Server* и *Template App Zabbix Proxy*. Он добавляет функционал мониторинга:
- лог-файлов zabbix-agent;
- размера лог-файлов;
- изменения конфигурации;
- контрольную сумму zabbix_server и zabbix_proxy.

## Макросы
```text
{$ZABBIXLOG} ⇒ /var/log/zabbix/zabbix_server.log
{$ZABBIXMODE} ⇒ zabbix_server
```
Макрос *ZABBIXLOG* служит для описания расположения лог-файлов zabbix-server или zabbix-proxy в Вашей системе.

Макрос *ZABBIXMODE* определяет мониториться zabbix_server или zabbix_proxy.

# Установка
- Импортируйте *Template App Zabbix ext.xml* в ваш заббикс сервер. 
- Подключите *Template App Zabbix ext* к *Template App Zabbix Server*.
 - Установите значение макроса *ZABBIXLOG* в *Template App Zabbix Server* согласно Вашему расположению лог-файлов zabbix-server (по умолчанию /var/log/zabbix/zabbix_server.log).
 - Установите значение макроса *ZABBIXMODE* в *Template App Zabbix Server* в *zabbix_server*.
- Подключите *Template App Zabbix ext* к *Template App Zabbix Proxy*.
 - Установите значение макроса *ZABBIXLOG* в *Template App Zabbix Proxy* согласно Вашему расположению лог-файлов zabbix-proxy (по умолчанию /var/log/zabbix/zabbix_proxy.log).
 - Установите значение макроса *ZABBIXMODE* в *Template App Zabbix Proxy* в *zabbix_proxy*.

