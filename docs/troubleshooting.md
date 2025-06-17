# Troubleshooting Guide

## Common Issues and Solutions

### 1. SSH Connection Failures

#### Symptom: "Permission denied (publickey)"

**Solution:**
```bash
# On Windows
ssh-copy-id admin@nas-ip

# Or manually:
# 1. Copy your public key
type %USERPROFILE%\.ssh\id_rsa.pub

# 2. Add to NAS
ssh admin@nas-ip
mkdir -p ~/.ssh
echo "YOUR_PUBLIC_KEY" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

#### Symptom: "Connection refused"

**Causes:**
- SSH not enabled on NAS
- Firewall blocking port 22
- Wrong IP address

**Solution:**
1. Verify SSH is enabled in NAS settings
2. Check Windows Firewall
3. Test with: `ping nas-ip`

### 2. Docker Container Issues

#### Symptom: Container keeps restarting

**Check logs:**
```bash
docker logs mcp-[service-name] --tail 50
```

**Common fixes:**
```bash
# Missing environment variables
docker exec mcp-[service] env

# Permission issues
docker exec mcp-[service] ls -la /app

# Restart clean
docker stop mcp-[service]
docker rm mcp-[service]
docker-compose up -d mcp-[service]
```

### 3. Claude Desktop Configuration

#### Symptom: MCP servers not appearing in Claude

**Check config location:**
```powershell
# Windows
dir %APPDATA%\Claude\claude_desktop_config.json

# Verify JSON syntax
type %APPDATA%\Claude\claude_desktop_config.json
```

**Common issues:**
- Single backslashes (use double: \\)
- Missing commas
- Wrong file encoding (use UTF-8)

#### Symptom: "spawn ENOENT" error

**Cause:** Path to script not found

**Solution:**
```powershell
# Verify scripts exist
dir C:\mcp-bridges\

# Re-run setup if missing
.\setup-magi-windows.ps1
```

### 4. MCP Communication Issues

#### Symptom: No response from MCP server

**Test manually:**
```bash
# SSH to NAS
ssh admin@nas-ip

# Test container
docker exec -it mcp-time python /app/server.py
# Type: {"jsonrpc": "2.0", "method": "initialize", "params": {}, "id": 1}
# Press Ctrl+D
```

**If no response:**
- Check if correct command (python vs node)
- Verify image has MCP server installed
- Check container resources

### 5. Network Issues

#### Symptom: Slow response times

**Optimize:**
```bash
# Use SSH ControlMaster
# Add to ~/.ssh/config on Windows:
Host nas
  HostName 192.168.1.100
  User admin
  ControlMaster auto
  ControlPath ~/.ssh/control-%r@%h:%p
  ControlPersist 10m
```

### 6. Memory/Performance Issues

#### Symptom: NAS running slow

**Check resources:**
```bash
# On NAS
docker stats
free -h
df -h
```

**Optimize:**
```bash
# Limit container resources
docker update --memory="512m" --cpus="0.5" mcp-[service]
```

### 7. Debugging Steps

#### Enable verbose logging:

1. **SSH verbose mode:**
```batch
ssh -vvv admin@nas-ip "docker exec -i mcp-time python /app/server.py"
```

2. **Docker logs:**
```bash
docker logs -f mcp-[service]
```

3. **Claude Desktop logs:**
- Windows: `%APPDATA%\Claude\logs`

### 8. Recovery Procedures

#### Full reset:
```bash
# On NAS
cd /volume1/docker/MAGI-CORE-MCP-NAS
docker-compose down
docker-compose pull
docker-compose up -d
```

#### Backup MCP data:
```bash
# Create backup
docker run --rm -v mcp-memory-data:/data -v /volume1/backup:/backup alpine tar czf /backup/mcp-memory-$(date +%Y%m%d).tar.gz -C /data .
```

### 9. Getting Help

1. **Collect diagnostics:**
```bash
# System info
uname -a
docker version
docker-compose version

# Container status
docker ps -a | grep mcp-

# Recent logs
for c in $(docker ps -a --format "{{.Names}}" | grep mcp-); do
  echo "=== $c ==="
  docker logs $c --tail 20
done
```

2. **Create GitHub issue with:**
- OS versions (NAS and Windows)
- Error messages
- Diagnostic output
- Steps to reproduce

### 10. Prevention

1. **Regular maintenance:**
```bash
# Weekly cleanup
docker system prune -f

# Check for updates
cd /volume1/docker/MAGI-CORE-MCP-NAS
git pull
```

2. **Monitor resources:**
- Set up Portainer for visual monitoring
- Configure alerts for container failures
- Regular backup of MCP data

---

**Remember:** Most issues are related to:
1. SSH configuration
2. Path/permission problems  
3. JSON syntax in config
4. Network connectivity

When in doubt, test each component individually!