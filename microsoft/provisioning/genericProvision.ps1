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

# If computer already renamed, add to domain. Otherwise, rename it first (used in dual extension execution templates only!)
#if ($env:computername -eq $hostname)
#{
#  do {
#      $failed = $false
#      Try {
#          Write-Host "Adding Computer to Domain.."
#          add-computer -domainname $domain -domaincredential $domaincred -newname $hostname -ErrorAction Stop 
#      } catch { 
#          $failed = $true 
#          Write-Host "Adding Computer to Domain failed, sleeping for 4 seconds.."
#          Write-Output $_.Exception.Message
#          start-Sleep -Seconds 4
#      }
#  } while ($failed)
# 
#  # Make sure domain admins can log in via RDP
#  Add-LocalGroupMember -group "Remote Desktop Users" -member ($domain + "\Domain Admins") | Out-Null
#  shutdown /r /t 03
#}
#else
#{
#  do {
#      $failed = $false
#      Try {
#          Write-Host "Renaming Computer.."
#          rename-computer -newname $hostname -force -PassThru -ErrorAction Stop
#      } catch { 
#          $failed = $true
#          Write-Host "Renaming Computer Failed, sleeping for 4 seconds.(Parameters: hostname: $hostname)"
#          Write-Output $_.Exception.Message
#          start-Sleep -Seconds 4
#      }
#  } while ($failed)
#  cscript c:\windows\system32\slmgr.vbs /rearm
#  shutdown /r /t 03
#}

do {
    $failed = $false
    Try {
        Write-Host "Renaming Computer.."
        rename-computer -newname $hostname -force -PassThru -ErrorAction Stop
    } catch { 
        $failed = $true
        Write-Host "Renaming Computer Failed, sleeping for 4 seconds.(Parameters: hostname: $hostname)"
        Write-Output $_.Exception.Message
        start-Sleep -Seconds 4
    }
} while ($failed)

start-Sleep -Seconds 5

do {
    $failed = $false
    Try {
        Write-Host "Adding Computer to Domain.."
        add-computer -domainname $domain -domaincredential $domaincred -Options JoinWithNewName,AccountCreate -ErrorAction Stop 
    } catch { 
        $failed = $true 
        Write-Host "Adding Computer to Domain failed, sleeping for 4 seconds.."
        Write-Output $_.Exception.Message
        start-Sleep -Seconds 4
    }
} while ($failed)

cscript c:\windows\system32\slmgr.vbs /rearm
shutdown /r /t 03
