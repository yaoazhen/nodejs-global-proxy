#!/bin/bash

# Define colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Node.js Global SOCKS5 Proxy Manager installation...${NC}"

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_NAME=$(basename "$SCRIPT_DIR")
INSTALL_PATH="$SCRIPT_DIR"

echo -e "${BLUE}Project directory: ${YELLOW}$INSTALL_PATH${NC}"

# Check for Node.js and npm
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed. Please install npm first.${NC}"
    exit 1
fi
echo -e "${GREEN}Node.js and npm found.${NC}"

# Check for package.json and create if not exists (for npm install socks-proxy-agent)
if [ ! -f "$INSTALL_PATH/package.json" ]; then
    echo -e "${YELLOW}package.json not found. Creating a new one...${NC}"
    npm init -y --prefix "$INSTALL_PATH" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create package.json. Check npm permissions.${NC}"
        exit 1
    fi
    echo -e "${GREEN}package.json created successfully.${NC}"
else
    echo -e "${YELLOW}package.json already exists. Skipping npm init.${NC}"
fi

# Install socks-proxy-agent
echo -e "${BLUE}Installing 'socks-proxy-agent'...${NC}"
npm install socks-proxy-agent --prefix "$INSTALL_PATH" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install 'socks-proxy-agent'. Check npm or network connection.${NC}"
    exit 1
fi
echo -e "${GREEN}'socks-proxy-agent' installed successfully.${NC}"

# Define the shell configuration file
SHELL_RC=""
if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_RC="$HOME/.bashrc"
else
    echo -e "${YELLOW}Warning: Neither .zshrc nor .bashrc detected. Please manually add functions to your shell config.${NC}"
    exit 0
fi

if [ -z "$SHELL_RC" ]; then
    echo -e "${RED}Error: Could not determine shell configuration file. Please manually add functions.${NC}"
    exit 1
fi

echo -e "${BLUE}Configuring shell functions in ${YELLOW}$SHELL_RC${NC} ...${NC}"

# Define the functions to be added
NODESETPROXY_FUNC="
# Node.js Global SOCKS5 Proxy Management
# Added by node-global-proxy install.sh
nodesetproxy() {
    if [ -z \"\$1\" ]; then
        echo -e \"${RED}Usage: nodesetproxy \\\"socks5://your.proxy.address:port\\\"${NC}\"
        return 1
    fi
    export NODEJS_GLOBAL_SOCKS5_PROXY=\"\$1\"
    export NODE_OPTIONS=\"--require $INSTALL_PATH/socks5-agent-injector.js\"
    echo -e \"${GREEN}Node.js global SOCKS5 proxy ENABLED to: ${YELLOW}\$NODEJS_GLOBAL_SOCKS5_PROXY${NC}\"
    echo -e \"${GREEN}NODE_OPTIONS set to: ${YELLOW}\$NODE_OPTIONS${NC}\"
}

nodeunsetproxy() {
    unset NODEJS_GLOBAL_SOCKS5_PROXY
    unset NODE_OPTIONS
    echo -e \"${GREEN}Node.js global SOCKS5 proxy DISABLED.${NC}\"
}"

# Check if functions already exist and add/update them
if grep -q "Node.js Global SOCKS5 Proxy Management" "$SHELL_RC"; then
    echo -e "${YELLOW}Updating existing 'nodesetproxy' and 'nodeunsetproxy' functions in $SHELL_RC...${NC}"
    # Remove old functions
    sed -i '' '/^# Node.js Global SOCKS5 Proxy Management/,/^}/d' "$SHELL_RC" 2>/dev/null || \
    sed -i '/^# Node.js Global SOCKS5 Proxy Management/,/^}/d' "$SHELL_RC"
else
    echo -e "${BLUE}Adding 'nodesetproxy' and 'nodeunsetproxy' functions to $SHELL_RC...${NC}"
fi

echo "$NODESETPROXY_FUNC" >> "$SHELL_RC"
echo -e "${GREEN}Functions 'nodesetproxy' and 'nodeunsetproxy' added/updated in $SHELL_RC.${NC}"

# --- AUTOMATIC TEST AFTER INSTALLATION ---
echo -e "\n${BLUE}Installation complete! Now performing an automatic test...${NC}"

# Source the RC file to make the new functions available in the current script context
# This is crucial for nodesetproxy to be recognized immediately
source "$SHELL_RC"

# Check if get-ip.js exists
GET_IP_JS_PATH="$SCRIPT_DIR/get-ip.js"
if [ ! -f "$GET_IP_JS_PATH" ]; then
    echo -e "${YELLOW}Warning: '${GET_IP_JS_PATH}' not found. Skipping automatic IP test.${NC}"
    echo -e "${YELLOW}Please create 'get-ip.js' or use your own Node.js script to test.${NC}"
    echo -e "${YELLOW}Remember to run 'source $SHELL_RC' in new terminals to use 'nodesetproxy'.${NC}"
else
    echo -e "${BLUE}Attempting to enable proxy and run test script...${NC}"
    
    # Run nodesetproxy with a common default
    # User might need to run it manually later if their proxy is different
    nodesetproxy "socks5://127.0.0.1:1086"

    # Run the test script
    echo -e "${BLUE}Running 'node get-ip.js' to check public IP via proxy...${NC}"
    node "$GET_IP_JS_PATH"
    echo -e "${BLUE}Automatic test finished.${NC}"
fi

echo -e "\n${GREEN}Please remember to run 'source $SHELL_RC' or open a new terminal window/tab${NC}"
echo -e "${GREEN}to use the 'nodesetproxy' and 'nodeunsetproxy' commands for your Node.js projects.${NC}"
echo -e "${BLUE}Thank you for using Node.js Global SOCKS5 Proxy Manager!${NC}"