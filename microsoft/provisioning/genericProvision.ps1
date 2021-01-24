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

# Define PSCredential variables following input from arguments (Domain and Local)
$temppwd = ConvertTo-SecureString -String $defAdminPwd -AsPlainText -Force
$localcred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $defAdminUsr,$temppwd

$temppwd = ConvertTo-SecureString -String $domAdminPwd -AsPlainText -Force
$domaincred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($domain + "\" + $domAdminUsr),$temppwd

# Force change computer name without a restart (rename computer including some registry changes)
#do {
#    $failed = $false
#    Try {
#        Write-Host "Renaming Computer.."
#        rename-computer -newname $hostname -force -PassThru -ErrorAction Stop
#    } catch { 
#        $failed = $true
#        Write-Host "Renaming Computer Failed, sleeping for 4 seconds.(Parameters: hostname: $hostname)"
#        Write-Output $_.Exception.Message
#        start-Sleep -Seconds 4
#    }
#} while ($failed)

Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" 
Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" 
Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\Computername" -name "Computername" -value $hostname
Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\ActiveComputername" -name "Computername" -value $hostname
Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" -value $hostname
Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" -value  $hostname
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "AltDefaultDomainName" -value $hostname
Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "DefaultDomainName" -value $hostname

rename-computer -newname $hostname -force -PassThru
start-Sleep -Seconds 5

# Add computer to domain (after succesfully changing computer name *AND* avoiding restart
do {
    $failed = $false
    Try {
        Write-Host "Adding Computer to Domain.."
        add-computer -domainname $domain -domaincredential $domaincred -force -ErrorAction Stop 
    } catch { 
        $failed = $true 
        Write-Host "Adding Computer to Domain failed, sleeping for 4 seconds.."
        Write-Output $_.Exception.Message
        start-Sleep -Seconds 5
    }
} while ($failed)

# Allow all Domain user accounts remote (RDP) access to machines
Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Users") | Out-Null

# Shift pagefile to the temporary drive (just in case)
new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force

# Restore Evaluation License
cscript c:\windows\system32\slmgr.vbs /rearm

# Remove all Log files (Starting fresh!) and restart
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }
shutdown /r /t 03
