# Machine-Specific Configurations

## 🔒 Security Notice

**IMPORTANT**: Never commit your actual `claude_desktop_config.json` files to GitHub! They contain sensitive API tokens.

## Overview

Each MAGI machine has different usernames and paths. We provide template files that you customize locally:

| Machine | Username | Template File | Actual Config Location |
|---------|----------|---------------|------------------------|
| Melchior | jordanehrig | `claude_desktop_config_melchior.example.json` | `%APPDATA%\Claude\claude_desktop_config.json` |
| Caspar | SamuraiBuddha | `claude_desktop_config_caspar.example.json` | `%APPDATA%\Claude\claude_desktop_config.json` |
| Balthasar | (varies) | `claude_desktop_config_balthasar.example.json` | `%APPDATA%\Claude\claude_desktop_config.json` |

## Security Best Practices

1. **Templates Only in Git**: Only `.example.json` files are committed
2. **Local Configs Only**: Your actual config with tokens stays on your machine
3. **Gitignore Protection**: All `claude_desktop_config*.json` files are gitignored
4. **Never Commit Tokens**: Double-check before any git commits

## Setup Process

### Automatic Setup

The `setup-magi-windows.ps1` script:
1. Detects your machine and username
2. Downloads the correct template
3. Creates a local config on your Desktop
4. Reminds you to add tokens and NOT commit it

### Manual Setup

1. **Download the correct template:**
   ```powershell
   # For Melchior
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/config/claude_desktop_config_melchior.example.json" -OutFile "claude_desktop_config.json"
   
   # For Caspar
   Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/config/claude_desktop_config_caspar.example.json" -OutFile "claude_desktop_config.json"
   ```

2. **Edit the config:**
   - Replace `${GITHUB_TOKEN}` with your actual token
   - Replace `YOUR_PORTAINER_TOKEN` with your actual token
   - Update paths if needed

3. **Copy to Claude Desktop:**
   ```powershell
   copy claude_desktop_config.json %APPDATA%\Claude\claude_desktop_config.json
   ```

4. **Verify it's not tracked:**
   ```powershell
   # In your local repo copy
   git status
   # Should NOT show claude_desktop_config.json
   ```

## Token Management

### GitHub Token
1. Go to GitHub Settings → Developer settings → Personal access tokens
2. Generate a token with repo permissions
3. Copy and paste into your LOCAL config only

### Portainer Token
1. Access Portainer at `http://192.168.1.100:9000`
2. Go to User settings → Access tokens
3. Create a new token
4. Copy and paste into your LOCAL config only

## Troubleshooting

### "I accidentally committed my config!"

1. **Immediately revoke tokens:**
   - GitHub: Settings → Developer settings → Personal access tokens → Delete
   - Portainer: User settings → Access tokens → Remove

2. **Remove from Git history:**
   ```bash
   git rm --cached claude_desktop_config.json
   git commit -m "Remove sensitive file"
   
   # If already pushed
   git filter-branch --force --index-filter \
     'git rm --cached --ignore-unmatch claude_desktop_config.json' \
     --prune-empty --tag-name-filter cat -- --all
   ```

3. **Generate new tokens**

### "Config not working"

```powershell
# Check file location
dir %APPDATA%\Claude\claude_desktop_config.json

# Verify JSON syntax
type %APPDATA%\Claude\claude_desktop_config.json | python -m json.tool

# Check username
echo %USERNAME%
```

## Adding New Machines

1. Create `config/claude_desktop_config_[machine].example.json`
2. Add machine detection to PowerShell script
3. Update this documentation
4. Submit PR (with .example.json only!)