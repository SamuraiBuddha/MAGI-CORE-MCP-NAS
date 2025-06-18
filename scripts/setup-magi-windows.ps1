# Setup MAGI Windows Machine for NAS MCP Access
# Run this on each MAGI machine (Melchior, Balthasar, Caspar)

$ErrorActionPreference = "Stop"

Write-Host "🔧 MAGI MCP Setup for Windows" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan

# Detect machine name and username
$computerName = $env:COMPUTERNAME
$userName = $env:USERNAME
Write-Host "Machine: $computerName" -ForegroundColor Yellow
Write-Host "User: $userName" -ForegroundColor Yellow

# Get NAS configuration
$nasIP = Read-Host -Prompt "Enter NAS IP (default: 192.168.50.78)"
if ([string]::IsNullOrWhiteSpace($nasIP)) { $nasIP = "192.168.50.78" }

# Note: We no longer ask for NAS username since it's dynamically detected
Write-Host "`n✅ NAS username will be automatically detected based on Windows username" -ForegroundColor Green
Write-Host "   - jordanehrig → SamuraiBuddha" -ForegroundColor Gray
Write-Host "   - SamuraiBuddha → SamuraiBuddha" -ForegroundColor Gray
Write-Host "   - Others → Same as Windows username" -ForegroundColor Gray

# Update the SSH commands to use port 9222
$sshPort = "9222"
Write-Host "`n⚡ SSH will use port $sshPort" -ForegroundColor Yellow

# 1. Check for SSH
Write-Host "`n🔍 Checking SSH installation..." -ForegroundColor Yellow
if (!(Get-Command ssh -ErrorAction SilentlyContinue)) {
    Write-Host "❌ SSH not found. Please install OpenSSH or Git for Windows" -ForegroundColor Red
    Write-Host "   Download Git: https://git-scm.com/download/win" -ForegroundColor Gray
    exit 1
}
Write-Host "✅ SSH is installed" -ForegroundColor Green

# 2. Generate SSH key if needed
$sshKeyPath = "$env:USERPROFILE\.ssh\id_rsa"
if (!(Test-Path $sshKeyPath)) {
    Write-Host "`n🔑 Generating SSH key..." -ForegroundColor Yellow
    ssh-keygen -t rsa -b 4096 -f $sshKeyPath -N '""' -q
    Write-Host "✅ SSH key generated" -ForegroundColor Green
}

# 3. Display public key
Write-Host "`n📋 Your SSH public key:" -ForegroundColor Yellow
$publicKey = Get-Content "$sshKeyPath.pub"
Write-Host $publicKey -ForegroundColor Cyan

# Determine the correct NAS username for instructions
$nasUser = if ($userName -eq "jordanehrig") { "SamuraiBuddha" } else { $userName }

Write-Host "`n⚠️  Add this key to your NAS:" -ForegroundColor Yellow
Write-Host "1. SSH to NAS: ssh -p $sshPort $nasUser@$nasIP" -ForegroundColor Gray
Write-Host "2. Run: echo '$publicKey' >> ~/.ssh/authorized_keys" -ForegroundColor Gray
Write-Host "3. Run: chmod 600 ~/.ssh/authorized_keys" -ForegroundColor Gray
Write-Host "`nPress Enter after adding the key..." -ForegroundColor Yellow
Read-Host

# 4. Test SSH connection
Write-Host "`n🧪 Testing SSH connection..." -ForegroundColor Yellow
$testResult = ssh -p $sshPort -o BatchMode=yes -o ConnectTimeout=5 "$nasUser@$nasIP" "echo 'SSH OK'"
if ($testResult -eq "SSH OK") {
    Write-Host "✅ SSH connection successful!" -ForegroundColor Green
} else {
    Write-Host "❌ SSH connection failed. Please check your configuration." -ForegroundColor Red
    exit 1
}

