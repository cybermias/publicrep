
cscript c:\windows\system32\slmgr.vbs /rearm

REG add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "D:\pagefile.sys 0 0" /f

wget https://github.com/cybermias/publicrep/raw/master/microsoft/digital_forensics.jpg -O c:\windows\system32\wallpaper.jpg

reg add "HKEY_CURRENT_USER\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d c:\windows\system32\wallpaper.jpg /f
Start-Sleep -s 2
rundll32.exe user32.dll, UpdatePerUserSystemParameters, 0, $false

shutdown /r /t 02
