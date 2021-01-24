### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$halt,
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$hostname
)

### 
#
#
#
###


# Define PSCredential variables following input from arguments (Domain and Local)
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd


# Shift pagefile to the temporary drive (just in case)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force

start-sleep -seconds $halt
do {
    $failed = $false
    Try {
        Write-Host "Adding Computer to Domain.."
        add-computer -domainname $domain -domaincredential $domaincred -newname $hostname -force -ErrorAction Stop 
    } catch { 
        $failed = $true 
        Write-Host "Adding Computer to Domain failed, sleeping for 4 seconds.."
        Write-Output $_.Exception.Message
        start-Sleep -Seconds 5
    }
} while ($failed)

Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Users") | Out-Null
# Fix evaluation license
cscript c:\windows\system32\slmgr.vbs /rearm

}


if ($state -eq "domain")
{
  # Add computer to domain (after succesfully changing computer name *AND* init-extension restart

  
  
  
  $restartRequired = "yes"
}


# Repeating activtiy through any kind of initialization
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }

if ($restartRequired -eq "yes")
{
  shutdown /r /t 03
}

### TRASH / ARCHIVE

