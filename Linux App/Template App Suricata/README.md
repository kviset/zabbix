# Описание
Файл *Template App Suricata.xml* добавляет темплейт *Template App Suricata*, предназначенный для мониторинга IPS/IDS Suricata. *Template App Suricata* состоит в группах: Templates, Templates App и Templates Custom.

С использованием данного темплейта осуществляется мониторинг:
- производительности;
- количества обнаруженных угроз;

# Установка
## Настройка
Необходимо изменить формат логирования состояния suricata. Для этого откройте файл /etc/suricata/suricata.yaml и исправьте следующую секцию:
```
stats:
  enabled: yes
  interval: 30
<...>
        - stats:
            totals: yes       # stats for all threads merged together
            threads: no       # per thread stats
            deltas: no        # include delta values
```

## Установка

```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Suricata/suricata.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App Suricata/suricata.pl' && \
chown zabbix suricata.pl && chmod 550 suricata.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт Template App Suricata
