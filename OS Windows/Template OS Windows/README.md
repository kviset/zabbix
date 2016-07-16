# Описание

Файл *Template OS Windows.xml* добавляет два темплейта: Template OS Windows public и Template OS Windows private, который состоит в группах: *Templates*, *Templates OS* и *Templates Custom*.

*Template OS Windows public* - предназначен для хранения общих итемов и триггеров. Наследует Template OS Windows.

*Template OS Windows private* - предназначен для хранения итемов и триггеров  Вашей инфраструктуры. Наследует Template OS Windows public. Так же в этом темплейте можно производить модификации (включения/отключения) итемов и тригеров темплейтов Template OS Windows public и Template OS Windows.

Данное разделение выполнено с целью упрощения механизма обновления темплейтов.

С использованием данного темплейта осуществляется мониторинг:
- производительности ОС;
- основных events;
- не установленных обновлений и необходимости перезагрузки ОС.

# Установка

Скопируйте файлы *getnumupdates.vbs* и *rebootrequest.vbs*  в директорию *C:\Program Files\zabbix\scripts*.

Скопируйте файл *windows.conf* в директорию *C:\Program Files\zabbix\conf.d*.

Перезапустите сервис zabbix-agent.

Добавляем хост в темплейт *Template OS Windows private*.
