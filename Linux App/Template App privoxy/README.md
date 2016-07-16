# Описание
Файл *Template App privoxy.xml* содержит *Template App Privoxy*, который состоит в группах *Templates*, *Templates App* и 
*Templates Custom* и предназначен для мониторинга privoxy.

*Template App Privoxy* осуществляет мониторинг:
- запущенности процесса;
- лог-файлов;
- версии и контрольной суммы;
- изменения конфигурации.

# Установка
## Настройка
Откройте файл */etc/privoxy/config* и раскомментируйте следующие строки:
```
debug  4096 # Startup banner and warnings
debug  8192 # Non-fatal errors 
```
Перезапустите privoxy

## Установка

Добавьте хост в *Template App Privoxy*
