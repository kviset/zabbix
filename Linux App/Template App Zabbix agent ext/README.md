# Описание
Файл *Template App Zabbix agent ext.xml* содержит *Template App Zabbix agent ext*, который состоит в группах *Templates*, *Templates App* и *Templates Custom*.

*Templates App Zabbix agent ext* является расширением для стандартного *Template App Zabbix agent*. Он добавляет функционал мониторинга лог-файлов zabbix-agent.

## Макросы
```text
{$ZABBIXAGENTLOG} ⇒ /var/log/zabbix/zabbix_agentd.log
```
Макрос *ZABBIXAGENTLOG* служит для описания расположения лог-файлов zabbix-agent в Вашей системе.

# Установка
- Импортируйте *Template App Zabbix agent ext.xml* в ваш заббикс сервер. 
- Подключите *Template App Zabbix agent ext* к *Template App Zabbix agent*.
- Установите значение макрос *ZABBIXAGENTLOG* в *Template OS Windows* согласно Вашему расположению лог-файлов zabbix-agent.
- Установите значение макрос *ZABBIXAGENTLOG* в *Template OS Linux* согласно Вашему расположению лог-файлов zabbix-agent (по умолчанию /var/log/zabbix/zabbix_agentd.log).

