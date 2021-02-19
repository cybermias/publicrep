<# 
Whenever, whereever
#>

winrm quickconfig -q
& sc.exe config WinRM start= auto


[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Add-LocalGroupMember -Group "Event Log Readers" -Members $env:ComputerName

Invoke-WebRequest -uri https://raw.githubusercontent.com/cybermias/publicrep/master/microsoft/provisioning/wef/sysmonconfig-export.xml -OutFile sysmonconfig-export.xml

sysmon64.exe -accepteula -i sysmonconfig-export.xml 2>&1 | %{ "$_" }

& wevtutil sl Microsoft-Windows-Sysmon/Operational /ca:"O:BAG:SYD:(A;;0xf0007;;;SY)(A;;0x7;;;BA)(A;;0x1;;;BO)(A;;0x1;;;SO)(A;;0x1;;;S-1-5-32-573)(A;;0x1;;;S-1-5-20)"

restart-service WinRM
