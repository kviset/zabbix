# Описание
Файл *Template App Tor.xml* содержит *Template App Tor*, который состоит в группах *Templates*, *Templates App* и *Templates Custom* и предназначен для мониторинга сервера tor.

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- изменения конфигурации;
- версии и контрольной суммы;
- лог-файлов.

# Установка
## Настройка
Необходимо установить zsender.pl.

Добавим пользователя zabbix в группу debian-tor:
```
 ~# usermod -a -G debian-tor zabbix
```
Создайте файл /usr/lib/zabbix/.torpass в который поместите пароль для соединение с tor.

```
 ~# echo "PASSWORD" > /usr/lib/zabbix/.torpass
```
сгенерируйте хеш для сохранения его в конфигурацию tor:
```
 ~# tor --hash-password PASSWORD
16:24836C9E52B6A1786073782985488DD9F9E2C3BA708AAA3EA1C086777D
```
Откройте файл /etc/tor/torrc и добавте следующие строки:
```
HashedControlPassword 16:24836C9E52B6A1786073782985488DD9F9E2C3BA708AAA3EA1C086777D
CookieAuthentication 0
```
Перезапустите tor:
```
 ~# /etc/init.d/tor restart
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Tor/tor.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Tor/tor.pl' && \
chown zabbix tor.pl && chmod 550 tor.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавим хост в *Template App Tor*.
