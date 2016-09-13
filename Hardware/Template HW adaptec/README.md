# Описание

Файл *Template HW adaptec.xml* добавляет *Template HW adaptec*, предназначенный для мониторинга Adaptec RAID Controller на ОС Linux.

*Template HW adaptec* состоит в группах: *Templates*, *Templates Hardware* и *Templates Custom*.

*Template HW adaptec* производит автоматический поиск доступных контроллеров и добавляет соответствующие итемы и триггеры в систему мониторинга 
zabbix. Использование данного темплейта возможно только на физических серверах.

*Template HW adaptec* производит мониторинг:
 - Модели, серийного номера и версий прошивок;
 - температуры;
 - состояния контроллера и логических дисков;

# Установка
## Требования
```
zsender.pl версии не ниже 0.3.9
```
Необходимо установить утилиту конфигурирования RAID от adaptec. 

Для контроллера ASR71605E утилиту можно найти по ссылке: http://adaptec.com/en-us/speed/raid/storage_manager/arcconf_v2_01_22270_zip.php

Распаковываем загруженный архив и копируем файл linux_x64/cmdline/arcconf в директорию /sbin.

Для проверки выполним команду arcconf:
```
 ~# arcconf GETCONFIG 1
Controllers found: 1
----------------------------------------------------------------------
Controller information
----------------------------------------------------------------------
   Controller Status                        : Optimal
   Controller Mode                          : RAID (Expose RAW)
   Channel description                      : SAS/SATA
   Controller Model                         : Adaptec ASR71605E
...
```
## Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW adaptec/adaptec.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Hardware/Template HW adaptec/adaptec.pl' && \
chown zabbix adaptec.pl && chmod 550 adaptec.pl
 ~# /etc/init.d/zabbix-agent restart
```

Добавьте хост в темплейт *Template HW adaptec*

