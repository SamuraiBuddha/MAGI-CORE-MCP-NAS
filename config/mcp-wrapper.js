#!/usr/bin/env node
/**
 * MCP SSH Wrapper for MAGI Machines
 * This wrapper enables Claude Desktop on Windows to communicate with
 * MCP servers running in Docker containers on the NAS via SSH
 */

const { spawn } = require('child_process');
const path = require('path');

// Configuration
const NAS_HOST = process.env.NAS_HOST || '192.168.50.78';
const NAS_USER = process.env.NAS_USER || 'admin';
const SSH_PORT = process.env.SSH_PORT || '22';

// Parse command line arguments
const args = process.argv.slice(2);
const mcpServer = args[0];

if (!mcpServer) {
  console.error('Usage: mcp-wrapper.js <mcp-server-name>');
  process.exit(1);
}

// Map of MCP server names to their execution commands
const serverCommands = {
  'mcp-docker': 'python /app/server.py',
  'mcp-filesystem': 'python /app/server.py',
  'mcp-memory': 'python /app/server.py',
  'mcp-github': 'node /app/server.js',
  'mcp-sequential': 'python /app/server.py',
  'mcp-time': 'python /app/server.py',
  'mcp-playwright': 'python /app/server.py',
  'mcp-node-sandbox': 'node /app/server.js'
};

const command = serverCommands[mcpServer];
if (!command) {
  console.error(`Unknown MCP server: ${mcpServer}`);
  console.error(`Available servers: ${Object.keys(serverCommands).join(', ')}`);
  process.exit(1);
}

// Build SSH command
const sshArgs = [
  '-tt',
  '-o', 'BatchMode=yes',
  '-o', 'StrictHostKeyChecking=no',
  '-o', 'UserKnownHostsFile=/dev/null',
  '-p', SSH_PORT,
  `${NAS_USER}@${NAS_HOST}`,
  `docker exec -i ${mcpServer} ${command}`
];

// Spawn SSH process
const sshProcess = spawn('ssh', sshArgs, {
  stdio: 'inherit',
  shell: false,
  windowsHide: true
});

// Handle process termination
sshProcess.on('close', (code) => {
  process.exit(code || 0);
});

sshProcess.on('error', (err) => {
  console.error(`Failed to connect to MCP server ${mcpServer}: ${err.message}`);
  process.exit(1);
});

// Handle signals
process.on('SIGINT', () => {
  sshProcess.kill('SIGINT');
});

process.on('SIGTERM', () => {
  sshProcess.kill('SIGTERM');
});