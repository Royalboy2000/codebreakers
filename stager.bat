@echo off

set "batchPath=%~dp0"
set "powershellPath=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
set "scriptPath=%batchPath%test.ps1"
set "executionPolicy=Unrestricted"

REM Set execution policy
"%powershellPath%" -Command "Set-ExecutionPolicy %executionPolicy% -Scope CurrentUser -Force"

REM Run PowerShell script invisibly
start "" /B "%powershellPath%" -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%scriptPath%"
