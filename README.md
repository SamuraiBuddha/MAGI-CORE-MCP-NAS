# 🧠 MAGI-CORE-MCP-NAS

Centralized MCP servers deployed on Terramaster NAS for all MAGI machines. Provides unified Claude memory and Docker management across Melchior, Balthasar, and Caspar.

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

### 3. Configure Claude Desktop

The setup script will create a `claude_desktop_config.json` file. Copy it to:
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Linux: `~/.config/Claude/claude_desktop_config.json`

## 📁 Repository Structure

```
MAGI-CORE-MCP-NAS/
├── docker-compose.yml          # Main deployment file
├── scripts/
│   ├── deploy-mcp-servers.sh   # NAS deployment script
│   ├── setup-magi-windows.ps1  # Windows setup script
│   └── test-mcp-connection.sh  # Connection test script
├── config/
│   ├── claude_desktop_config.json  # Template config
│   └── mcp-wrapper.js             # SSH bridge wrapper
├── docs/
│   ├── setup-guide.md         # Detailed setup instructions
│   ├── troubleshooting.md     # Common issues and fixes
│   └── architecture.md        # Technical architecture
└── env.example                # Environment variables template
```

## 🔧 Configuration

### Environment Variables

Copy `env.example` to `.env` and set:

```bash
# Required
GITHUB_TOKEN=ghp_your_github_token
NAS_IP=192.168.1.100
NAS_USER=admin

# Optional
NEO4J_PASSWORD=your_neo4j_password
MCP_WORKSPACE=/volume1/docker/mcp-workspace
```

### SSH Key Setup

The setup script generates SSH keys automatically. If manual setup needed:

```bash
# On MAGI machine
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# Copy to NAS
ssh-copy-id admin@192.168.1.100
```

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

## 📄 License

MIT License - See [LICENSE](LICENSE) file

---

**Created by**: Jordan Paul Ehrig (SamuraiBuddha)  
**Company**: Ehrig BIM & IT Consultation, Inc.  
**Part of**: CORTEX AI Ecosystem