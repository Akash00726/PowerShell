<#
Author:Akash Saxena
Version: 2.0
###################################
Step-1: Go to Script Path & put VM names in file servers.txt file and Vcenter servers in Vcenter.txt.

Step-2: Open latest version of PowerCLI i.e. v10 with Admin privilage.

After that Please follow the below process -
 
1) 	Select option 12 before starting VMware Tools upgrade process it will gather IMP data e.g. VM Name, Tools Version status(if upgrade Current or upgrade is needed), Tools version, ToolsUpgradePolicy(Manual or UpgradeAtPowerCycle), PowerState, NIC, NIC Type, VLAN, MAC, IP, VM Hardware Version

2) 	In Prep-work results & if found "isolation.tools.autoInstall.disable" set as True on any VM/VM's, then use option 5 in script to set this option to False.
   
	Note - Above steps can be executed in advance i.e. day before activity to same time on execution date.
	
3) 	Open VMware PowerCLI with Admin privileges enter option 12 to gather Pre activity VM details(e.g. VM name, VMware Tools Status, Tools Version, VM Hardware version, How many NIC's VM has, Vlan details, IP Details, MAC details)
4) 	Once Pre activity data is gathered, now select option 4 this will check mark option 'Check & upgrade VMware Tools before each Power ON' for VM present in servers.txt file.

                  5) Now select option 0 which will Shutdown VM's gracefully which are present in servers.txt file.
				  
6) 	Wait for 10 to 15 Mins & check VM's are Shutdown by selecting option 7 to find VM PowerState.

7) 	After waiting PowerON VM's using option 1 & once VM's will comes online, it automatically upgrade VMware Tools & reboot VM's.

8) 	Now select option 13, which will fetch latest VM's Tools details & confirm all VM's VMware Tools have been upgraded successfully.

9) 	Once confirmed VMware Tools have been upgraded, now we will again shutdown VM's to upgrade VM Hardware version to v13.

10)	Now again select option 0 to Shutdown VM's gracefully & wait for 10 to 15 Mins & confirm VM's are Shutdown by selecting option 7 to find VM PowerState.

11) Once VM's confirmed to be shutdown select option 3 which will upgrade VM's Hardware version to v13.

12) Monitor the progress in script & once Hardware version has been upgraded successfully, select option 9 which will fetch latest VM's Hardware version details & confirm all VM's Hardware version upgraded successfully.

13) Once confirmed VM Hardware version has been upgraded, select option 1, which will PowerON VM's.

14) After 10 to 15 Mins select option 7 to check if VM's came back online.
#####################################

#>

