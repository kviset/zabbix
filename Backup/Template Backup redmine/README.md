# Описание
Файл *Template Backup redmine.xml* содержит *Template Backup redmine*, который состоит в группах *Templates*, *Templates Backup* и *Templates Custom*. 
*Template Backup mediawiki* Предназначен для мониторинга резервного копирования и самого резервного копирования загружаемых файлов redmine.

# Установка
## Требования
```
zsender.pl версии не ниже 0.3.3
```
Для установки zsender.pl воспользуйтесь [инструкцией](https://github.com/kviset/zabbix/tree/master/Linux%20App).

К хосту должен быть добавлен *Template App redmine*.

Необходима установка следующих пакетов:
```
 ~# aptitude install cifs-utils
```

## Настройка
Резервное копирование выполняется на общую папку, подключенную по протоколу samba.

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

Настроим запуск скрипта резервного копирования через cron:
```
#Backup redmine files
30 0    * * 7   root    /usr/bin/perl /usr/lib/zabbix/backup/backup.redmine.pl
```
Настроим запись логов резервного копирования в отдельный файл:
```
~# cat >/etc/rsyslog.d/backup.redmine.conf <<EOL
if (\$programname == 'backup.redmine') then {
/var/log/zabbix/backup.redmine.log
stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроим ротацию логов:
```
 ~# cat > /etc/logrotate.d/backup.redmine <<EOL
/var/log/zabbix/backup.redmine.log {
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
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Backup/Template Backup redmine/backup.redmine.pl' && \
chmod 550 backup.redmine.pl
```

Откроем файл */usr/lib/zabbix/backup/backup.redmine.pl* и исправим переменную $BACKUPSERVER.

Добавим хост в *Template Backup redmine*.
