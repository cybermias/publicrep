### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$hostname
)

### Still missing in current build
#   Condition the following functions: Domain add, Computer rename, PSCredential creation, RAT addons, Evaluation rearm
#
###
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }

# Define PSCredential variables following input from arguments (Domain and Local)
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd

# Add the computer to a domain (if available)

$success = $null
do {
        $joined = $true
        try {
            add-computer -domainname $domain -domaincredential $domaincred -ErrorAction Stop
            $success = $true
        } catch {
            Start-Sleep -Seconds 2
        }
}until ( $success)

# Shift pagefile to the temporary drive (just in case)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force

# Rename the computer according to the Arguments
# For some reason rename-computer finishes with no errors, but it doesn't enforce

$success = $null
do {
        try {
            rename-computer -newname $hostname -force -PassThru -ErrorAction Stop -DomainCredential $domaincred -ErrorAction Stop
            $success = $true
        } catch {
            Start-Sleep -Seconds 2
        }
}until ($success)

$success = $null
do {
        try {
            Add-LocalGroupMember -group "Remote Desktop Users" -member $domAdminUsr -ErrorAction Stop
            $success = $true
        } catch {
            Start-Sleep -Seconds 2
        }
}until ($success)


cscript c:\windows\system32\slmgr.vbs /rearm
shutdown /r /t 03
