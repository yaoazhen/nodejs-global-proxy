#!/usr/bin/env node

import { execSync } from 'child_process';
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

function main() {
    // Check if this is a global installation
    const isGlobal = process.env.npm_config_global === 'true';
    
    if (!isGlobal) {
        log('yellow', 'This package is designed for global installation.');
        log('yellow', 'Please install globally with: npm install -g nodejs-process-proxy');
        return;
    }

    log('blue', '🚀 Setting up Node.js Process Proxy...');
    
    // Check if install.sh exists
    const installScript = join(__dirname, 'install.sh');
    if (!existsSync(installScript)) {
        log('yellow', 'install.sh not found, skipping additional setup.');
        showUsageInstructions();
        return;
    }

    try {
        log('blue', 'Running additional setup script...');
        
        // Make install.sh executable
        execSync(`chmod +x "${installScript}"`, { stdio: 'inherit' });
        
        // Run install.sh
        execSync(`bash "${installScript}"`, { stdio: 'inherit' });
        
        log('green', '✅ Setup completed successfully!');
        
    } catch (error) {
        log('yellow', 'Additional setup script encountered an issue, but the main package is still functional.');
        log('yellow', 'You can still use the np command normally.');
        showUsageInstructions();
    }
}

function showUsageInstructions() {
    console.log('');
    log('blue', '📖 Usage Instructions:');
    console.log('');
    console.log('  Enable proxy:');
    log('yellow', '    np set                    # Use default proxy');
    log('yellow', '    np set "socks5://..."     # Use custom proxy');
    log('yellow', '    np set -log               # Enable debug logging');
    console.log('');
    console.log('  Apply to current shell:');
    log('yellow', '    source .np-proxy-env.sh   # After running np set');
    console.log('');
    console.log('  Check status:');
    log('yellow', '    np status');
    console.log('');
    console.log('  Disable proxy:');
    log('yellow', '    np unset');
    log('yellow', '    source .np-proxy-env.sh');
    console.log('');
    console.log('  Get help:');
    log('yellow', '    np help');
    console.log('');
}

main();