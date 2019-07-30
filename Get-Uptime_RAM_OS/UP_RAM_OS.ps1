<#
.Synopsis
    Powershell Script To Get Uptime,RAM and OS Details From Remote Servers.
.Description
    Powershell Script To Get Uptime,RAM and OS Details From Remote Servers.
    Author:  Akash Saxena  
    Email:   saxena00726@gmail.com 
    Version: 1.0
.Parameter
    Inputfile (Mandatory)
    OutputFilePath (Mandatory)
.Example
    Extract the script in directory.
    Create a input text file containing list of Servers. (does not require any header)
    Open Powershell and change directory to script directory
    Run the script as below
    Example:  PS C:\Test_lastlogged> .\UP_RAM_OS.ps1 -Inputfile ".\server.txt" -OutputFilePath ".\"
    script will create 'Output.csv on given Output file path'
#>  
 
param( 
[Parameter(Mandatory=$true)] $Inputfile, 
[Parameter(Mandatory=$true)] $OutputFilePath 
) 
cls 
$ErrorActionPreference="Silentlycontinue" 
$Path=$OutputFilePath 
$a=(Get-Date).Millisecond 
$servers=Get-Content $Inputfile 
$TotalServer=$servers.Count 
$i=1 
foreach($server in $servers){ 
    Write-Progress -Activity "Getting Info Please wait......" -Status "Server $server ($i/$TotalServer)" -PercentComplete ($i/$TotalServer*100) 
    if(Test-Connection -Count 1 -ComputerName $server -Quiet){ 
        $Type=Get-WmiObject -Class Win32_ComputerSystem -ComputerName $server
        $sysinfo=Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server
        $Lastboot = $sysinfo.LastBootUpTime
        $boot=[System.Management.ManagementDateTimeconverter]::ToDateTime($Lastboot)
        $final=((Get-Date)-$boot)
        $Uptime = $final.Days
        $info=Get-WmiObject -Class Win32_ComputerSystem -ComputerName $server|select @{Name='ServerName';ex={$_.PSComputerName}},@{Name='RAM';ex={$_.TotalPhysicalMemory/1GB}},@{Name='OperatingSystem';ex={$sysinfo.Caption}},@{Name='Uptime_Days';ex={$Uptime}}
                    if(!$info){
                           Write-Warning "RPC error with $server"
                           $i=$i+1
                           Add-Content $Path\error_log.txt "RPC error with $server" 
                        }
                   else{
                        $i=$i+1
                        $info|Export-Csv -Path $Path\Output.csv -Append -NoTypeInformation
                    } 
             }                                                                     
    else{ 
    Write-Host $server is Offline -ForegroundColor Red 
    Add-Content $Path\error_log.txt "$server is Offline" 
    }  
} 
Write-Host Script Execution Completed -ForegroundColor Green