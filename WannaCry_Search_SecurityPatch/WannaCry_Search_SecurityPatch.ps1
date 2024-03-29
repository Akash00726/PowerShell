<#
Author: Akash Saxena
version: 1
POWERSHELL SCRIPT TO FIND UNPATCHED MACHINES AND CAN BE USE FOR WANNACRY SECURITY PATCHES.

How to use--

1-Extract the script in a directory
2-Put all the Server names in server.txt (no header required)
3-Open PowerShell as Admin.
4-Change to Script directory.
5-Run the script like below.
    For Single patch(KBID) = PS C:\PatchScript> .\WannaCry_Patch_Search.ps1 -KBID kb4093114
    For Multiple patches(KBIDs) = PS C:\PatchScript> .\WannaCry_Patch_Search.ps1 -KBID kb4093114,kb4093115,kb4093116,kb4093117
6-Script will create below 3 Outputs--
    a]patched.csv ----Contains the list of servers who are patched against given KBIDs
    b]NotPatched.txt----Contains name of servers that are not patched against given KBIDs
    c]log.txt---If any server not reachable.
#>
Param(
[Parameter(Mandatory=$true)] [String[]] $KBID
)
$ErrorActionPreference="SilentlyContinue"
$Servers = Get-Content ".\Servers.txt"
$ids = $KBID
Write-Host GETTING DATA.... -ForegroundColor Cyan
foreach($Server in $servers){
       $i=0
       if(Test-Connection -Count 1 $Server -Quiet)
                {  
                    foreach($id in $ids){
                                            Write-Host Searching for $id in $Server  -ForegroundColor DarkGreen
                                            $v = Get-HotFix -Id $id -ComputerName $Server
                                            while($v){
                                                        $v| select CSName,HotFixID,InstalledBy,InstalledOn|export-csv .\Patched.csv -Append -NoTypeInformation
                                                        Write-Host $id FOUND IN $Server  -ForegroundColor Green
                                                        $i=$i+1
                                                        break
                                                     }
                                        }
                    Write-Host $i Patch found on $Server -ForegroundColor Green
                    if($i -eq 0){
                                    Add-Content -Path .\Not_Patched.txt "$server NOT PATCHED"
                                }      
                }
       else {
                   Add-Content .\log.txt "$Server NOT REACHABLE"
                   Write-Host $Server NOT REACHABLE -ForegroundColor Red
            }
  }
  Write-Host SEARCH HAS BEEN COMPLETED -ForegroundColor Cyan