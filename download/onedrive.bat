REG add HKCU\SOFTWARE\Microsoft\OneDrive /v DisablePauseOnBatterySaver /t REG_DWORD /d 00000001 /f
REG add HKCU\SOFTWARE\Microsoft\OneDrive /v DisablePauseOnMeteredNetwork /t REG_DWORD /d 00000001 /f
REG add HKCU\SOFTWARE\Microsoft\OneDrive /v DisablePersonalSync /t REG_DWORD /d 00000001 /f
REG add HKCU\SOFTWARE\Microsoft\OneDrive /v EnableAllOcsiClients /t REG_DWORD /d 00000001 /f
del /F /S /Q %localappdata%\Microsoft\Office\16.0\OfficeFileCache\*.*
RMDIR /S /Q %localappdata%\Microsoft\Office\16.0\OfficeFileCache\
mkdir %localappdata%\Microsoft\Office\16.0\OfficeFileCache\
%localappdata%\Microsoft\OneDrive\OneDrive.exe /background