cls
Function Choice{
Write-Host ""
Write-Host "PLEASE ENTER YOUR CHOICE FROM BELOW MENU" -ForegroundColor Green
Write-Host "===========================================================================" -ForegroundColor Magenta 
Write-Host ""
Write-Host " [0]:  To Shutdown VMs " -ForegroundColor Cyan 
Write-Host " [1]:  To PowerON VMs " -ForegroundColor Cyan
Write-Host " [2]:  To Reboot VMs " -ForegroundColor Cyan
Write-Host " [3]:  To Change HW Version " -ForegroundColor Cyan
Write-Host " [4]:  To Change Upgrade Policy " -ForegroundColor Cyan
Write-Host " [5]:  To VM TOOLS (Enable-AUTOINSTALL) " -ForegroundColor Cyan
Write-Host " [6]:  To VM TOOLS (Disable-AUTOINSTALL) " -ForegroundColor Cyan
Write-Host " [7]:  To Find VM Powerstate " -ForegroundColor Cyan  
Write-Host " [8]:  To Find Uptime of VMs " -ForegroundColor Cyan
Write-Host " [9]:  To Find Hardware version of VMs " -ForegroundColor Cyan
Write-Host " [10]: To Find VMtools Upgrade policy of VMs " -ForegroundColor Cyan
Write-Host " [11]: To Find VM TOOLS AUTOINSTALL status (Enabled or Disabled) " -ForegroundColor Cyan
Write-Host " [12]: To Export VM and IP configuration Pre Or Post check " -ForegroundColor Cyan
Write-Host " [13]: To Export Network Pre Or Post configuration " -ForegroundColor Cyan
Write-Host " [14]: To Find VM Tools Version and Running status " -ForegroundColor Cyan
Write-Host " [15]: To EXIT " -ForegroundColor RED
Write-Host ""
$result = switch (Read-Host "Please Enter Your Choice")
{
0 {Shutdown}
1 {PowerON}
2 {Reboot}
3 {ChangeHWVersion}
4 {ToolsUpgradePolicy}
5 {EnableAutoinstallOption}
6 {DisableAutoinstallOption}
7 {VerifyPowerstate}
8 {VMuptime}
9 {VerifyHWVersion}
10 {VerifyupgradePolicy}
11 {VerifyAutoinstallOption}
12 {PrePostcheck}
13 {Pre_Network_Configuration}
14 {ToolsVersion}
15 {Disconnect}
default { 'Invalid Choice !' }
}
}
Function Shutdown{
$a=Get-Date
Write-Warning " YOU HAVE CHOOSED OPTION 0:ALL THE INSCOPE VM's WILL BE SHUTDOWN. "
pause
foreach($VM in $VMs){
Write-Host Shutting down $VM -ForegroundColor Green
Shutdown-VMGuest -VM $VM -Confirm:$false -Verbose
}
Write-Host PLEASE WAIT FOR 1 MINUTE, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 60
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Yellow
Choice
}
Function VerifyPowerstate{
$a=Get-Date
foreach($VM in $VMs){
Write-Host Checking power state of $VM -ForegroundColor Green
Get-VM -Name $VM|Select Name,Powerstate|Export-Csv -Path $path\Powerstate.csv -Append -NoTypeInformation -Verbose
}
Write-Host "Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP...DUMPING $path\Powerstate.csv" -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Yellow
Choice
}
Function PowerON{
$a=Get-Date
Write-Warning " YOU HAVE CHOOSED OPTION 1:ALL THE INSCOPE VM's WILL BE PowerUP. "
pause
foreach($VM in $VMs){
Write-Host Powering ON $VM -ForegroundColor Green
Start-VM $VM -Confirm:$false -RunAsync -Verbose
}
Write-Host PLEASE WAIT FOR 1 MINUTE, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 60
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Yellow
Choice
}
Function Reboot{
Write-Warning " YOU HAVE CHOOSED OPTION 2:ALL THE INSCOPE VM's WILL BE REBOOT. "
pause
$a=Get-Date
foreach($VM in $VMs){
Write-Host Rebooting $VM -ForegroundColor Green
Restart-VMGuest -VM $VM -Confirm:$false 
}
Write-Host PLEASE WAIT FOR 1 MINUTE, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 60
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Yellow
Choice
}
Function VMuptime{
$a=Get-Date
Write-Host Getting Uptime ... Green
foreach($VM in $VMs){
$up=Get-Stat -Entity $VM -Stat sys.uptime.latest -Realtime -MaxSamples 1
$uptime=New-TimeSpan -Seconds $up.Value
Write-Host $VM ----- $($uptime.Days) Days,$($uptime.Hours) Hours, $($uptime.Minutes) Minutes -ForegroundColor Green
Add-Content $path\uptime.txt " $VM -- $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes" 
}
Write-Host PLEASE WAIT FOR 1 MINUTE, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 60
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function PrePostcheck{
$a=Get-Date
foreach($VM in $VMs){
$count=$Count+1
Write-Host "Gathering Info from $VM || VM serial number in Server list is : $count" -ForegroundColor DarkGreen
Get-VM -name $VM|get-view|Select @{N=”VM Name”;E={$_.Name}},@{Name=”VMware Tools”;E={$_.Guest.ToolsStatus}},@{Name=”Folder”;E={(Get-VM -Name $VM).Folder.Name}},@{Name=”ToolsVersionstatus”;E={$_.Guest.ToolsVersionStatus}},@{Name=”ToolsRunningStatus”;E={$_.Guest.toolsRunningStatus}},@{Name=”ToolsVersion”;E={$_.Guest.ToolsVersion}},@{Name='ToolsUpgradePolicy';exp={(get-vm -name $VM).ExtensionData.Config.Tools.ToolsUpgradePolicy}},@{Name=”PowerState”;E={(Get-VM -Name $VM).Powerstate}},@{Name=”Network Adapter IPs”;E={(Get-VM -Name $VM).Guest.IPAddress}},@{Name=”UUID”;E={Get-VM $VM|%{(Get-View $_.Id).config.uuid}}},@{Name=”OS Name”;E={(Get-VM -Name $VM).Guest.OSFullName}},@{Name="HW Version";expression={$_.config.version}},@{Name="Tools_Autoinstall_Disable";expression={(Get-AdvancedSetting -Entity $VM -Name isolation.tools.autoInstall.disable).value}}|Export-Csv $path\Pre_Post_Check.csv -NoTypeInformation -Append
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function ToolsVersion{
$a=Get-Date
Write-Host Gathering Tools Version Info Please wait..... -ForegroundColor Green
foreach($VM in $VMs){
Get-VM -name $VM|get-view|Select Name,@{Name=”ToolsVersion”;E={$_.Guest.ToolsVersion}},@{Name=”ToolsRunningStatus”;E={$_.Guest.toolsRunningStatus}}|Export-Csv $path\VMtoolsversion.csv -Append -NoTypeInformation -Verbose
}
Write-Host PLEASE WAIT FOR 10 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 10
Write-Host Current operation Completed successfully -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function ChangeHWVersion{
$a=Get-Date
Write-Warning " YOU HAVE CHOOSED OPTION 3:THIS OPTION WILL CHANGE THE H/W VERSION. "
pause
$Hw=Read-Host "Enter HW Version"
Write-Host Changing HW version to $Hw -ForegroundColor Green
foreach($VM in $VMs){
Set-VM -VM $vm -Version $Hw -Confirm:$false -Verbose
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function VerifyHWVersion{
$a=Get-Date
Write-Host Getting HW version.... -ForegroundColor Green
foreach($VM in $VMs){
Get-VM -name $VM|get-view|select  @{N=”VM Name”;E={$_.Name}},@{Name="HW Version";expression={$_.config.version}}|Export-Csv -Path $path\HWversion.csv -Append -NoTypeInformation -Verbose
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host  DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function EnableAutoinstallOption{
Write-Warning " YOU HAVE CHOOSED OPTION 5 "
pause
$a=Get-Date
Write-Host Enabling AutoinstallOption....  -ForegroundColor Green
foreach($VM in $VMs){
New-AdvancedSetting -Entity $VM -Name isolation.tools.autoInstall.disable -value $false -force -Confirm:$false -Verbose
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function DisableAutoinstallOption{
Write-Warning " YOU HAVE CHOOSED OPTION 6:"
pause
$a=Get-Date
Write-Host Disbaling AutoinstallOption....  -ForegroundColor Green
foreach($VM in $VMs){
New-AdvancedSetting -Entity $VM -Name isolation.tools.autoInstall.disable -value $True -force -Confirm:$false -Verbose
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function VerifyAutoinstallOption{
$a=Get-Date
Write-Host Getting VMtools Autoinstall Option value....  -ForegroundColor Green
foreach($VM in $VMs){
Get-AdvancedSetting -Entity $VM -Name isolation.tools.autoInstall.disable|select Entity,Value|Export-Csv -Path $path\ToolsAutoinstall.csv -Append -NoTypeInformation -Verbose
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function ToolsUpgradePolicy{
Write-Warning " YOU HAVE CHOOSED OPTION 4:THIS OPTION WILL CHANGE THE TOOLS UPGRADE POLICY. "
pause
Write-Host Choose Policy..... -ForegroundColor Green
Write-Host " 1 :To 'Manual'" -ForegroundColor Yellow
Write-Host " 2 :To 'UpgradeAtPowerCycle'" -ForegroundColor Yellow
Write-Host ""
Write-Host ""
switch(Read-Host “Please enter the choice”)
{
1{$policy='Manual'}
2{$policy='UpgradeAtPowerCycle'}
default { 'Invalid Choice !' }

}
$a=Get-Date
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vmConfigSpec.Tools = New-Object VMware.Vim.ToolsConfigInfo
$vmConfigSpec.Tools.ToolsUpgradePolicy = "$policy"
Write-Host Upgrading Policy to $policy
foreach($VM in $VMs){
Get-VM -Name $VM | % { (Get-View $_.ID).ReconfigVM($vmConfigSpec)} -Verbose
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE!! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function VerifyupgradePolicy{
$a=Get-Date
Write-Host Getting VMware tools upgrade policy....  -ForegroundColor Green
foreach($VM in $VMs){
$pV=get-vm -name $VM
$pv|select name,@{Name='ToolsUpgradePolicy';exp={($pV).ExtensionData.Config.Tools.ToolsUpgradePolicy}}|Export-Csv -Path $path\upgradepolicy.csv -Append -NoTypeInformation -Verbose
}
Write-Host PLEASE WAIT FOR 20 SECONDS, FINISHING UP..... -ForegroundColor Yellow
Start-Sleep -s 20
Write-Host DONE !! -ForegroundColor Green
$b=Get-Date
$c=$b-$a
Write-host Time taken for $VMs.count Host is $c.Minutes Minutes and $c.Seconds Seconds -ForegroundColor Cyan
Choice
}
Function Pre_Network_Configuration{
ForEach($VM in $VMs) {
$NICs = Get-NetworkAdapter -VM $VM
$VMName = $VM
ForEach ($NIC in $NICs) {
$NICName = $NIC.Name
$PortKey = $NIC.ExtensionData.Backing.Port.PortKey
$OnStartConnect=$NIC.ExtensionData.Connectable.StartConnected
$Connected=$NIC.ExtensionData.Connectable.Connected
$Status=$NIC.ExtensionData.Connectable.Status
$Line = "$VMName | $($NICName) | $($PortKey) | $($NIC.NetworkName)"
New-Object -TypeName psobject -Property @{
VMname=$VMName
NICName=$($NICName)
PortID=$($PortKey)
VLAN=$($NIC.NetworkName)
MAC=$($NIC.MacAddress)
OnStartConnect=$($OnStartConnect)
Connected=$($Connected)
Status=$($Status)}|select VMname,NICName,PortID,VLAN,TempVLAN,MAC,OnStartConnect,Connected,Status|Export-Csv $path\PreNetwokConfig.csv -Append -NoTypeInformation
Write-Host $Line -ForegroundColor Cyan
                }
}
choice
}

function Disconnect{
Write-Host "DISCONNECTING FROM VCENTERS....." -ForegroundColor Green
Disconnect-VIServer -Server * -Confirm:$false
Start-Sleep -Seconds 5
Exit
}
$path="."
$vcenters = Get-Content $path\vcenter.txt 
$VMs=Get-Content $path\servers.txt
$user=Read-Host -Prompt "Enter Username"
$pass=Read-Host -AsSecureString "Enter Password"
$username = $user
Write-Host HELLO $username -ForegroundColor Green
Write-Host "===========================================================================" -ForegroundColor Magenta 
Write-Host ""
Write-Host BELOW ARE THE IN-SCOPE VMs -ForegroundColor Green
$VMs
Write-Host "===========================================================================" -ForegroundColor Magenta 
Write-Host ""
Write-Host BELOW ARE THE VCENTERS IN LIST -ForegroundColor Green
$vcenters
Write-Host "===========================================================================" -ForegroundColor Magenta 
$mycreds = New-Object System.Management.Automation.PSCredential ("$username",$pass)
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -confirm:$false -Scope Session -DefaultVIServerMode Multiple|Out-Null
Write-host CONNECTING TO VCENTERS... -ForegroundColor Green
foreach($vcen in $vcenters){
Connect-ViServer  -Server $vcen -Credential $mycreds -SaveCredentials -Verbose
}
Choice
