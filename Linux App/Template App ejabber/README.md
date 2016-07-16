# Описание
Файл *Template App ejabber.xml* содержит *Template App ejabber*, который состоит в группах *Templates*, *Templates App* и *Templates Custom* и предназначен для мониторинга сериса ejabber.

С использованием данного темплейта осуществляется мониторинг:
- лог-файлов;
- изменения конфигурации;
- версии;
- количества зарегистрированных и онлайн пользователей.

# Установка
```
 ~# cd /etc/zabbix/zabbix_agentd.d && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App ejabber/ejabber.conf'
 ~# cd /usr/lib/zabbix/agentscripts/ && \
wget 'https://raw.githubusercontent.com/kviset/zabbix/master/Linux App/Template App ejabber/ejabber.pl' && \
chown zabbix ejabber.pl && chmod 550 ejabber.pl
 ~# /etc/init.d/zabbix-agent restart
```
Добавим хост в *Template App ejabber*.
