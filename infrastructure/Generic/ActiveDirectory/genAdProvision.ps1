<# 
Preview_20210403
Mostly generic ActiveDirectory provisioining (meant for Atlas, yet recieving arguements that define the domain name).

Will test manual creation of user accounts and adding them to "local administrator" group for all domain memebers.
#>

param(
  [String]$domain
)

# Old Atlas.Lab forwards require the Azure forwarder (some Atlas.Lab don't include it for some reason)
Add-DnsServerForwarder -IPAddress 168.63.129.16 -PassThru 
Clear-DnsClientCache

# Clear some Azure Crap (removed due to "protectedSettings" - will review)
#Remove-Item 'C:\WindowsAzure\Logs\Plugins','C:\WindowsAzure\Logs\AggregateStatus','C:\WindowsAzure\CollectGuestLogsTemp','C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension' -Force -Confirm:$False -recurse | out-null

# Clear all the relevant logs (old snapshot logs and provisioning-generated logs, so fresh start). Enforcing final Restart.
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
