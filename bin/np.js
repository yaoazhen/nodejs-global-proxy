#!/usr/bin/env node

import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { existsSync } from 'fs';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Colors for output
const colors = {
    red: '\x1b[31m',
    green: '\x1b[32m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m',
    reset: '\x1b[0m'
};

function log(color, message) {
    console.log(`${colors[color]}${message}${colors.reset}`);
}

function showUsage() {
    log('blue', 'Node.js Process SOCKS5 Proxy Manager');
    log('yellow', 'Usage: np <command> [options]');
    console.log('');
    console.log('Commands:');
    console.log('  set [proxy_uri] [-log]  Enable SOCKS5 proxy for Node.js processes');
    console.log('                          Default: socks5://127.0.0.1:1086');
    console.log('                          -log: Enable debug logging');
    console.log('  unset                   Disable SOCKS5 proxy for Node.js processes');
    console.log('  status                  Show current proxy status');
    console.log('');
    console.log('Examples:');
    console.log('  np set "socks5://127.0.0.1:1086"');
    console.log('  np set "socks5://user:pass@127.0.0.1:1086" -log');
    console.log('  np set -log             (uses default proxy with debug logging)');
    console.log('  np set                  (uses default: socks5://127.0.0.1:1086)');
    console.log('  np unset');
    console.log('  np status');
    console.log('');
    log('blue', 'Note: If no proxy_uri is provided with "set" command,');
    log('blue', '      the default socks5://127.0.0.1:1086 will be used.');
}

function getInjectorPath() {
    // Get the path to the socks5-agent-injector.js file
    const injectorPath = join(__dirname, '..', 'socks5-agent-injector.js');
    if (!existsSync(injectorPath)) {
        log('red', `Error: Cannot find socks5-agent-injector.js at ${injectorPath}`);
        process.exit(1);
    }
    return injectorPath;
}

function setProxy(proxyUri, enableLog = false) {
    const defaultProxy = 'socks5://127.0.0.1:1086';
    const uri = proxyUri || defaultProxy;
    
    if (!proxyUri) {
        log('yellow', `No proxy URI provided. Using default proxy: ${uri}`);
        log('blue', 'You can specify a custom proxy like: np set "socks5://your.proxy:port"');
    }
    
    const injectorPath = getInjectorPath();
    
    // Set environment variables
    process.env.NODEJS_GLOBAL_SOCKS5_PROXY = uri;
    process.env.NODE_OPTIONS = `--require ${injectorPath}`;
    
    // Set log environment variable if -log flag is provided
    if (enableLog) {
        process.env.NODEJS_PROXY_DEBUG_LOG = 'true';
    }
    
    log('green', `Node.js process SOCKS5 proxy ENABLED to: ${uri}`);
    log('green', `NODE_OPTIONS set to: ${process.env.NODE_OPTIONS}`);
    
    if (enableLog) {
        log('green', 'Debug logging ENABLED');
    }
    
    // Show instructions for shell integration
    console.log('');
    log('blue', 'To make this setting persistent in your current shell session, run:');
    log('yellow', `export NODEJS_GLOBAL_SOCKS5_PROXY="${uri}"`);
    log('yellow', `export NODE_OPTIONS="--require ${injectorPath}"`);
    if (enableLog) {
        log('yellow', `export NODEJS_PROXY_DEBUG_LOG="true"`);
    }
    console.log('');
    log('blue', 'Or add these lines to your ~/.bashrc or ~/.zshrc for permanent setup.');
}

function unsetProxy() {
    delete process.env.NODEJS_GLOBAL_SOCKS5_PROXY;
    delete process.env.NODE_OPTIONS;
    delete process.env.NODEJS_PROXY_DEBUG_LOG;
    
    log('green', 'Node.js process SOCKS5 proxy DISABLED.');
    console.log('');
    log('blue', 'To make this setting persistent in your current shell session, run:');
    log('yellow', 'unset NODEJS_GLOBAL_SOCKS5_PROXY');
    log('yellow', 'unset NODE_OPTIONS');
    log('yellow', 'unset NODEJS_PROXY_DEBUG_LOG');
}

function showStatus() {
    const proxyUri = process.env.NODEJS_GLOBAL_SOCKS5_PROXY;
    const nodeOptions = process.env.NODE_OPTIONS;
    const debugLog = process.env.NODEJS_PROXY_DEBUG_LOG;
    
    log('blue', 'Current Node.js Process Proxy Status:');
    console.log('');
    
    if (proxyUri) {
        log('green', `✓ SOCKS5 Proxy: ${proxyUri}`);
    } else {
        log('yellow', '✗ SOCKS5 Proxy: Not set');
    }
    
    if (nodeOptions && nodeOptions.includes('socks5-agent-injector.js')) {
        log('green', `✓ NODE_OPTIONS: ${nodeOptions}`);
    } else {
        log('yellow', '✗ NODE_OPTIONS: Not configured for proxy');
    }
    
    if (debugLog === 'true') {
        log('green', '✓ Debug Logging: ENABLED');
    } else {
        log('yellow', '✗ Debug Logging: DISABLED');
    }
    
    console.log('');
    if (proxyUri && nodeOptions) {
        log('green', 'Status: Proxy is ENABLED for Node.js applications');
    } else {
        log('yellow', 'Status: Proxy is DISABLED');
    }
}

// Main CLI logic
const args = process.argv.slice(2);
const command = args[0];

switch (command) {
    case 'set':
        // Parse arguments for set command
        let proxyUri = null;
        let enableLog = false;
        
        // Check for -log flag and proxy URI
        for (let i = 1; i < args.length; i++) {
            if (args[i] === '-log') {
                enableLog = true;
            } else if (!proxyUri && !args[i].startsWith('-')) {
                proxyUri = args[i];
            }
        }
        
        setProxy(proxyUri, enableLog);
        break;
    case 'unset':
        unsetProxy();
        break;
    case 'status':
        showStatus();
        break;
    case 'help':
    case '--help':
    case '-h':
        showUsage();
        break;
    default:
        if (!command) {
            showUsage();
        } else {
            log('red', `Unknown command: ${command}`);
            console.log('');
            showUsage();
            process.exit(1);
        }
        break;
}