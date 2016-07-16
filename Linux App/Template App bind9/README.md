# Описание

Файл *Template App bind9* добавляет темплейты *Template App bind9* и *Template App bind9 - log*, которые состоят в группах: *Templates*, *Templates App* и *Templates Custom*.

*Template App bind9* - предназначен для мониторинга и сбора статистики с сервиса named.

*Template App bind9 - log* - предназначен для мониторинга лог-файлов bind9.

С использованием данных темплейтов осуществляется мониторинг:
- производительности;
- файлов логов;
- состояния порта;
- запущенности процесса;
- версии и контрольной суммы bind;
- изменения конфигурации.

# Установка
## Требования

Необходима установка следующих пакетов:
```
aptitude install xml2 curl libdatetime-locale-perl
```

## Настройка

Откроем файл */etc/bind/named.conf.options* и добавим следующие строки:
```
statistics-channels {
     inet 127.0.0.1 port 8053 allow { 127.0.0.1; };
};

logging {
        channel syslog {
                syslog daemon;
                severity info;
                print-category yes;
        };

        category default { syslog; };
        category queries { syslog; };
};

controls {
        inet 127.0.0.1 allow { localhost; };
};
```
Добавим разрешающее правило в фаервол:
```
 ~# iptables -A INPUT -s 127.0.0.1/32 -p tcp -m state --state NEW -m tcp --dport 8053 -j ACCEPT
 ~# /etc/init.d/netfilter-persistent save
```
Перезапустим bind:
```
 ~# /etc/init.d/bind9 restart
[ ok ] Restarting bind9 (via systemctl): bind9.service.
```
Проверим работоспособность:
```
 ~# curl -s http://localhost:8053/ 2>/dev/null | xml2 | grep -A1 -E 'queries|=Qry'
...
```
Настроем rsyslog для сохранение логов bind в отдельный файл. Для этого выполним следующие команды:
```
 ~# echo "if \$programname == 'named' then /var/log/named.log" > /etc/rsyslog.d/named.conf
 ~# echo "if \$programname == 'named' then stop" >> /etc/rsyslog.d/named.conf
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
 ~# 
```
Откройте файл /etc/logrotate.d/rsyslog и добавьте следующую строку в начале файла:
```
/var/log/named.log
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App bind9/bind.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App bind9/bind.pl' && \
chown zabbix bind.pl && chmod 550 bind.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавим хост в *Tempalte App bind9* и *Template App bind9 - log*
