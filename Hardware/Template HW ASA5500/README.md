# Описание
Файл *Template HW ASA5500.xml* содержит темплейт *Template HW ASA5500*, который состоит в группах *Templates*, *Templates Hardware* и *Templates Custom*. 
И предназначен для мониторинга фаервола Cisco ASA серии 5500 по протоколу SNMP.

*Template HW ASA5500* осуществляет мониторинг:
- счетчиков интерфойсов;
- времени работы;
- датчиков работоспособности(по температуре, БП, вентиляторов);
- использование памяти;
- использование ЦПУ
- Серийного номера, версии прошивки;
- количества VPN тунелей.

Темплейт создан на основе [source](https://share.zabbix.com/network_devices/cisco/cisco-asa-discovery/visit)

## Макросы

При использовании данного темплейта рекомендуется глобально установить макрос
```text
{$SNMP_COMMUNITY}	⇒	community_name
```

# Установка
## Настройка
Подключитесь к ASA через ssh и выполните следующие команды:
```
ASA(config)# snmp-server enable
ASA(config)# snmp-server host inside 10.1.1.100 community somesecretword version 2c
ASA(config)# snmp-server community somesecretword
ASA(config)# snmp-server enable traps snmp authentication linkup linkdown coldstart
```

Для настройки удаленного логирования выполните следующие команды:
```
ASA(config)# logging enable
ASA(config)# logging timestamp
ASA(config)# logging buffered informational
ASA(config)# logging trap informational
ASA(config)# logging facility 17
ASA(config)# logging host inside 192.168.1.5

``

Не забудте сохранить конфигурацию.
```
ASA(config)# write
```
## Установка
Добавьте хост в темплейт *Template HW ASA5500*
