'Template: Templane OS Windows local
'Config:  conf.win/windows.conf

Set updateSession = CreateObject("Microsoft.Update.Session")
Set updateSearcher = updateSession.CreateupdateSearcher()
Set searchResult = updateSearcher.Search("")
wscript.echo searchResult.Updates.Count

