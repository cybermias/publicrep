### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$halt,
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$hostname
)

### 
#
#
#
###


# Define PSCredential variables following input from arguments (Domain and Local)
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd

Rename-Computer -NewName $hostname
start-sleep -seconds $halt

# Shift pagefile to the temporary drive (just in case)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force

start-sleep -seconds $halt

add-computer -domainname $domain -domaincredential $domaincred -Options JoinWithNewName,AccountCreate -force


Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Users") | Out-Null
# Fix evaluation license
cscript c:\windows\system32\slmgr.vbs /rearm

# Repeating activtiy through any kind of initialization
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
shutdown /r /t 03

### TRASH / ARCHIVE
#do {
#    $failed = $false
#    Try {
#        Write-Host "Adding Computer to Domain.."
#        add-computer -domainname $domain -domaincredential $domaincred -Options JoinWithNewName,AccountCreate -force -ErrorAction Stop 
#    } catch { 
#        $failed = $true 
#        Write-Output $_.Exception.Message
#        start-Sleep -Seconds 3
#    }
#} while ($failed)
