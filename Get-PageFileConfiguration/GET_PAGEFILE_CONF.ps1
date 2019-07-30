<#
.Synopsis
    Powershell Script To Get PAGE FILE Configuration From Remote Servers.
.Description
    Powershell Script To Get PAGE FILE Configuration From Remote Servers.
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
    Example:  PS C:\Test> .\PAGE_FILE_RAM.ps1 -Inputfile ".\server.txt" -OutputFilePath ".\"
    script will create 'Output.csv on given Output file path'
#>  
 
param( 
[Parameter(Mandatory=$true)] $Inputfile, 
[Parameter(Mandatory=$true)] $OutputFilePath 
) 
cls 
$ErrorActionPreference="Silentlycontinue" 
$Path=$OutputFilePath 
$Total=@()
$servers=Get-Content $Inputfile 
$TotalServer=$servers.Count 
$i=1 
foreach($server in $servers){ 

try{
    Write-Progress -Activity "Getting Info Please wait......" -Status "Server $server ($i/$TotalServer)" -PercentComplete ($i/$TotalServer*100) 
    if(Test-Connection -Count 1 -ComputerName $server -Quiet){ 
        $PING="TRUE"
        $RAM=Get-WmiObject -Class Win32_ComputerSystem -Property * -ComputerName $server|%{$_.Properties}
        $PAGEFILE=Get-WmiObject -Class Win32_PageFileSetting -Property * -ComputerName $server |select Name,InitialSize,MaximumSize
        $info=Get-WmiObject -Class win32_logicalDisk -ComputerName $server -Filter "DeviceID='C:'"
        $R=$RAM|?{$_.Name -eq "TotalPhysicalMemory"}|select @{Name='RAM';ex={$_.Value/1GB}}
        $D=$info|select @{Name='DriveLetter';ex={$_.DeviceID}}
        $T=$info|Select @{Name='TotalSize_GB';ex={[math]::Round($_.Size/1GB)}}
        $F=$info|Select @{Name='FreeSpace_GB';ex={[math]::Round($_.FreeSpace/1GB)}}
        $M=$RAM|?{$_.Name -eq "AutomaticManagedPagefile"}|select Value
        $In=$RAM|?{$_.Name -eq "InstallDate"}|select Value
        $i=$i+1 
        $Tout=""|Select SERVERNAME,RAM,DRIVE,TOTALSIZE_GB,FREESPACE_GB,PAGEFILE,PAGEFILEINITIALSIZE,PAGEFILEMAXSIZE,SYSTEMMANAGED,InStallDate,PING   
        $Tout.SERVERNAME=$server
        $Tout.RAM=$($R.RAM)
        $Tout.DRIVE=$($D.DriveLetter) -join ""
        $Tout.TOTALSIZE_GB=$($T.TotalSize_GB) -join ""
        $Tout.FREESPACE_GB=$($F.FreeSpace_GB) -join ""
        $Tout.PAGEFILE=$($PAGEFILE.Name) -join ""
        $Tout.PAGEFILEINITIALSIZE=$($PAGEFILE.InitialSize)
        $Tout.PAGEFILEMAXSIZE=$($PAGEFILE.MaximumSize)
        $Tout.SYSTEMMANAGED=$($M.Value)
        $Tout.InStallDate=$($In.Value)
        $Tout.PING=$PING
        $Total+=$Tout
         
         
              
             }                                                                     
    else{ 
        $PING="FALSE"
        $Tout=""|Select SERVERNAME,RAM,DRIVE,TOTALSIZE_GB,FREESPACE_GB,PAGEFILE,PAGEFILEINITIALSIZE,PAGEFILEMAXSIZE,SYSTEMMANAGED,InStallDate,PING   
        $Tout.SERVERNAME=$server
        $Tout.RAM=""
        $Tout.DRIVE=""
        $Tout.TOTALSIZE_GB=""
        $Tout.FREESPACE_GB=""
        $Tout.PAGEFILE=""
        $Tout.PAGEFILEINITIALSIZE=""
        $Tout.PAGEFILEMAXSIZE=""
        $Tout.SYSTEMMANAGED=""
        $Tout.InStallDate=""
        $Tout.PING=$PING 
        $Total+=$Tout
    } 
   }
   catch{
   
    $Tout=""|Select SERVERNAME,RAM,DRIVE,TOTALSIZE_GB,FREESPACE_GB,PAGEFILE,PAGEFILEINITIALSIZE,PAGEFILEMAXSIZE,SYSTEMMANAGED,InStallDate,PING   
        $Tout.SERVERNAME=$server
        $Tout.RAM=$_.Exception.message
        $Tout.DRIVE=""
        $Tout.TOTALSIZE_GB=""
        $Tout.FREESPACE_GB=""
        $Tout.PAGEFILE=""
        $Tout.PAGEFILEINITIALSIZE=""
        $Tout.PAGEFILEMAXSIZE=""
        $Tout.SYSTEMMANAGED=""
        $Tout.InStallDate=""
        $Tout.PING=$PING 
        $Total+=$Tout
   
   
   
   } 
    
    
    
     
} 
$Total|Export-Csv ./Output.csv -NoTypeInformation
