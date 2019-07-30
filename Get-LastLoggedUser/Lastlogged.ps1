
#Written By Akash Saxena
#Version V1
#Put all the servers in text file.
#Go to the directory of script.
#Example- PS C:\Test_lastlogged> .\Script.ps1 -InputFilePath ".\server.txt" -OutputPath ".\" 

param(
[Parameter(Mandatory=$true)] $OutputPath,
[Parameter(Mandatory=$true)] $InputfilePath
)
$D=Get-Date -Format "dd-MMM-yyyy_hh_mm_ss"
cls
$Servers=Get-Content $InputfilePath
foreach($Server in $Servers){
    if(Test-Connection $Server -Count 1 -Quiet)
        {
            if(Test-Path -Path \\$server\c$\Users){
                Write-Host Getting Details from $Server ..... -ForegroundColor DarkGreen
                Get-ChildItem \\$server\c$\Users|sort LastWriteTime -Descending|select $Server, LastWriteTime , Name|Out-File -FilePath "$OutputPath\Output_$D.txt" -Append
                Write-Host DONE!!!!!! -ForegroundColor Green
                }
            else{
                Add-Content $OutputPath\log.txt "$server path not accesseble"
                Write-Host path not accesseble for $server 
            }
        }
    else{
            Add-Content $OutputPath\log.txt "$server not Reachable"
            Write-Host $server not Reachable
    }
    }