### VERSION CONTROL: 20210215_Preview
<#
PS1 script to provision Windows10 virtualmachines made with snapshots (specifically "ENVARIO-WIN10ENT-1809-20201126-A0".
 
Script is based on "genericProvision.ps1" script that was created for the Multiple (copyIndex()) win10 hosts in the MACABI environment. It required a $halt variable to avoid conflicting AD-Joining machines.

This version (C2hubCometA1) is mainly used for Dark Comet integration (a more recent version of atlasCommet.ps1) and is based on the "genericProvision" variant.
>#

param(
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

# Add computer to domain after $halt seconds, including new name enforcement under "options".
add-computer -domainname $domain -domaincredential $domaincred -Options JoinWithNewName,AccountCreate -force

# Adding the domain users group to "remote desktop users" - which would allow RDP for domain users (default to "prevent" in used Windows versions)
Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Users") | Out-Null

# Fix evaluation license
cscript c:\windows\system32\slmgr.vbs /rearm

# Clear all the relevant logs (old snapshot logs and provisioning-generated logs, so fresh start). Enforcing final Restart.
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
shutdown /r /t 03
