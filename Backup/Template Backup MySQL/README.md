# Описание
Файл *Template Backup MySQL.xml* содержит *Template Backup MySQL*, который состоит в группах *Templates*, *Templates Backup* и 
*Templates Custom*. *Template Backup MySQL* предназначен для мониторинга резервного копирования и самого резервного копирования 
БД MySQL.

# Установка
## Требования
К хосту должен быть добавлен *Template App MySQL*.

Необходима установка следующих пакетов:
```
 ~# aptitude install cifs-utils
```

## Настройка
Резервное копирование выполняется в общую папку подключенную по протоколу samba.

На сервере резервного копирования заведите "Общую папку" с именем совпадающим с именем сервера. Общая папка может быть скрытой.

На хосте создайте точку монтирования "Общей папки" сервера резервного копирования:
```
~# mkdir /var/backups/remote
```

Создайте файл для хранения аутентификационных данных для выполнения монтирования:
```
 ~# cat > /etc/cifspasswd <<EOL
username=<USERNAME>
password=*********
EOL
 ~# chown 0.0 /etc/cifspasswd
 ~# chmod 600 /etc/cifspasswd
```

Добавим пользователя MySQL для выполнения резервного копирования:
```
 ~# mysql -p
Enter password: 
...
mysql> CREATE USER 'backup'@'localhost' IDENTIFIED BY '********';
Query OK, 0 rows affected (0.02 sec)

mysql> GRANT SELECT, SHOW VIEW, RELOAD, REPLICATION CLIENT, EVENT, TRIGGER ON *.* TO 'backup'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT LOCK TABLES ON *.* TO 'backup'@'localhost';
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW grants FOR backup@localhost;
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Grants for backup@localhost                                                                                                                                                        |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| GRANT SELECT, RELOAD, LOCK TABLES, REPLICATION CLIENT, SHOW VIEW, EVENT, TRIGGER ON *.* TO 'backup'@'localhost' IDENTIFIED BY PASSWORD '*****************************************' |
+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```
Подключите директорию для резервного копирования при помощи команды:
```
 ~# mount.cifs //<BACKUPSERVER>/<HOSTNAME> /var/backups/remote -o uid=0,gid=0,rw,credentials=/etc/cifspasswd
```
Создайте файл /var/backups/remote/.my.cnf следующего содержания:
```
[client]
user=backup
password=********
```
Назначим права доступа к этому файлу:
```
 ~# chmod 400 /var/backups/remote/.my.cnf
```

Настроим запуск скрипта резервного копирования через cron:
```
#Backup mysql db
00 1    * * *   root    /usr/bin/perl /usr/lib/zabbix/backup/backup.mysql.pl
```
Настроим запись логов резервного копирования в отдельный файл:
```
~# cat >/etc/rsyslog.d/backup.mysql.conf <<EOL
if (\$programname == 'backup.mysql') then {
/var/log/zabbix/backup.mysql.log
stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроим ротацию логов:
```
 ~# cat > /etc/logrotate.d/backup.mysql <<EOL
/var/log/zabbix/backup.mysql.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root zabbix
}
EOL
```
## Установка

```
 ~# cd /usr/lib/zabbix/backup/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Backup/Template Backup MySQL/backup.mysql.pl' && \
chmod 550 backup.mysql.pl
```
Отмонтируем диск резервного копирования:
```
 ~# umount /var/backups/remote
```

Откроем файл */usr/lib/zabbix/backup/backup.mysql.pl* и исправим переменную $BACKUPSERVER.

Добавим хост в *Template Backup MySQL*.

## Проверка
```
 ~# /usr/lib/zabbix/backup/backup.mysql.pl 
MySQL Backup start time: 1458550528.8514
Execute 'mount.cifs'. Return: ''
Backup filename: 'week-21-3-2016.sql'
Backup directory '/var/backups/remote//mysql' do not exists. Creating it.
Remove dayly backup: 
Remove weekly backup: 
Remove monthly backup: 
File /tmp/zabbix.1458550528.8498.1582:
"red.github.com" script.mysql.backup.version 1458550529 0.0.5
"red.github.com" script.mysql.backup.starttime 1458550529 1458550528
"red.github.com" script.mysql.backup.size 1458550529 148
"red.github.com" script.mysql.backup.count 1458550529 1
"red.github.com" script.mysql.backup.duration 1458550529 0.235881090164185
"red.github.com" script.mysql.backup.success 1458550529 1
zabbix_sender [1614]: DEBUG: answer [{"response":"success","info":"processed: 6; failed: 0; total: 6; seconds spent: 0.000118"}]\ninfo from server: "processed: 6; failed: 0; total: 6; seconds spent: 0.000118"\nsent: 6; skipped: 0; total: 6\n
```
