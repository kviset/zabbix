# Описание
Файл *Template App RDP.xml* содержит темплейт *Template App RDP*, который состоит в группах *Templates*, *Templates App* и *Templates Custom*. 
И предназначен для мониторинга событий Remote Desktop Services Windows.

*Template App RDP* осуществляет мониторинг:
- журнала событий Windows, извлекает из него события AppLocker и генерирует предупреждения в случае обнаружения событий с ошибками;
- состояние сервиса AppIDSvc;
- счетчики производительности.

# Установка

Добавьте хост в темплейт *Template App RDP*
