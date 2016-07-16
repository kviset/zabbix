# Описание
Файл *Template Rmt PingNslookup.xml* содержит *Template Rmt PingNslookup*, который состоит в группах *Templates*, *Templates Rmt* и 
*Templates Custom*. И предназначен для проверки соединение с сетью Интернет на Linux серверах.

При помощи темплейта *Template Rmt PingNslookup* осуществляется ping и nslookup заданных серверов. При выполнение данных операций 
происходит измерение времени.

## Макросы
```text
{$INETNSLKP}	⇒google.com_yahoo.com_ya.ru
{$INETPING}	⇒8.8.8.8_98.137.236.150_213.180.204.3
{$INETSIZE}	⇒64
```
Макрос *{$INETNSLKP}* представляет собой список доменов для выполнения nslookup. В качестве разделителя используется символ '_'.

Макрос *{$INETPING}* представляет собой список IP адресов для команды ping. В качестве разделителя используется символ '_'.

Макрос *{$INETSIZE}* представляет собой размер пакета для команды пинг.

# Установка
## Требования
```
zsender.pl версии не ниже 0.3.8
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).


Необходима установка следующих пакетов:
```
 ~# aptitude install fping libnet-nslookup-perl
```
## Настройка
Модифицируем разрешения fping:
```
 ~# chown root:zabbix /usr/bin/fping && chmod 4710 /usr/bin/fping
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Remote/Template Rmt PingNslookup/internet.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Remote/Template Rmt PingNslookup/internet.pl' && \
chown zabbix internet.pl && chmod 550 internet.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавим хост в *Template Rmt PingNslookup*
