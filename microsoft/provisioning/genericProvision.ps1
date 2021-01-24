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

do {
        $joined = $true
        try {
            add-computer -domainname $domain -domaincredential $domaincred
        } catch {
            $joined = $false
            Start-Sleep -Seconds 1
        }
}until ($joined)

# Shift pagefile to the temporary drive (just in case)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force

# Rename the computer according to the Arguments
# For some reason rename-computer finishes with no errors, but it doesn't enforce

do {
        $renamed = $true
        try {
            rename-computer -newname $hostname -force -PassThru -ErrorAction Stop -DomainCredential $domaincred
        } catch {
            $renamed = $false
            Start-Sleep -Seconds 1
        }
}until ($renamed)
do {
        $added = $true
        try {
            Add-LocalGroupMember -group "Remote Desktop Users" -member $domAdminUsr
        } catch {
            $added = $false
            Start-Sleep -Seconds 1
        }
}until ($added)


cscript c:\windows\system32\slmgr.vbs /rearm
shutdown /r /t 03
