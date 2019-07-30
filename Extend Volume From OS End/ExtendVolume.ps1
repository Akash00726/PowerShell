#Name: Script to extend volume on remote host from OS end.
#Author: Akash Saxena
#Version : 1.0
#Step-1: Extract Zip contents in a folder.
#Step-2: Go to that Folder
#Step-3: Put Server Names in ServerList.txt (No header required)
#Step-4: Open Powershell as Administrator
#Step-5: Go To Script Directory
#Step-Run Script as shown below.
#Example : PS C:\Akash\DiskTest> .\ExtendVolume.ps1 -DriveLetter E.
#It will create Outpute.csv as output with final size of Volume.
#Script can be use for bulk number of hosts.
Param(
[Parameter(Mandatory=$true)] [String] $DriveLetter
)
cls
$ErrorActionPreference = "SilentlyContinue"
$username=Read-Host -Prompt "Enter Username[Domain\UserName]"
$pass=Read-Host -AsSecureString "Enter Password"
$Password=[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($pass))
if(Test-Path .\ServerList.txt){
    $servers=Get-Content .\ServerList.txt
    if($servers.Length -gt 0){
    $b=@(
    "rescan"
    "select Volume=$DriveLetter"
    "extend"
    "list volume"
    )
    $b|Set-Content .\Test.txt
    $all=@()
    foreach($server in $servers){
        if(Test-Connection -Count 1 -Server $server -Quiet){
            Write-Host Performing Command Executions on Server $server : Drive $DriveLetter -ForegroundColor Cyan 
                if(Test-Path -Path \\$server\c$\Test.txt ){
                Remove-Item -Path \\$server\c$\Test.txt -Force
                Copy-Item .\Test.txt -Destination \\$server\c$\ -Recurse
                $cmd=& .\PSTools\psexec.exe /accepteula  \\$server -u $username -p $Password -h diskpart.exe /s C:\Test.txt
                $drive=$cmd|Select-String "$DriveLetter" -CaseSensitive
                $drive=$drive -join ""
                $data=""|select Name,DriveDetails
                $data.Name=$server
                $data.DriveDetails=$drive
                $all+=$data
                }else{  Write-Host $server : UNC Path Not Accessible -ForegroundColor Red
                        $data=""|select Name,DriveDetails
                        $data.Name=$server
                        $data.DriveDetails="Path Not Accessible"
                        $all+=$data
                        }
           }else{Write-Host $server : Not Reachable -ForegroundColor Red
                $data=""|select Name,DriveDetails
                $data.Name=$server
                $data.DriveDetails="Not Reachable"
                $all+=$data
                }
        }
    }else{Write-Host ServerList.txt is Empty -ForegroundColor Yellow
        }
}else{Write-Host ServerList.txt Does Not Exist -ForegroundColor Red
    }
$all|Export-Csv .\output.csv -NoTypeInformation