### VERSION CONTROL: 20210126_preview
#
# PS1 script to provision Windows10 virtualmachines made with snapshots (specifically "ENVARIO-WIN10ENT-1809-20201126-A0".
# 
# Script will accept arguements (from calling templates) according to their respected names. Arguements are used to auto-provision OS parameters.
#
# Lessons Learned:
# - Azure doesn't yet support multiple extension scripts of the same type for Windows OS (Can't call two different provision scripts, if Restart is needed)
# - "add-domain" may not function properly in "race-conditions" which are definitely possible. Since snapshots are used, all VM's of the same snapshot have the same
#   hostname upon deployment. If script is run exactly the same time, renaming a computer and adding to domain may introduce conflicts (domain is busy, thus it simply
#   hangs. Various versions were examined (including "try/catch/do/while". Conflics re-occured and the chosen method was the following LL.
# - When deploying multiple VM of the same snapshot (using the copy() feature) - a "waiting timer" is assigned to this script ($halt) via linear time addition based on 
#   VM last IP octat (10,11,12,... with additional waiting time of 3 seconds).
# - When DC add a VM before rename restart occurs, even if proper "options" value is used in "add-domain", DC is probably first adding the machine with "old" name and takes
#   a few seconds before it properly updates. Race-Conditions may result in conflict for adding consecutive machines of the same snapshot - so sleep-timer is introducted.
#
# Implemented Provisioning Concepts:
# - Restart computer is done after all relevant actions, including name change and domain addition.
# - VM is added to domain after some sleep time (to avoid parameters that havn't changed in VM, and allowing DC to "enforce" new name.
#
###

param(
  [String]$halt,
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$hostname
)

# Define PSCredential variables following input from arguments (Domain and Local)
#   First credentials refer to local user configured in snapshot
#   Second credentials refer to domain admin.
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd

# Shift pagefile to the temporary drive (just in case - if its not embedded in the snapshot)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force

# Rename computer without restart, and sleep just in case renaming requires some seconds seconds to "temporary" enforce. Also contributes to DC race-conditions.
#   Not the "best" alternative - Requires additional SYSTEM investigation on this.
Rename-Computer -NewName $hostname
start-sleep -seconds $halt
#start-sleep -seconds 5 //Old (yet additional) timer used in first succesful attempts. May not be needed.

# Add computer to domain after $halt seconds, including new name enforcement under "options".
add-computer -domainname $domain -domaincredential $domaincred -Options JoinWithNewName,AccountCreate -force

# Adding the domain users group to "remote desktop users" - which would allow RDP for domain users (default to "prevent" in used Windows versions)
Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Users") | Out-Null

# Fix evaluation license
cscript c:\windows\system32\slmgr.vbs /rearm

# Clear all the relevant logs (old snapshot logs and provisioning-generated logs, so fresh start). Enforcing final Restart.
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
shutdown /r /t 03
