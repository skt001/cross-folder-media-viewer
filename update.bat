@echo off
setlocal
cd /d "%~dp0"

echo ====================================
echo  media.json update
echo ====================================
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0update.ps1"
set "RC=%ERRORLEVEL%"

if not "%RC%"=="0" (
    echo.
    echo [ERROR] media.json was not updated. The previous media.json, if any, is unchanged.
    echo   - "running scripts is disabled" or "execution policy": policy on this PC blocks PowerShell scripts.
    echo   - "Access to the path is denied": check write permission for this folder.
    echo   - "powershell is not recognized": Windows PowerShell is missing or not on PATH.
    echo   Details are also written to update.log.
)

echo.
pause
endlocal & exit /b %RC%
