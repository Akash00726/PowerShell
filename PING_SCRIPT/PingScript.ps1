#Ping Script V1
#Author - Akash Saxena
#Steps to use:
#        a]Extract Script into a Directory
#        b]Put all the servers in server.txt
#        c]Open Powershell --> Change directory(Where script stored)
#        d]Now run script as shown below
#               ===>     PS C:\Test> .\PingScript.ps1 -ServerList ".\servers.txt" -OutputPath ".\" 
#        Recommend : put everything in same directory and run script as shown above.
#################################################################################################################         
param(
[String] $ServerList,
[String] $OutputPath)
$Servers=Get-Content $ServerList
foreach($Server in $Servers){
if(Test-Connection $Server -Count 1 -Quiet){
$status='True'
Write-Host $server is Online -ForegroundColor Green
}else{$status='False'
Write-Host $server is Offline -ForegroundColor Red
}
New-Object -TypeName psobject -Property @{
ComputerName=$Server
Status=$status
}|select ComputerName,Status|Export-Csv -Path $OutputPath\pingresult.csv -Append -NoTypeInformation
}