
cscript c:\windows\system32\slmgr.vbs /rearm

REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "D:\pagefile.sys 0 0" /f
