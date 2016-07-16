# Описание
Файл *Template App WSUS.xml* добавляет Template App WSUS, который состоит в группах: *Templates*, *Templates App* и *Templates Custom*.

*Template App WSUS*  предназначен для мониторинга работы WSUS. Осуществляется мониторинг следующих параметров:
- запущенность сервиса;
- наличие unapproved updates;
- наличие unassigned computers;

# Установка

Скопируйте файл *wsus.ps1* в директорию *C:\Program Files\zabbix\scripts\*.

Скопируйте файл *wsus.conf* в директорию *C:\Program Files\zabbix\conf.d\*.

Перезапустите сервис zabbix-agent.

Для проверка работоспособности скрипта запустите *cmd* от имени администратра и выполните следующие команды:
```
C:\Windows\system32>powershell.exe -File "C:\Program Files\zabbix\scripts\wsus.ps1" unapproved
0
C:\Windows\system32>powershell.exe -File "C:\Program Files\zabbix\scripts\wsus.ps1" unassigned
6
```
