@echo off
setlocal

REM Dynamic MCP SSH Wrapper - Automatically detects correct NAS username
REM This wrapper intelligently maps Windows usernames to NAS usernames

REM Get current Windows username
set CURRENT_USER=%USERNAME%

REM Detect NAS username based on Windows username
if /I "%CURRENT_USER%"=="jordanehrig" (
    set NAS_USER=SamuraiBuddha
) else if /I "%CURRENT_USER%"=="SamuraiBuddha" (
    set NAS_USER=SamuraiBuddha
) else (
    REM Default fallback - assumes Windows username matches NAS username
    set NAS_USER=%CURRENT_USER%
)

REM Get NAS connection details from environment or use defaults
if "%NAS_IP%"=="" set NAS_IP=192.168.50.78
if "%NAS_PORT%"=="" set NAS_PORT=9222

REM Get the MCP server details from the script name
set SERVER_NAME=%~n0
set SERVER_CMD={{SERVER_CMD}}

REM Execute SSH connection with dynamic username
ssh -p %NAS_PORT% %NAS_USER%@%NAS_IP% "docker exec -i %SERVER_NAME% %SERVER_CMD%"

endlocal
