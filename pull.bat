@echo off
setlocal enabledelayedexpansion
REM pull.bat - Simplified Git pull workflow for iOS project
REM Usage: pull.bat (run from project root in Command Prompt or PowerShell)

echo [PULLING] Fetching and merging from remote...

REM Capture git pull output to temp file
set "tempfile=%temp%\git_pull_output_%random%.txt"
git pull > "!tempfile!" 2>&1
set "pull_exit=!errorlevel!"

if !pull_exit! neq 0 (
    echo.
    REM Check for merge conflicts
    set "has_conflicts=0"
    set "header=0"
    for /f "delims=" %%f in ('git diff --name-only --diff-filter=U 2^>nul') do (
        set "has_conflicts=1"
        if !header! equ 0 (
            echo [ERROR] MERGE CONFLICT DETECTED
            echo.
            echo The following files have conflicts and need manual resolution:
            echo.
            set "header=1"
        )
        echo   - %%f
    )
    if "!has_conflicts!"=="1" (
        echo.
        echo Please resolve the conflicts, then run 'git add' and 'git commit' to complete the merge.
    ) else (
        echo [ERROR] git pull failed:
        type "!tempfile!"
    )
    echo.
    del "!tempfile!" 2>nul
    pause
    exit /b 1
)

REM Check if already up to date
findstr /i "Already up to date" "!tempfile!" >nul 2>&1
if !errorlevel! equ 0 (
    echo.
    echo [DONE] Already up to date
    del "!tempfile!" 2>nul
    echo.
    pause
    exit /b 0
)

echo.
echo [DONE] Pull completed successfully
echo.
echo Updated files:
git diff --name-only HEAD@{1} HEAD 2>nul
if errorlevel 1 type "!tempfile!"

del "!tempfile!" 2>nul
echo.
pause
