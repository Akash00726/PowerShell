<# 
.Synopsis 
    Powershell Script To Get Disk SCSI Target ID,SCSI BUS,DISK Letter,DISK SIZE,FREE SPACE From Remote Servers. 
.Description 
    Powershell Script To Get Disk SCSI Target ID,SCSI BUS,DISK Letter,DISK SIZE,FREE SPACE From Remote Servers.
    Author:  Akash Saxena   
    Email:   saxena00726@gmail.com  
    Version: 1.0 
.Parameter 
    ServerList (Mandatory) 
    DriveLetter 
.Example 
    Extract the script in directory. 
    Create a input text file containing list of Servers. (does not require any header) 
    Open Powershell and change directory to script directory 
    Run the script as below.
    For All drive execute script like Below-
        Example:  PS C:\Test_lastlogged> .\targetID.ps1 -ServerList ".\server.txt"
    For specific drive execute script like below-
        Example:  PS C:\Test_lastlogged> .\targetID.ps1 -ServerList ".\server.txt" -DriveLetter E:
    script would create 'DiskReport.csv and Log.txt 
#>   
param(
[Parameter (Mandatory = $true)] [String] $ServerList,
[Parameter (Mandatory = $false)] [String] $DriveLetter='*'
)
$Pinc=1
Function Get-DiskTargetID{
$ComputerName=Get-Content $ServerList
$TCount=$ComputerName.count
$DeviceID=$DriveLetter
    if ($ComputerName)
    {foreach ($Computer in $ComputerName) {
        Get-Progress -Computer $Computer -Increament $Pinc -ToCount $TCount
        $Pinc=$Pinc+1
      try {$Parameters = @{
            ComputerName = $Computer
           }
        if (Test-Connection -ComputerName $Computer -Count 1 -Quiet)     
        { $Win32_LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk @Parameters|Where-Object {$_.DeviceID -like $DeviceID}
          $Win32_LogicalDiskToPartition = Get-WmiObject -Class Win32_LogicalDiskToPartition @Parameters
          $Win32_DiskDriveToDiskPartition = Get-WmiObject -Class Win32_DiskDriveToDiskPartition @Parameters
          $Win32_DiskDrive = Get-WmiObject -Class Win32_DiskDrive @Parameters
          $Win32_LogicalDisk|%{
              if($_)
              {
                $LogicalDisk = $_
                $LogicalDiskToPartition = $Win32_LogicalDiskToPartition|Where-Object {$_.Dependent -eq $LogicalDisk.Path}
                if ($LogicalDiskToPartition)
                {
                  $DiskDriveToDiskPartition = $Win32_DiskDriveToDiskPartition|Where-Object {$_.Dependent -eq $LogicalDiskToPartition.Antecedent}
                  if ($DiskDriveToDiskPartition)
                  {
                    $DiskDrive = $Win32_DiskDrive|Where-Object {$_.__Path -eq $DiskDriveToDiskPartition.Antecedent}
                    if ($DiskDrive)
                    {
                      
                        New-Object -TypeName PSObject -Property @{
                        Computer = $Computer
                        DeviceID = $LogicalDisk.DeviceID
                        DriveLabel =$LogicalDisk.VolumeName
                        TotalSize_GB = [math]::Round($LogicalDisk.Size/1GB)
                        FreeSpace_GB = [math]::Round($LogicalDisk.FreeSpace/1GB)
                        SCSIBus = $DiskDrive.SCSIBus
                        SCSIPort = $DiskDrive.SCSIPort
                        SCSITargetId = $DiskDrive.SCSITargetId
                   
                      }|select Computer,DeviceID,DriveLabel,TotalSize_GB,FreeSpace_GB,SCSIBus,SCSIPort,SCSITargetId|Export-Csv .\DiskReport.csv -Append -NoTypeInformation
                    }
                  }
                }
              }
            }
          }
          else
          {
            Write-host "NOT ABLE TO CONNECT $Computer." -ForegroundColor Red
            Add-Content .\Log.txt "NOT ABLE TO CONNECT WITH || $Computer"
          }
        }
        catch {
          Write-Host "Unable to get disk information for computer $Computer.`n$($_.Exception.Message)" -ForegroundColor Red
          Add-Content .\Log.txt "Unable to get disk information for computer|| $Computer.`n$($_.Exception.Message)"
        }
      }
    }
}
Function Get-Progress($Computer,$Increament,$ToCount){
Write-Progress -Activity "Getting Info Please wait......" -Status "Server $Computer ($Increament/$ToCount)" -PercentComplete ($Increament/$ToCount*100)
}
if(Test-Path ./LOG.txt){Remove-Item ./LOG.txt -Force}
if(Test-Path ./DiskReport.csv){Remove-Item ./DiskReport.csv -Force}
Get-DiskTargetID