# 5. Create MCP bridge directory
$bridgeDir = "C:\mcp-bridges"
Write-Host "`n📁 Creating MCP bridge directory..." -ForegroundColor Yellow
if (!(Test-Path $bridgeDir)) {
    New-Item -ItemType Directory -Path $bridgeDir | Out-Null
}

# 6. Create wrapper scripts with dynamic username detection
Write-Host "📝 Creating MCP wrapper scripts with dynamic username detection..." -ForegroundColor Yellow

$mcpServers = @{
    "mcp-docker" = @{"cmd" = "python /app/server.py"; "type" = "docker"}
    "mcp-filesystem" = @{"cmd" = "python /app/server.py"; "type" = "filesystem"}
    "mcp-memory" = @{"cmd" = "python /app/server.py"; "type" = "memory"}
    "mcp-github" = @{"cmd" = "node /app/server.js"; "type" = "github"}
    "mcp-sequential" = @{"cmd" = "python /app/server.py"; "type" = "sequential"}
    "mcp-time" = @{"cmd" = "python /app/server.py"; "type" = "time"}
    "mcp-playwright" = @{"cmd" = "python /app/server.py"; "type" = "browser"}
    "mcp-node-sandbox" = @{"cmd" = "node /app/server.js"; "type" = "sandbox"}
}

# Create dynamic wrapper template
$wrapperTemplate = @'
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
if "%NAS_IP%"=="" set NAS_IP={{NAS_IP}}
if "%NAS_PORT%"=="" set NAS_PORT={{NAS_PORT}}

REM Get the MCP server details
set SERVER_NAME={{SERVER_NAME}}
set SERVER_CMD={{SERVER_CMD}}

REM Execute SSH connection with dynamic username
ssh -p %NAS_PORT% %NAS_USER%@%NAS_IP% "docker exec -i %SERVER_NAME% %SERVER_CMD%"

endlocal
'@

foreach ($server in $mcpServers.GetEnumerator()) {
    $wrapperContent = $wrapperTemplate -replace "{{NAS_IP}}", $nasIP
    $wrapperContent = $wrapperContent -replace "{{NAS_PORT}}", $sshPort
    $wrapperContent = $wrapperContent -replace "{{SERVER_NAME}}", $server.Key
    $wrapperContent = $wrapperContent -replace "{{SERVER_CMD}}", $server.Value.cmd
    
    $wrapperPath = Join-Path $bridgeDir "$($server.Key).bat"
    Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding ASCII
}

# 7. Create Claude Desktop configuration
Write-Host "`n📋 Creating Claude Desktop configuration..." -ForegroundColor Yellow

# Determine config file based on machine/user
$configFileName = ""
if ($computerName -match "melchior" -or $userName -eq "jordanehrig") {
    $configFileName = "claude_desktop_config_melchior.example.json"
    $portainerPath = "C:\\Users\\jordanehrig\\Documents\\GitHub\\mcp-portainer-bridge\\server.js"
} elseif ($computerName -match "caspar" -or $userName -eq "SamuraiBuddha") {
    $configFileName = "claude_desktop_config_caspar.example.json"
    $portainerPath = "C:\\Users\\SamuraiBuddha\\Documents\\GitHub\\mcp-portainer-bridge\\server.js"
} elseif ($computerName -match "balthasar") {
    $configFileName = "claude_desktop_config_balthasar.example.json"
    $portainerPath = "C:\\Users\\$userName\\Documents\\GitHub\\mcp-portainer-bridge\\server.js"
} else {
    Write-Host "⚠️  Unknown machine. Creating generic config..." -ForegroundColor Yellow
    $configFileName = "claude_desktop_config_balthasar.example.json"
    $portainerPath = "C:\\Users\\$userName\\Documents\\GitHub\\mcp-portainer-bridge\\server.js"
}

Write-Host "Using config template: $configFileName" -ForegroundColor Cyan

