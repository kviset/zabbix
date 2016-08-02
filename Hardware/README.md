# Настройка IPMI на ОС Debian==

При установке zabbix-server на ОС Debian возникает проблема с использованием IPMI. Это вызвано тем что пакет openipmi собран без поддержки openssl и rpath. Для того что бы это исправить следуйте инструкции.

Для того что бы zabbix-server поддерживал мониторинг через IPMI необходимо установить следующие пакеты:
```
 ~# aptitude install ipmitool dpkg-dev debhelper libsnmp-dev libpopt-dev libncurses5-dev chrpath autotools-dev libgdbm-dev
```

Так как в дистрибьютиве Debian пакет openipmi собирается без поддержки openssl, то нам необходимо пересобрать этот пакет с поддержко openssl. Для этого необходимо выполнить следующую последовательность команд:
```
 ~# mkdir /usr/src/openipmi && cd /usr/src/openipmi
 ...# apt-get source openipmi
 ...# cd openipmi-2*
```

Откроем файл *debian/rules* и ичправем внем строку *--without-openssl* на *--with-openssl* и удалим параметр *--disable-rpath*
```
 ...# dpkg-buildpackage
 ...# cd ..
 ...# dpkg -i openipmi*.deb libopenipmi*.deb
```

Отключим обновление данных пакетов, что бы случайно не переустановить их:
```
 ~# echo "openipmi hold" | dpkg --set-selections && \
 echo "libopenipmi0 hold" | dpkg --set-selections && \
 echo "libopenipmi-dev hold" | dpkg --set-selections
```
Перезапустим zabbix-server:
```
 ~# /etc/init.d/zabbix-server restart
[ ok ] Stopping Zabbix server: zabbix_server.
[ ok ] Starting Zabbix server: zabbix_server.
```

Откройте файл */etc/zabbix/zabbix_server.conf* и исправте следующий параметр:
```
StartIPMIPollers=3
```

