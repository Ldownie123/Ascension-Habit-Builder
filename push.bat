@echo off
setlocal enabledelayedexpansion
REM push.bat - Simplified Git push workflow for iOS project
REM Usage: push.bat (run from project root in Command Prompt or PowerShell)

echo [PUSHING] Staging all changes...
git add .
if errorlevel 1 (
    echo.
    echo [ERROR] git add failed
    echo.
    pause
    exit /b 1
)

REM Build commit message from staged files
set "msg=update "
set "has_files=0"
for /f "delims=" %%f in ('git diff --cached --name-only 2^>nul') do (
    set "has_files=1"
    set "name=%%~nxf"
    if "!msg!"=="update " (
        set "msg=!msg!!name!"
    ) else (
        set "msg=!msg!, !name!"
    )
)

if "!has_files!"=="0" (
    echo.
    echo Nothing to commit
    echo.
    pause
    exit /b 0
)

REM Truncate to 72 chars if needed
if not "!msg:~72,1!"=="" set "msg=!msg:~0,69!..."

echo [PUSHING] Committing: !msg!
git commit -m "!msg!"
if errorlevel 1 (
    echo.
    echo [ERROR] git commit failed
    echo.
    pause
    exit /b 1
)

echo [PUSHING] Pushing to remote...
git push
if errorlevel 1 (
    echo.
    echo [ERROR] git push failed
    echo.
    pause
    exit /b 1
)

echo.
echo [DONE] Successfully pushed: !msg!
echo.
pause
