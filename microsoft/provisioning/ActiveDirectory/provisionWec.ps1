<# 
Following WEC/WEF definitions, a script is needed.
#>

param(
  [String]$domain,
  [String]$splunkip,
  [String]$splunkport
)

# Old Atlas.Lab forwards require the Azure forwarder (issues with 9.9.9.9 not accepting some lousy bashupload.com translation)
Add-DnsServerForwarder -IPAddress 168.63.129.16 -PassThru 
Clear-DnsClientCache

# Unfortunately, add-computer doesn't create an OU for computers (and default domain adding doesn't put a computer inside an OU). GPO will fail.

New-ADOrganizationalUnit -Name "ComputersOU"
$dc = $domain.split(".")
redircmp "OU=ComputersOU,DC=$($dc[0]),DC=$($dc[1])"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet -Force
Install-Module xWindowsEventForwarding -Force -Confirm:$False -SkipPublisherCheck
winrm quickconfig -q
winrm quickconfig -transport:http
& sc.exe config WinRM start= auto

$collector = $env:ComputerName
$fqdn = $collector+"."+$domain

# Making sure the collector (AD) himself is reporting too
Invoke-WebRequest -uri https://raw.githubusercontent.com/cybermias/publicrep/master/microsoft/provisioning/wef/sysmonconfig-export.xml -OutFile sysmonconfig-export.xml
sysmon64.exe -accepteula -i sysmonconfig-export.xml 2>&1 | %{ "$_" }
& wevtutil sl Microsoft-Windows-Sysmon/Operational /ca:"O:BAG:SYD:(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x1;;;BO)(A;;0x1;;;SO)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20)"
#sysmon64.exe -accepteula -i 2>&1 | %{ "$_" }

Invoke-WebRequest -uri https://raw.githubusercontent.com/cybermias/publicrep/master/microsoft/provisioning/sysmon/sysmon.xml -outfile sysmon.xml

& wecutil cs sysmon.xml
& wecutil qc /quiet
Restart-Service wecsvc

# Altering the default domain policy (as my attempts to create a new policy and enforce it went to valhalla. Apperantly, the default policy already has a misconfigured SubscriptionManager without the "Server=" element in it)
Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\Software\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager" -ValueName 1 -Type String -Value "Server=http://$($fqdn):5985/wsman/SubscriptionManager/WEC,Refresh=60"

# Install nxlog and fix nxlog.conf
$nxpath = "C:\Program Files (x86)\nxlog\conf\nxlog.conf"
Invoke-WebRequest -uri https://github.com/cybermias/publicrep/raw/master/microsoft/provisioning/ActiveDirectory/nxlog/nxlog-ce-2.10.2150.msi -outfile nxlog.msi
Start-Process msiexec '/i nxlog.msi /quiet' -Wait 
start-sleep -s 5 # Needs to validate if "-wait" will wait util file is downloaded. Just in case for now.
Remove-Item $nxpath | out-null
Invoke-WebRequest -uri https://raw.githubusercontent.com/cybermias/publicrep/master/microsoft/provisioning/ActiveDirectory/nxlog/nxlog.conf -outfile $nxpath
start-sleep -s 2 # Replace with "-wait" or other prettier alternatives (in the future) to make sure nxlog.conf is downloaded
((Get-Content -path $nxpath -Raw) -replace '@HOST@',$splunkip) | Set-Content -Path $nxpath
((Get-Content -path $nxpath -Raw) -replace '@PORT@',$splunkport) | Set-Content -Path $nxpath
Start-Service -Name nxlog

# Clear some Azure Crap
#Remove-Item 'C:\WindowsAzure\Logs\Plugins','C:\WindowsAzure\Logs\AggregateStatus','C:\WindowsAzure\CollectGuestLogsTemp','C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension' -Force -Confirm:$False -recurse | out-null

# Clear all the relevant logs (old snapshot logs and provisioning-generated logs, so fresh start). Enforcing final Restart.
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
