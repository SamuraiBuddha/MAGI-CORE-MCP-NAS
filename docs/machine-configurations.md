# Machine-Specific Configurations

## Overview

Each MAGI machine has different usernames and paths, so we provide separate configuration files:

| Machine | Username | Config File | Portainer Path |
|---------|----------|-------------|----------------|
| Melchior | jordanehrig | `claude_desktop_config_melchior.json` | `C:\Users\jordanehrig\Documents\GitHub\mcp-portainer-bridge\server.js` |
| Caspar | SamuraiBuddha | `claude_desktop_config_caspar.json` | `C:\Users\SamuraiBuddha\Documents\GitHub\mcp-portainer-bridge\server.js` |
| Balthasar | (varies) | `claude_desktop_config_balthasar.json` | `C:\Users\USERNAME\Documents\GitHub\mcp-portainer-bridge\server.js` |

## Automatic Detection

The `setup-magi-windows.ps1` script automatically:
1. Detects your machine name and username
2. Downloads the correct configuration file
3. Replaces any USERNAME placeholders
4. Saves it to your Desktop

## Manual Configuration

If automatic detection fails, you can:

1. **Download the correct config manually:**
   ```powershell
   # For Melchior
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/config/claude_desktop_config_melchior.json" -OutFile "claude_desktop_config.json"
   
   # For Caspar
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/config/claude_desktop_config_caspar.json" -OutFile "claude_desktop_config.json"
   
   # For Balthasar
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/config/claude_desktop_config_balthasar.json" -OutFile "claude_desktop_config.json"
   ```

2. **Edit paths if needed:**
   - Open the config in a text editor
   - Update the portainer-bridge path to match your username
   - Save the file

3. **Copy to Claude Desktop:**
   ```powershell
   copy claude_desktop_config.json %APPDATA%\Claude\claude_desktop_config.json
   ```

## Adding New Machines

To add a new machine:

1. Create a new config file: `config/claude_desktop_config_[machine].json`
2. Update the PowerShell script detection logic
3. Submit a pull request

## Shared Components

All machines share:
- MCP bridge scripts in `C:\mcp-bridges\`
- SSH connection to NAS
- Same MCP server names (nas-docker, nas-filesystem, etc.)

Only the Portainer bridge path differs based on username.

## Troubleshooting Username Issues

```powershell
# Check your username
echo $env:USERNAME

# Check your computer name
echo $env:COMPUTERNAME

# Find your Documents folder
echo $env:USERPROFILE\Documents
```

If paths don't match, manually edit the config file before copying to Claude Desktop.