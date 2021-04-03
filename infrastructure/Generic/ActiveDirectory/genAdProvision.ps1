<# 
Preview_20210403
Mostly generic ActiveDirectory provisioining (meant for Atlas, yet recieving arguements that define the domain name).

Will test manual creation of user accounts and adding them to "local administrator" group for all domain memebers.

Parameter $usersCsv is either empty or contains a URL. If it contains a CSV URL (see example below), users will be deployed from CSV. 
Otherwise, users are deployed by parameters (NOT YET IMPLEMENTED).
UsersCsv example: https://raw.githubusercontent.com/cybermias/publicrep/master/infrastructure/Generic/ActiveDirectory/genUserData.csv

*** NOTICE *** - This script works with the old Atlas.Lab snapshot (containing some crap). Future considerations need to regard this
#>

param(
  [String]$domain,
  [String]$usersCsv
)
## Old Atlas.Lab snapshot cleaning and fixing
# Old Atlas.Lab forwards require the Azure forwarder (some Atlas.Lab don't include it for some reason)
Add-DnsServerForwarder -IPAddress 168.63.129.16 -PassThru 
Clear-DnsClientCache
# Remove old objects from AD
Get-ADComputer "WIN7DSKTP" | Remove-ADObject -Recursive -Confirm:$false
#Fixate TimeZone on GMT+2 for now
Set-TimeZone -Id "Middle East Standard Time"


## WinRM, PS-REMOTING and FW considerations (FW is off for the purposes of these experiments)
# Enabling (unsafe at its current implementation, but needed) ps-remoting
Enable-PSRemoting -Force
# Enabling WinRM (consider above comment on remoting)
winrm quickconfig -q
& sc.exe config WinRM start= auto
# Disabling all FW (but adding winrm rule just in case usability requires turning it back on)
Set-NetFirewallRule -Name 'WINRM-HTTP-In-TCP' -RemoteAddress Any -Profile Any
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False


# Creating an OU for joinable computers (started with WEC, but whenever GPO will be relevant, it should probably happen)
# For now a fixed variable is used ($genCompOut) - for Future, input with parameter.
$genCompOu = "ComputersOU"
New-ADOrganizationalUnit -Name $genCompOu
$dc = $domain.split(".")
redircmp "OU=$($genCompOu),DC=$($dc[0]),DC=$($dc[1])"

# Preparing GPO's for stuff (not altering FW on workstations yet allowing domain controller to GP updates). Adding also winrm
New-GPO -Name "Remote Management Automation" -StarterGpoName "Group Policy Remote Update Firewall Ports" | New-GPLink -Target "OU=$($genCompOu),DC=$($dc[0]),DC=$($dc[1])" -LinkEnabled yes

# Creating AD users (if parameters allow this)
if (-Not ($usersCsv -eq $null)) {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  $adUsers = ConvertFrom-CSV (Invoke-WebRequest -uri $usersCsv).ToString()

  $adUsers | ForEach-Object {
      New-ADUser `
          -Name $($_.FirstName + " " + $_.LastName) `
          -GivenName $_.FirstName `
          -DisplayName $($_.FirstName + " " + $_.LastName + $_.Title) `
          -UserPrincipalName $_.UserPrincipalName `
          -SamAccountName $_.SamAccountName `
          -AccountPassword $(ConvertTo-SecureString $_.Password -AsPlainText -Force) `
          -Enabled $True `
          -PasswordNeverExpires $True `
          -ChangePasswordAtLogon $False
  }
}
else {
# If CSV isn't provided - nothing happens. Update with future manual parameters.
}


# Clear some Azure Crap (removed due to "protectedSettings" - will review)
#Remove-Item 'C:\WindowsAzure\Logs\Plugins','C:\WindowsAzure\Logs\AggregateStatus','C:\WindowsAzure\CollectGuestLogsTemp','C:\Packages\Plugins\Microsoft.Compute.CustomScriptExtension' -Force -Confirm:$False -recurse | out-null

# Clear all the relevant logs (old snapshot logs and provisioning-generated logs, so fresh start). Enforcing final Restart.
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
