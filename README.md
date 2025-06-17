# 🧠 MAGI-CORE-MCP-NAS

Centralized MCP servers deployed on Terramaster NAS for all MAGI machines. Provides unified Claude memory and Docker management across Melchior, Balthasar, and Caspar.

## 🔒 Security Notice

**IMPORTANT**: This repository uses template configuration files (`.example.json`). Never commit your actual `claude_desktop_config.json` files with real tokens to GitHub!

## 🎯 Purpose

This repository contains the infrastructure to deploy and manage MCP (Model Context Protocol) servers on your Terramaster NAS, allowing all Claude instances across your MAGI machines to share:
- Unified memory (knowledge graph)
- Docker container management
- File system access
- GitHub integration
- Time synchronization
- Sequential thinking capabilities

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Terramaster NAS                       │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │          MCP Server Containers                   │   │
│  │                                                  │   │
│  │  • mcp-docker (Docker management)                │   │
│  │  • mcp-filesystem (File operations)              │   │
│  │  • mcp-memory (Neo4j knowledge graph)            │   │
│  │  • mcp-github (GitHub integration)               │   │
│  │  • mcp-sequential (Sequential thinking)          │   │
│  │  • mcp-time (Time operations)                    │   │
│  │  • mcp-playwright (Browser automation)           │   │
│  │  • mcp-node-sandbox (Code execution)            │   │
│  └─────────────────────┬───────────────────────────┘   │
│                        │ SSH + Docker exec              │
└────────────────────────┴───────────────────────────────┘
                         │
     ┌──────────┬────────┴────────┬──────────┐
     │          │                 │          │
┌────┴────┐ ┌───┴────┐      ┌────┴────┐    │
│ Claude  │ │ Claude │      │ Claude  │    │
│ Desktop │ │Desktop │      │Desktop  │    │
│Melchior │ │Balthasar│     │ Caspar  │    │
└─────────┘ └────────┘      └─────────┘    │
                                            │
                            Portainer Bridge
```

## 📦 Available MCP Images on NAS

Your NAS already has 28 MCP Docker images ready:
- `mcp/docker:latest` - Docker container management
- `mcp/filesystem:latest` - File system operations
- `mcp/neo4j-memory:latest` - Persistent memory/knowledge graph
- `mcp/github-mcp-server:latest` - GitHub integration
- `mcp/sequentialthinking:latest` - Complex reasoning
- `mcp/time:latest` - Time operations
- `mcp/playwright:latest` - Browser automation
- `mcp/node-code-sandbox:latest` - Code execution
- And 20 more specialized servers!

## 🚀 Quick Start

### 1. Deploy MCP Servers on NAS

```bash
# SSH to your NAS
ssh admin@192.168.1.100

# Clone this repository
cd /volume1/docker
git clone https://github.com/SamuraiBuddha/MAGI-CORE-MCP-NAS.git
cd MAGI-CORE-MCP-NAS

# Deploy all MCP servers
./scripts/deploy-mcp-servers.sh
```

### 2. Setup MAGI Machines

On each MAGI machine (Melchior, Balthasar, Caspar):

```powershell
# Run PowerShell as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Download and run setup script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/SamuraiBuddha/MAGI-CORE-MCP-NAS/main/scripts/setup-magi-windows.ps1" -OutFile "setup-magi.ps1"
.\setup-magi.ps1
```

The script automatically detects your machine and downloads the correct configuration template!

### 3. Configure Claude Desktop

1. **Add your tokens** to the config file on your Desktop:
   - Replace `${GITHUB_TOKEN}` with your GitHub personal access token
   - Replace `YOUR_PORTAINER_TOKEN` with your Portainer API token

2. **Copy the configured file** to Claude's directory:
   ```powershell
   copy claude_desktop_config.json %APPDATA%\Claude\claude_desktop_config.json
   ```

3. **Restart Claude Desktop**

⚠️ **IMPORTANT**: Never commit your configured `claude_desktop_config.json` to GitHub!

## 🔧 Machine-Specific Configurations

Each MAGI machine has a custom configuration template:

| Machine | Username | Template File |
|---------|----------|--------------|
| Melchior | jordanehrig | `claude_desktop_config_melchior.example.json` |
| Caspar | SamuraiBuddha | `claude_desktop_config_caspar.example.json` |
| Balthasar | (varies) | `claude_desktop_config_balthasar.example.json` |

See [Machine Configurations](docs/machine-configurations.md) for security details.

## 📁 Repository Structure

```
MAGI-CORE-MCP-NAS/
├── docker-compose.yml          # Main deployment file
├── scripts/
│   ├── deploy-mcp-servers.sh   # NAS deployment script
│   ├── setup-magi-windows.ps1  # Windows setup script
│   └── test-mcp-connection.sh  # Connection test script
├── config/
│   ├── *.example.json          # Template configs (safe to commit)
│   └── mcp-wrapper.js          # SSH bridge wrapper
├── docs/
│   ├── setup-guide.md              # Detailed setup
│   ├── troubleshooting.md          # Common issues
│   └── machine-configurations.md   # Security guide
└── .gitignore                      # Protects your secrets
```

## 🔒 Security Best Practices

1. **Use template files**: Only `.example.json` files in the repo
2. **Local configs only**: Your actual config stays on your machine
3. **Check before commit**: Always run `git status` before committing
4. **Revoke if exposed**: If you accidentally commit tokens, revoke them immediately

## 🧪 Testing

### Test Individual MCP Server

```bash
# On NAS
./scripts/test-mcp-connection.sh mcp-time
```

### Test from MAGI Machine

```powershell
# Test SSH connection
ssh admin@192.168.1.100 "docker ps"

# Test MCP bridge
C:\mcp-bridges\test-mcp-time.bat
```

## 📊 Monitoring

- Portainer UI: `http://192.168.1.100:9000`
- Container logs: `docker logs mcp-<service-name>`
- Health checks: `docker ps` shows container status

## 🛠️ Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md) for common issues:
- SSH connection failures
- Container startup issues
- Claude Desktop configuration problems
- Network connectivity issues

## 🔄 Updates

```bash
# On NAS
cd /volume1/docker/MAGI-CORE-MCP-NAS
git pull
docker-compose down
docker-compose up -d
```

## 🤝 Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Test thoroughly on your setup
4. Submit a pull request
5. **Never include real tokens or configured files!**

## 📄 License

MIT License - See [LICENSE](LICENSE) file

---

**Created by**: Jordan Paul Ehrig (SamuraiBuddha)  
**Company**: Ehrig BIM & IT Consultation, Inc.  
**Part of**: CORTEX AI Ecosystem