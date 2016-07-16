# Описание
Файл *Template Rmt gateway.xml* содержит *Template Rmt gateway* предназначенный для мониторинга публичного IP адреса и MAC адреса маршрутизатора по умолчанию.
*Template Rmt gateway* состоит в группах *Templates*, *Templates Custom* и *Templates Rmt*.

## Макросы
```text
{$GW_DEFAULTIP}	⇒ 192.168.0.1
{$PUBLICIP}	⇒ 8.8.8.8|4.4.4.4
{$GW_INT}	⇒ eth0
```
*GW_DEFAULTIP* - IP адрес маршрутизатора по умолчанию;

*PUBLICIP* - допустимые публичные адреса, указанные через символ '|'

#GW_INT* - внешний интерфейс маршрутизатора. Его будем включать и отключать для доступа к интернет.

# Установка
## Требования
```
zsender.pl версии не ниже 0.3.8
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).

## Настройка zabbix-server

Создайте группу хостов с названием "GROUPNAME". 
В эту группу добавьте хосты, на которые планируете установить темплейт *Template Rmt gateway* и планируете включать/выключать сетевой интерфейс из zabbix.

Перейдите *Administration->Scripts* и создайте новый скрипт. Назовите его 'Internet on-off'
- *Name*: internet on-off
- *Type*: Script
- *Execute on*: Zabbix server
- *Commands*: zabbix_get -s {HOST.CONN} -k script.gateway.turn {$GW_INT}
- *Description*: ---
- *User group*: Administrator
- *Host group*: Selected: GROUPNAME
- *Required host permissions*: Write
Нажмите *Update*.

Перейдите *Configuration->Actions* и создайте *Action* 'internet off':
- *Action*
-- *Name*: internet off
-- Остальные пункты оставте как есть.
- *Conditions*
-- *Conditions*: 'Trigger = Template Rmt gateway: router: Public IP not correct'
- *Operations*
-- Выберите созданное Action 'internet on-off'

## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/ Remote/Template Rmt gateway/gateway.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/ Remote/Template Rmt gateway/gateway.pl' && \
chown zabbix gateway.pl && chmod 550 gateway.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в *Template Rmt gateway*
