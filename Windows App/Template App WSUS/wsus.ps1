#Template:      Template App WSUS
#Config:        conf.win/wsus.conf
#Place:         C:\Program Files\zabbix\scripts
#Version:       0.0.0


if ($args[0] -eq "unapproved"){
	$result = Get-WsusUpdate -Approval Unapproved  | Measure-Object -Line
	Write-Host $result.Lines
}elseif($args[0] -eq "unassigned"){
	$result = Get-WsusComputer -ComputerTargetGroups "Unassigned Computers"  
	if ($result -eq "No computers available."){
		Write-Host "0"
	}else{
		$result = $result | Measure-Object -Line 
		Write-Host $result.Lines	
	}
}else{
	Write-Host "Usage:"
	Write-Host "wsus.ps1 unapproved - return count unapproved updates"
	Write-Host "wsus.ps1 unassigned - return count unassigned Computers"
}
