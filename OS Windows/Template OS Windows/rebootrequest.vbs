'Template: Templane OS Windows local
'Config:  conf.win/windows.conf

Set objSysInfo = CreateObject("Microsoft.Update.SystemInfo")

if objSysInfo.RebootRequired then
 Wscript.Echo "1"
else
 Wscript.Echo "0"
end if
