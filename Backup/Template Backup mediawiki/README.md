# Описание
Файл *Template Backup mediawiki.xml* содержит *Template Backup mediawiki*, который состоит в группах *Templates*, *Templates Backup* 
и *Templates Custom*. *Template Backup mediawiki* Предназначен для мониторинга резервного копирования и самого резервного копирования
загружаемых файлов mediawiki.

# Установка
## Требования
К хосту должен быть добавлен *Template App mediawiki*.

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
#Backup mediawiki files
30 0    * * 7   root    /usr/bin/perl /usr/lib/zabbix/backup/backup.mediawiki.pl
```
Настроим запись логов резервного копирования в отдельный файл:
```
 ~# cat >/etc/rsyslog.d/backup.mediawiki.conf <<EOL
if (\$programname == 'backup.mediawiki') then {
/var/log/zabbix/backup.mediawiki.log
stop
}
EOL
 ~# /etc/init.d/rsyslog restart
[ ok ] Restarting rsyslog (via systemctl): rsyslog.service.
```
Настроим ротацию логов:
```
 ~# cat > /etc/logrotate.d/backup.mediawiki <<EOL
/var/log/zabbix/backup.mediawiki.log {
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
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Backup/Template Backup mediawiki/backup.mediawiki.pl' && \
chmod 550 backup.mediawiki.pl
```

Откроем файл */usr/lib/zabbix/backup/backup.mediawiki.pl* и исправим переменную $BACKUPSERVER.

Добавим хост в *Template Backup mediawiki*.