# Download the appropriate config
$configUrl = "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/config/$configFileName"
try {
    $claudeConfig = Invoke-WebRequest -Uri $configUrl -UseBasicParsing | Select-Object -ExpandProperty Content
    
    # Replace USERNAME placeholder if present
    $claudeConfig = $claudeConfig -replace "USERNAME", $userName
    
    $configPath = "$env:USERPROFILE\Desktop\claude_desktop_config.json"
    Set-Content -Path $configPath -Value $claudeConfig -Encoding UTF8
    Write-Host "✅ Downloaded machine-specific config template" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not download config. Creating generic version..." -ForegroundColor Yellow
    # Create generic config as fallback
    $claudeConfig = @"
{
  "mcpServers": {
    "nas-docker": {
      "command": "$bridgeDir\\mcp-docker.bat"
    },
    "nas-filesystem": {
      "command": "$bridgeDir\\mcp-filesystem.bat",
      "env": {
        "ALLOWED_DIRECTORIES": "/workspace"
      }
    },
    "nas-memory": {
      "command": "$bridgeDir\\mcp-memory.bat"
    },
    "nas-github": {
      "command": "$bridgeDir\\mcp-github.bat",
      "env": {
        "GITHUB_TOKEN": "YOUR_GITHUB_TOKEN_HERE"
      }
    },
    "nas-sequential": {
      "command": "$bridgeDir\\mcp-sequential.bat"
    },
    "nas-time": {
      "command": "$bridgeDir\\mcp-time.bat"
    },
    "portainer-bridge": {
      "command": "node",
      "args": ["$portainerPath"],
      "env": {
        "PORTAINER_URL": "http://$nasIP:9000",
        "PORTAINER_TOKEN": "YOUR_PORTAINER_TOKEN",
        "PORTAINER_ENDPOINT_ID": "1"
      }
    }
  }
}
"@
    $configPath = "$env:USERPROFILE\Desktop\claude_desktop_config.json"
    Set-Content -Path $configPath -Value $claudeConfig -Encoding UTF8
}

# 8. Create test script
$testScript = @"
@echo off
echo Testing MCP Time Server with dynamic username...
echo Current Windows user: %USERNAME%
echo.
call "$bridgeDir\mcp-time.bat"
pause
"@
Set-Content -Path "$env:USERPROFILE\Desktop\test-mcp.bat" -Value $testScript -Encoding ASCII

# Success message
Write-Host "`n✅ Setup Complete!" -ForegroundColor Green
Write-Host "`n🎨 IMPORTANT SECURITY NOTICE:" -ForegroundColor Red
Write-Host "The config file on your Desktop contains placeholders for sensitive tokens." -ForegroundColor Yellow
Write-Host "DO NOT commit this file to GitHub after adding your tokens!" -ForegroundColor Yellow
Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Edit the config file on your Desktop:" -ForegroundColor Gray
Write-Host "   - Replace 'YOUR_GITHUB_TOKEN_HERE' with your actual GitHub token" -ForegroundColor Gray
Write-Host "   - Replace 'YOUR_PORTAINER_TOKEN' with your Portainer API token" -ForegroundColor Gray
Write-Host "2. Copy config to: %APPDATA%\Claude\claude_desktop_config.json" -ForegroundColor Gray
Write-Host "3. Restart Claude Desktop" -ForegroundColor Gray
Write-Host "4. Test with: test-mcp.bat on your Desktop" -ForegroundColor Gray
Write-Host "`n🎯 MCP bridges created in: $bridgeDir" -ForegroundColor Cyan
Write-Host "🎯 Config saved to: $configPath" -ForegroundColor Cyan
Write-Host "🎯 Machine detected as: $computerName ($userName)" -ForegroundColor Cyan
Write-Host "`n✨ Dynamic username detection enabled!" -ForegroundColor Green
Write-Host "   The wrappers will automatically use the correct NAS username" -ForegroundColor Gray
Write-Host "   regardless of which Windows user runs them." -ForegroundColor Gray
Write-Host "`n⚠️  Remember: Keep your configured claude_desktop_config.json LOCAL only!" -ForegroundColor Red
