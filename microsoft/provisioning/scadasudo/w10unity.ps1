### Preview (20210504 - ScadaSudo Preview of WIN10 for Unity Pro XL13)

# Not using domain, simple singlevm environment

### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$hostname
)
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

### Still missing in current build
#   Condition the following functions: Domain add, Computer rename, PSCredential creation, RAT addons, Evaluation rearm
#
###

# Define PSCredential variables following input from arguments (Domain and Local)
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

# Rename the computer according to the Arguments
rename-computer -newname $hostname -LocalCredential $localcred -force -PassThru 

cscript c:\windows\system32\slmgr.vbs /rearm
optimize-volume c -verbose

Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
wevtutil el | Foreach-Object {wevtutil cl $_}

shutdown /r /t 03
