<#
.Synopsis  
    Powershell Script To Get Service Status From Remote Servers.  
.Description  
    Powershell Script To Get Service Status From Remote Servers. 
    Author:  Akash Saxena    
    Email:   saxena00726@gmail.com   
    Version: 1.0  
.Parameter  
    ServerList (Mandatory)  
    ServiceName (Mandatory)  
.Example  
    Extract the script in directory.  
    Create a input text file containing list of Servers. (does not require any header)  
    Open Powershell and change directory to script directory  
    Run the script as below. 
    Execute script like Below- 
        Example:  PS C:\Test_lastlogged> .\Script.ps1 -ServiceName "SplunkForwarder" -ServerList Server.txt 
    
    script would create 'Output.csv .  
#>

param(
[Parameter(mandatory=$true)] [String[]] $ServiceName,
[Parameter(mandatory=$true)] [String] $ServerList
)
$TotalOut=@()
$Servers= Get-Content $ServerList
foreach($Server in $Servers){
try{
    if(Test-Connection -ComputerName $Server -Count 1 -Quiet){
        $Ping="True"
        foreach($Service in $ServiceName ){
            $Serviceout=Get-WmiObject -Class Win32_Service -ComputerName $Server|?{$_.Name -eq $Service}|select PSComputerName,name,StartMode,State,Status
            $Serviceout
            $Serv=""|Select ServerName,Ping,ServiceName,StartMode,State,Status
            $Serv.ServerName=$Server
            $Serv.Ping=$Ping
            $Serv.ServiceName=$Serviceout.name
            $Serv.StartMode=$Serviceout.StartMode
            $Serv.State=$Serviceout.State
            $Serv.Status=$Serviceout.Status
            $TotalOut+=$Serv
            }
    }
    else{
            $Ping="False"
            $Serv=""|Select ServerName,Ping,ServiceName,StartMode,State,Status
            $Serv.Ping=$Ping
            $Serv.ServerName=""
            $Serv.ServiceName=""
            $Serv.StartMode=""
            $Serv.State=""
            $Serv.Status=""
            $TotalOut+=$Serv
            }
}
catch{
            $Serv=""|Select ServerName,Ping,ServiceName,StartMode,State,Status
            $Serv.Ping=$Ping
            $Serv.ServerName=$_
            $Serv.ServiceName=""
            $Serv.StartMode=""
            $Serv.State=""
            $Serv.Status=""
            $TotalOut+=$Serv
            }
}
$TotalOut|Export-Csv Output.csv -NoTypeInformation -Force