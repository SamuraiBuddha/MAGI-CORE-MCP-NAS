# Detailed Setup Guide for MAGI-CORE-MCP-NAS

## Prerequisites

- Terramaster NAS with Docker support
- 3 Windows machines (Melchior, Balthasar, Caspar) with Claude Desktop
- SSH access to NAS
- GitHub account with personal access token
- Basic understanding of Docker and SSH

## Step 1: NAS Preparation

### 1.1 Enable SSH on NAS

1. Log into Terramaster NAS web interface
2. Go to Control Panel → Terminal & SSH
3. Enable SSH service
4. Note the SSH port (default: 22)

### 1.2 Install Docker

1. Go to App Center
2. Search for "Docker"
3. Install Docker and Docker Compose
4. Start Docker service

### 1.3 Create Required Directories

```bash
ssh admin@your-nas-ip
mkdir -p /volume1/docker/{mcp-workspace,mcp-logs}
```

## Step 2: Deploy MCP Servers

### 2.1 Clone Repository

```bash
cd /volume1/docker
git clone https://github.com/SamuraiBuddha/MAGI-CORE-MCP-NAS.git
cd MAGI-CORE-MCP-NAS
```

### 2.2 Configure Environment

```bash
cp env.example .env
nano .env  # Edit with your values
```

Required values:
- `GITHUB_TOKEN`: Your GitHub personal access token
- `NAS_IP`: Your NAS IP address
- `NAS_USER`: Your NAS admin username

### 2.3 Deploy Services

```bash
./scripts/deploy-mcp-servers.sh
```

This will:
- Pull all MCP Docker images
- Create and start containers
- Set up networking
- Create test scripts

## Step 3: Configure MAGI Machines

### 3.1 Install Prerequisites on Windows

1. **Git for Windows** (includes SSH):
   - Download from: https://git-scm.com/download/win
   - During installation, ensure "Git Bash" is selected

2. **Node.js** (for MCP wrapper):
   - Download from: https://nodejs.org/
   - Choose LTS version

### 3.2 Run Setup Script

1. Open PowerShell as Administrator
2. Run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/scripts/setup-magi-windows.ps1" -OutFile "setup-magi.ps1"
.\setup-magi.ps1
```

3. Follow the prompts:
   - Enter NAS IP
   - Enter NAS username
   - Copy SSH key to NAS when prompted

### 3.3 Configure Claude Desktop

1. Locate the generated config file on Desktop
2. Edit to add your tokens:
   - `GITHUB_TOKEN`
   - `PORTAINER_TOKEN` (if using)

3. Copy to Claude config directory:
   - Press `Win + R`
   - Type: `%APPDATA%\Claude`
   - Copy `claude_desktop_config.json` here

4. Restart Claude Desktop

## Step 4: Verify Installation

### 4.1 Test SSH Connection

```powershell
ssh admin@your-nas-ip "docker ps | grep mcp-"
```

You should see all MCP containers running.

### 4.2 Test MCP Bridge

1. Run the test script on Desktop:
   ```
   test-mcp.bat
   ```

2. You should see JSON-RPC responses

### 4.3 Test in Claude

1. Open Claude Desktop
2. Check available tools/functions
3. Try a simple command like getting current time

## Troubleshooting

### SSH Key Issues

```bash
# On Windows, check key permissions
icacls %USERPROFILE%\.ssh\id_rsa

# On NAS, fix permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

### Container Not Starting

```bash
# Check logs
docker logs mcp-[service-name]

# Restart container
docker restart mcp-[service-name]
```

### Claude Not Detecting MCP

1. Verify config file location
2. Check for JSON syntax errors
3. Ensure paths use double backslashes
4. Restart Claude Desktop

## Next Steps

1. Configure additional MCP servers as needed
2. Set up monitoring with Portainer
3. Create automated backups of MCP data
4. Explore advanced MCP features

## Support

For issues, check:
- [Troubleshooting Guide](troubleshooting.md)
- [GitHub Issues](https://github.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/issues)
- CORTEX Discord community