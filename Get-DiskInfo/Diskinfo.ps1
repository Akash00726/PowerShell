<###################################################
  Author:  Akash Saxena 
  Email:   saxena00726@gmail.com
  Version: 1.0 
####################################################> 

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
        $Type=Get-WmiObject -Class Win32_ComputerSystem -ComputerName $server|select Manufacturer
        $hash = @{
                2="Removable disk"
                3="Fixed local disk"
                4="Network disk"
                5="Compact disk"}
        $info=Get-WmiObject -Class win32_logicalDisk -ComputerName $server|select @{Name='ServerName';ex={$_.PSComputerName}},@{Name='DriveLetter';ex={$_.DeviceID}},@{LABEL='DriveType';EXPRESSION={$hash.item([int]$_.DriveType)}},@{Name='DriveLabel';ex={$_.VolumeName}},@{Name='TotalSize_GB';ex={[math]::Round($_.Size/1GB)}},@{Name='FreeSpace_GB';ex={[math]::Round($_.FreeSpace/1GB)}},@{Name='SystemType';ex={$Type.Manufacturer}}
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
Write-Host Script Execution Completed Completed -ForegroundColor Green