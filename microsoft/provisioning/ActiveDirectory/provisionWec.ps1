<# 
Following WEC/WEF definitions, a script is needed.
#>

param(
  [String]$domain
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

sysmon64.exe -accepteula -i 2>&1 | %{ "$_" }

Invoke-WebRequest -uri https://raw.githubusercontent.com/OTRF/Blacksmith/master/resources/configs/wef/subscriptions/sysmon.xml -outfile sysmon.xml

& wecutil cs sysmon.xml
& wecutil qc /quiet
Restart-Service wecsvc

# Altering the default domain policy (as my attempts to create a new policy and enforce it went to valhalla. Apperantly, the default policy already has a misconfigured SubscriptionManager without the "Server=" element in it)
Set-GPRegistryValue -Name "Default Domain Policy" -Key "HKLM\Software\Policies\Microsoft\Windows\EventLog\EventForwarding\SubscriptionManager" -ValueName 1 -Type String -Value "Server=http://$($fqdn):5985/wsman/SubscriptionManager/WEC,Refresh=60"




