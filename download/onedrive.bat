REG add HKCU\SOFTWARE\Microsoft\OneDrive /v DisablePauseOnBatterySaver /t REG_DWORD /d 00000001 /f
REG add HKCU\SOFTWARE\Microsoft\OneDrive /v DisablePauseOnMeteredNetwork /t REG_DWORD /d 00000001 /f
REG add HKCU\SOFTWARE\Microsoft\OneDrive /v DisablePersonalSync /t REG_DWORD /d 00000001 /f
REG add HKCU\SOFTWARE\Microsoft\OneDrive /v EnableAllOcsiClients /t REG_DWORD /d 00000001 /f
%localappdata%\Microsoft\OneDrive\OneDrive.exe /background
