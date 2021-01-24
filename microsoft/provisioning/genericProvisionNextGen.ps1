### Basic non-Parameterized ps1 script to allow introduction of various limited-provisioning commands to Windows 10
param(
  [String]$state,
  [String]$defAdminUsr, 
  [String]$defAdminPwd,
  [String]$domain,
  [String]$domAdminUsr,
  [String]$domAdminPwd,
  [String]$hostname
)

### 
# This script takes a new method of provisioning according to conditioning set by the JSON tempate.
# Since it was created to accomodate Macabi / Cyber Control requirements from 20210123 of 7 Workstations added to domain
# - The main issue initially was that each of these workstations is based on a snapshot (and already has a machine name "WIN10DSKTP"). 
#   However, rename-computer *requires* restart before add-domain. And restart isn't supported in Azure Extension. Any other non-restart
#   alternative didn't work properly (and god I tried).
# - DSC Was not examined yet. Preferable solution was to create two different extensions to run one after the other.
#
# In this script we embrace a new concept of "state". Provided from the JSON template, we require a "state" value according to this list:
# - "init" - Initial non-internet / non-network requiring initializations (change computer name, change registry, make FS changes, etc)
# - "advanced" - Post-Initial provisioning that may require internet / network connectivtiy (i.e non-configured Checkpoint may cause issues here)
#   Notice we already have a solution for that situation with *routing* pre-deployment configurations (two consecutive deployments).
# - "domain" - Provision according to some domain configurations
###


if ($state -eq "init")
{
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
  
  # Rename the computer
  rename-computer -newname $hostname -force -PassThru
  
  # Shift pagefile to the temporary drive (just in case)
  new-itemproperty -path "hklm:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -name PagingFiles -propertytype MultiString -value "D:\pagefile.sys" -force

  # Fix evaluation license
  cscript c:\windows\system32\slmgr.vbs /rearm
  
  $restartRequired = "yes"
}


if ($state -eq "domain")
{
  # Add computer to domain (after succesfully changing computer name *AND* init-extension restart
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
  
  Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Users") | Out-Null
  
  $restartRequired = "yes"
}


# Repeating activtiy through any kind of initialization
Get-EventLog -LogName * | ForEach { Clear-EventLog $_.Log }

if ($restartRequired -eq "yes")
{
  shutdown /r /t 03
}

### TRASH / ARCHIVE
#Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" 
#Remove-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" 
#Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\Computername" -name "Computername" -value $hostname
#Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\Computername\ActiveComputername" -name "Computername" -value $hostname
#Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "Hostname" -value $hostname
#Set-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -name "NV Hostname" -value  $hostname
#Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "AltDefaultDomainName" -value $hostname
#Set-ItemProperty -path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -name "DefaultDomainName" -value $hostname
