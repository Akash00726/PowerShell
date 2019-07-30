<# 
.Synopsis 
    Powershell Script To Get NETSTAT Output with Process Name From Remote Servers. 
.Description 
    Powershell Script To Get NETSTAT Output with Process Name From Remote Servers. 
    Author:  Akash Saxena   
    Email:   saxena00726@gmail.com  
    Version: 1.0 
.Parameter 
    N/A 
.Example 
    Extract the script in directory. 
    Put list of Servers in Servers.txt. (does not require any header) 
    Open Powershell and change directory to script directory 
    Run the script as below 
    Example:  PS C:\Test> .\PORT_INFO.PS1 
    script will create 'Port_Info_Output.csv' in Script Directory. 
#>   
function Get-PortStatus 
{
$Path="."
$username=Read-Host -Prompt "Enter Username"
$pass=Read-Host -AsSecureString "Enter Password"
$Password=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
$servers=Get-Content ".\Servers.txt"
foreach($server in $servers){
    &{ .\psexec.exe /accepteula  \\$server -u $username -p $Password -h netstat.exe -ano}| Select-String -Pattern ‘\s+(TCP|UDP)’ | ForEach-Object {

        $item = $_.line.split(” “,[System.StringSplitOptions]::RemoveEmptyEntries)

        if($item[1] -notmatch ‘^\[::’) 
        {            
            if (($la = $item[1] -as [ipaddress]).AddressFamily -eq ‘InterNetworkV6’) 
            { 
               $localAddress = $la.IPAddressToString 
               $localPort = $item[1].split(‘\]:’)[-1] 
            } 
            else 
            { 
                $localAddress = $item[1].split(‘:’)[0] 
                $localPort = $item[1].split(‘:’)[-1] 
            } 

            if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq ‘InterNetworkV6’) 
            { 
               $remoteAddress = $ra.IPAddressToString 
               $remotePort = $item[2].split(‘\]:’)[-1] 
            } 
            else 
            { 
               $remoteAddress = $item[2].split(‘:’)[0] 
               $remotePort = $item[2].split(‘:’)[-1] 
            } 

            New-Object PSObject -Property @{ 
                Server=$server
                PID = $item[-1] 
                ProcessName = (Get-Process -Id $item[-1] -ComputerName $server -ErrorAction SilentlyContinue).Name 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress =$remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq ‘tcp’) {$item[3]} else {$null} 
            } | Select-Object Server,Protocol,LocalAddress,LocalPort,RemoteAddress,RemotePort,State,ProcessName,PID|Export-Csv ./Port_Info_Output.csv -Append -NoTypeInformation
        } 
    } 
}
}
Get-PortStatus