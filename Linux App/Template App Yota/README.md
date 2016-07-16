# Описание
Файл *Template App Yota.xml* добавляет *Template App Yota*, который состоит в группах *Templates*, *Templates App* и *Templates Custom*. 
*Template App Yota* Предназначен для мониторинга состояния сетевого интерфейса, созданного Yota модемом. Производится мониторинг:
- состояния;
- производительности;
- доступности.

# Установка
## Требования
Необходима установка следующих пакетов:
```
 ~# aptitude install fping curl
```
## Настройка
В случае если Yota используется в качестве резервного провайдера, необходимо произвести настройки для направления трафика в этот интерфейс:
```
 ~# echo -e "300\tyota" >> /etc/iproute2/rt_tables
 ~# ip route add 10.0.0.0/24 dev wan1 table yota
 ~# ip route add default via 10.0.0.1 dev wan1 table yota
 ~# ip rule add pref 10000 oif wan1 table yota
```
Также внести их в файл */etc/network/interfaces*, чтобы они применялись после перезагрузки:
```
allow-hotplug wan1
iface wan1 inet static
        address 10.0.0.10
        netmask 255.255.255.0

        post-up ip route add default via 10.0.0.1 dev wan1 metric 1000
        post-up ip route add 10.0.0.0/24 dev wan1 table yota
        post-up ip route add default via 10.0.0.1 dev wan1 table yota
        post-up ip rule add pref 10000 oif wan1 table yota
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Yota/yota.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Yota/yota.pl' && \
chown zabbix yota.pl && chmod 550 yota.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавим хост в темплейт *Template App Yota*.
