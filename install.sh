#!/bin/bash

# Define colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Node.js Process Proxy - Shell Integration Setup${NC}"
echo ""

# Get the global npm modules path to find the injector
NPM_GLOBAL_PATH=$(npm root -g 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$NPM_GLOBAL_PATH" ]; then
    echo -e "${RED}Error: Cannot determine npm global modules path${NC}"
    exit 1
fi

INJECTOR_PATH="$NPM_GLOBAL_PATH/nodejs-process-proxy/socks5-agent-injector.js"
echo -e "${BLUE}Injector path: ${YELLOW}$INJECTOR_PATH${NC}"

# Verify the injector exists
if [ ! -f "$INJECTOR_PATH" ]; then
    echo -e "${RED}Error: Cannot find injector at $INJECTOR_PATH${NC}"
    echo -e "${RED}Please ensure nodejs-process-proxy is installed globally${NC}"
    exit 1
fi

# --- Determine Shell RC File ---
SHELL_RC=""
echo -e "${BLUE}Determining shell configuration file...${NC}"

if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
    echo -e "${GREEN}Detected Zsh environment: ${YELLOW}$SHELL_RC${NC}"
elif [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
    echo -e "${YELLOW}Found ${YELLOW}$SHELL_RC${NC}"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
    echo -e "${YELLOW}Found ${YELLOW}$SHELL_RC${NC}"
else
    echo -e "${YELLOW}No common shell configuration file found.${NC}"
    echo -e "${YELLOW}You can still use the 'np' command normally.${NC}"
    exit 0
fi

# --- Create np functions ---
NP_FUNCTIONS="
# Node.js Process Proxy - Shell Functions
# Added by nodejs-process-proxy postinstall
np() {
    local command=\$1
    local proxy_uri=\$2
    local enable_log=false
    local default_proxy=\"socks5://127.0.0.1:1086\"
    
    # Parse arguments
    case \"\$command\" in
        set)
            # Check for -log flag
            if [[ \"\$proxy_uri\" == \"-log\" ]]; then
                enable_log=true
                proxy_uri=\"\"
            elif [[ \"\$3\" == \"-log\" ]]; then
                enable_log=true
            fi
            
            # Use default proxy if none provided
            if [ -z \"\$proxy_uri\" ]; then
                proxy_uri=\"\$default_proxy\"
                echo -e \"\\033[0;33mNo proxy URI provided. Using default: \$proxy_uri\\033[0m\"
            fi
            
            # Set environment variables
            export NODEJS_GLOBAL_SOCKS5_PROXY=\"\$proxy_uri\"
            export NODE_OPTIONS=\"--require $INJECTOR_PATH\"
            
            if [ \"\$enable_log\" = true ]; then
                export NODEJS_PROXY_DEBUG_LOG=\"true\"
                echo -e \"\\033[0;32mDebug logging ENABLED\\033[0m\"
            fi
            
            echo -e \"\\033[0;32m✅ Node.js SOCKS5 proxy ENABLED: \\033[0;33m\$proxy_uri\\033[0m\"
            echo -e \"\\033[0;32mNODE_OPTIONS set to: \\033[0;33m\$NODE_OPTIONS\\033[0m\"
            
            # Run test to verify proxy is working
            echo \"\"
            echo -e \"\\033[0;34m🧪 Testing proxy configuration...\\033[0m\"
            local test_script=\"$NPM_GLOBAL_PATH/nodejs-process-proxy/test/test-proxy.js\"
            if [ -f \"\$test_script\" ]; then
                node \"\$test_script\"
                if [ \$? -eq 0 ]; then
                    echo \"\"
                    echo -e \"\\033[0;32m✅ Proxy test completed successfully!\\033[0m\"
                    echo -e \"\\033[0;34mYour proxy is now configured. All Node.js applications will use the proxy.\\033[0m\"
                else
                    echo \"\"
                    echo -e \"\\033[0;33m⚠️  Proxy test finished with warnings. Check the output above.\\033[0m\"
                fi
            else
                echo -e \"\\033[0;33m⚠️  Test script not found, skipping automatic test.\\033[0m\"
                echo -e \"\\033[0;34mYou can manually test with: node \$test_script\\033[0m\"
            fi
            ;;
        unset)
            unset NODEJS_GLOBAL_SOCKS5_PROXY
            unset NODE_OPTIONS
            unset NODEJS_PROXY_DEBUG_LOG
            echo -e \"\\033[0;32m✅ Node.js SOCKS5 proxy DISABLED\\033[0m\"
            ;;
        status)
            echo -e \"\\033[0;34mNode.js Process Proxy Status:\\033[0m\"
            echo \"\"
            if [ -n \"\$NODEJS_GLOBAL_SOCKS5_PROXY\" ]; then
                echo -e \"\\033[0;32m✓ SOCKS5 Proxy: \$NODEJS_GLOBAL_SOCKS5_PROXY\\033[0m\"
            else
                echo -e \"\\033[0;33m✗ SOCKS5 Proxy: Not set\\033[0m\"
            fi
            
            if [[ \"\$NODE_OPTIONS\" == *\"socks5-agent-injector.js\"* ]]; then
                echo -e \"\\033[0;32m✓ NODE_OPTIONS: \$NODE_OPTIONS\\033[0m\"
            else
                echo -e \"\\033[0;33m✗ NODE_OPTIONS: Not configured for proxy\\033[0m\"
            fi
            
            if [ \"\$NODEJS_PROXY_DEBUG_LOG\" = \"true\" ]; then
                echo -e \"\\033[0;32m✓ Debug Logging: ENABLED\\033[0m\"
            else
                echo -e \"\\033[0;33m✗ Debug Logging: DISABLED\\033[0m\"
            fi
            
            echo \"\"
            if [ -n \"\$NODEJS_GLOBAL_SOCKS5_PROXY\" ] && [[ \"\$NODE_OPTIONS\" == *\"socks5-agent-injector.js\"* ]]; then
                echo -e \"\\033[0;32mStatus: Proxy is ENABLED for Node.js applications\\033[0m\"
            else
                echo -e \"\\033[0;33mStatus: Proxy is DISABLED\\033[0m\"
            fi
            ;;
        help|--help|-h)
            echo -e \"\\033[0;34mNode.js Process SOCKS5 Proxy Manager\\033[0m\"
            echo -e \"\\033[0;33mUsage: np <command> [options]\\033[0m\"
            echo \"\"
            echo \"Commands:\"
            echo \"  set [proxy_uri] [-log]  Enable SOCKS5 proxy for Node.js processes\"
            echo \"                          Default: socks5://127.0.0.1:1086\"
            echo \"                          -log: Enable debug logging\"
            echo \"  unset                   Disable SOCKS5 proxy for Node.js processes\"
            echo \"  status                  Show current proxy status\"
            echo \"\"
            echo \"Examples:\"
            echo \"  np set\"
            echo \"  np set \\\"socks5://127.0.0.1:1080\\\"\"
            echo \"  np set -log\"
            echo \"  np set \\\"socks5://user:pass@proxy.com:1080\\\" -log\"
            echo \"  np unset\"
            echo \"  np status\"
            ;;
        *)
            echo -e \"\\033[0;31mUnknown command: \$command\\033[0m\"
            echo \"Run 'np help' for usage information.\"
            return 1
            ;;
    esac
}
"

# Check if functions already exist
if grep -q "Node.js Process Proxy - Shell Functions" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}np functions already exist in $SHELL_RC${NC}"
    echo -e "${YELLOW}To update, please manually remove the old block and run this script again${NC}"
else
    echo -e "${BLUE}Adding np functions to ${YELLOW}$SHELL_RC${NC}"
    echo "$NP_FUNCTIONS" >> "$SHELL_RC"
    echo -e "${GREEN}✅ np functions added to your shell configuration!${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Setup complete!${NC}"
echo ""
echo -e "${BLUE}Available commands (after restarting terminal or running 'source $SHELL_RC'):${NC}"
echo -e "  ${YELLOW}np set${NC}                 - Enable proxy with default settings"
echo -e "  ${YELLOW}np set -log${NC}            - Enable proxy with debug logging"
echo -e "  ${YELLOW}np set \"socks5://...\"${NC}  - Enable proxy with custom URI"
echo -e "  ${YELLOW}np unset${NC}               - Disable proxy"
echo -e "  ${YELLOW}np status${NC}              - Check proxy status"
echo -e "  ${YELLOW}np help${NC}                - Show help"
echo ""
echo -e "${BLUE}To use the functions immediately, run:${NC}"
echo -e "  ${YELLOW}source $SHELL_RC${NC}"
echo ""