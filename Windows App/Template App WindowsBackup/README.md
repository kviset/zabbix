# Описание
Файл *Template App WindowsBackup.xml* содержит *Template App WindowsBackup*, который состоит в группах *Templates*, *Templates App* и *Templates Custom*.
*Template App WindowsBackup* предназначен для мониторинга процесса резервного копирования встроенной системы Резервного копирования Windows.

## Макросы

*Template App WindowsBackup* содержит следующий макрос:
```text
{$WINBACKUPTIMEOUT} => 7d
```
Который предназначен для регулирования триггера невыполнения резервного копирования в течение заданного промежутка времени.

# Установка
- Установите роль Windows Server Backup.
- Создайте резервное копирование.
- Добавьте хост в темплейт *Template App WindowsBackup*
- Импортируйте таски *ZabbixAgent_BackupAttention.xml*, *ZabbixAgent_BackupCompleted.xml* и *ZabbixAgent_BackupStarted.xml* в TaskSheduler.
