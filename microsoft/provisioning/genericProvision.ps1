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



# Shift pagefile to the temporary drive (just in case)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force


# Add the computer to a domain (if available)

do {
    $failed = $false
    Try {
        Write-Host "Adding Computer to Domain.."
        add-computer -domainname $domain -domaincredential $domaincred -ErrorAction Stop 
    } catch { 
        $failed = $true 
        Write-Host "Adding Computer to Domain failed, sleeping for 4 seconds.."
        Write-Output $_.Exception.Message
        start-Sleep -Seconds 4
    }
} while ($failed)

start-Sleep -Seconds 5
Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Admins") | Out-Null

# Rename the computer according to the Arguments
# For some reason rename-computer finishes with no errors, but it doesn't enforce
do {
    $failed = $false
    Try {
        Write-Host "Renaming Computer.."
        rename-computer -newname $hostname -force -PassThru -DomainCredential $domaincred -ErrorAction Stop
    } catch { 
        $failed = $true
        Write-Host "Renaming Computer Failed, sleeping for 4 seconds.(Parameters: hostname: $hostname, domaincred: $domaincred)"
        Write-Output $_.Exception.Message
        start-Sleep -Seconds 4
    }
} while ($failed)

Write-Host "All Variables used are: $domaincred ; $hostname ;
cscript c:\windows\system32\slmgr.vbs /rearm
shutdown /r /t 03
