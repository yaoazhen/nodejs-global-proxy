#!/bin/bash

# Define colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Node.js Global SOCKS5 Proxy Manager installation...${NC}"

# --- CRITICAL SHELL CHECK ---
# Ensure this script is run in Zsh if the user's default shell is Zsh.
# Oh My Zsh-related errors indicate the script is being executed by bash.
if [[ -n "$ZSH_VERSION" ]]; then
    echo -e "${GREEN}Detected Zsh environment for script execution.${NC}"
elif [[ -n "$BASH_VERSION" ]]; then
    echo -e "${RED}WARNING: This script is running in Bash, but your default shell appears to be Zsh.${NC}"
    echo -e "${RED}If you are using Oh My Zsh, please run this script by *sourcing* it directly in your Zsh terminal, like this:${NC}"
    echo -e "${YELLOW}    source ./install.sh${NC}"
    echo -e "${RED}This ensures the Zsh environment variables (like ZSH_VERSION) are correctly set for the script.${NC}"
else
    echo -e "${YELLOW}Warning: Could not reliably detect Zsh or Bash version during script execution.${NC}"
fi


# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
INSTALL_PATH="$SCRIPT_DIR" # This correctly gets the absolute path

echo -e "${BLUE}Project directory: ${YELLOW}$INSTALL_PATH${NC}"

# --- Prerequisites Check ---
echo -e "${BLUE}Checking for Node.js and npm...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed. Please install Node.js first.${NC}"
    exit 1
fi
if ! command -v npm &> /dev/null; then
    echo -e "${RED}Error: npm is not installed. Please install npm first.${NC}"
    exit 1
fi
echo -e "${GREEN}Node.js and npm found.${NC}"

# --- package.json Setup ---
echo -e "${BLUE}Checking/creating package.json...${NC}"
if [ ! -f "$INSTALL_PATH/package.json" ]; then
    echo -e "${YELLOW}package.json not found. Creating a new one...${NC}"
    npm init -y --prefix "$INSTALL_PATH" > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create package.json. Check npm permissions or try again.${NC}"
        exit 1
    fi
    echo -e "${GREEN}package.json created successfully.${NC}"
else
    echo -e "${YELLOW}package.json already exists. Skipping npm init.${NC}"
fi

# --- Install socks-proxy-agent ---
echo -e "${BLUE}Installing 'socks-proxy-agent'...${NC}"
npm install socks-proxy-agent --prefix "$INSTALL_PATH" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install 'socks-proxy-agent'. Check npm or network connection.${NC}"
    exit 1
fi
echo -e "${GREEN}'socks-proxy-agent' installed successfully.${NC}"

# --- Determine Shell RC File ---
# Force .zshrc if Zsh is detected, otherwise fallback to .bashrc
SHELL_RC=""
echo -e "${BLUE}Determining shell configuration file...${NC}"

if [ -n "$ZSH_VERSION" ]; then
    SHELL_RC="$HOME/.zshrc"
    echo -e "${GREEN}Confidently setting shell configuration file to: ${YELLOW}$SHELL_RC${NC} (due to ZSH_VERSION detection).${NC}"
elif [ -f "$HOME/.zshrc" ]; then # Fallback to check for .zshrc file existence
    SHELL_RC="$HOME/.zshrc"
    echo -e "${YELLOW}ZSH_VERSION not set, but found ${YELLOW}~/.zshrc${YELLOW}. Setting shell configuration file to: ${YELLOW}$SHELL_RC${NC}.${NC}"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
    echo -e "${YELLOW}Neither ZSH_VERSION nor ~/.zshrc found. Falling back to ~/.bashrc. Setting shell configuration file to: ${YELLOW}$SHELL_RC${NC}.${NC}"
else
    echo -e "${RED}Error: Cannot find a common shell configuration file (~/.zshrc or ~/.bashrc).${NC}"
    echo -e "${RED}Please ensure your shell configuration file exists or manually add the 'np' function.${NC}"
    exit 1
fi

if [ -z "$SHELL_RC" ]; then
    echo -e "${RED}Fatal Error: \$SHELL_RC variable is empty after detection logic. Cannot proceed.${NC}"
    exit 1
fi

# --- Define the 'np' function ---
# Using EOF marker for a more robust multi-line string definition.
# IMPORTANT: $INSTALL_PATH is expanded here to embed the absolute path directly into the function string.
read -r -d '' NP_FUNC << EOF
# Node.js Global SOCKS5 Proxy Management - START
# Added by node-global-proxy install.sh
np() {
    local command=\$1
    local proxy_uri=\$2
    local default_proxy_uri="socks5://127.0.0.1:1086"

    # The absolute path to the project directory is automatically set during installation.
    local PROJECT_INSTALL_PATH="$INSTALL_PATH" 

    case "\$command" in
        set)
            if [ -z "\$proxy_uri" ]; then
                proxy_uri="\$default_proxy_uri"
                echo -e "${YELLOW}No proxy URI provided. Using default: \${proxy_uri}${NC}"
            fi
            export NODEJS_GLOBAL_SOCKS5_PROXY="\$proxy_uri"
            export NODE_OPTIONS="--require \$PROJECT_INSTALL_PATH/socks5-agent-injector.js"
            echo -e "${GREEN}Node.js global SOCKS5 proxy ENABLED to: ${YELLOW}\$NODEJS_GLOBAL_SOCKS5_PROXY${NC}"
            echo -e "${GREEN}NODE_OPTIONS set to: ${YELLOW}\$NODE_OPTIONS${NC}"
            ;;
        unset)
            unset NODEJS_GLOBAL_SOCKS5_PROXY
            unset NODE_OPTIONS
            echo -e "${GREEN}Node.js global SOCKS5 proxy DISABLED.${NC}"
            ;;
        *)
            echo -e "${RED}Usage: np {set|unset} [proxy_uri]${NC}"
            echo -e "${RED}Example: np set \\"socks5://127.0.0.1:1086\\"${NC}"
            echo -e "${RED}Example: np set (uses default 127.0.0.1:1086)${NC}"
            return 1
            ;;
    esac
}
# Node.js Global SOCKS5 Proxy Management - END
EOF

# --- Configure Shell Functions ---
echo -e "${BLUE}Attempting to configure 'np' shell function in ${YELLOW}$SHELL_RC${NC} ...${NC}"

# Detect which sed to use (GNU sed vs BSD sed)
SED_INPLACE_OPTION=""
if command -v gsed &> /dev/null; then
    SED_CMD="gsed"
    SED_INPLACE_OPTION="-i"
    echo -e "${BLUE}Using gsed (GNU sed) for file modifications.${NC}"
elif sed --version >/dev/null 2>&1 | grep -q "GNU\|Free Software Foundation"; then
    SED_CMD="sed"
    SED_INPLACE_OPTION="-i"
    echo -e "${BLUE}Using GNU sed for file modifications.${NC}"
else
    SED_CMD="sed"
    SED_INPLACE_OPTION="-i ''" # BSD sed requires a backup extension (empty string for no backup)
    echo -e "${BLUE}Using BSD sed for file modifications.${NC}"
fi

# Check if functions already exist and add/update them
if grep -q "Node.js Global SOCKS5 Proxy Management - START" "$SHELL_RC"; then
    echo -e "${YELLOW}Warning: 'np' function block already exists in $SHELL_RC. ${NC}"
    echo -e "${YELLOW}To update, please manually remove the old block from $SHELL_RC (between START and END comments).${NC}"
    echo -e "${YELLOW}Then, run this script again (source ./install.sh) to append the new version.${NC}"
    echo -e "${YELLOW}Skipping automatic append to avoid duplicates.${NC}"
else
    # Append the new function block
    echo -e "${BLUE}Appending new 'np' function block to ${YELLOW}$SHELL_RC${BLUE}...${NC}"
    if ! echo "$NP_FUNC" >> "$SHELL_RC"; then
        echo -e "${RED}Error: Failed to append new 'np' function to $SHELL_RC. Check file permissions or disk space.${NC}"
        exit 1
    fi
    echo -e "${GREEN}Function 'np' successfully appended to $SHELL_RC.${NC}"
fi

# --- Verification Step ---
echo -e "\n${BLUE}Verifying content of ${YELLOW}$SHELL_RC${BLUE} after modification...${NC}"
if grep -q "Node.js Global SOCKS5 Proxy Management - START" "$SHELL_RC" && grep -q "Node.js Global SOCKS5 Proxy Management - END" "$SHELL_RC"; then
    echo -e "${GREEN}Verification successful: 'np' function block found in ${YELLOW}$SHELL_RC${GREEN}.${NC}"
else
    echo -e "${RED}Verification FAILED: 'np' function block NOT found in ${YELLOW}$SHELL_RC${RED}.${NC}"
    echo -e "${RED}This indicates a serious issue with writing to ${YELLOW}$SHELL_RC${RED}. Please check file permissions or manually add the function.${NC}"
fi

# --- Automatic Test After Installation ---
echo -e "\n${BLUE}Installation complete! Now performing an automatic test...${NC}"

# Source the RC file to make the new functions available in the current script context
# This is crucial for np to be recognized immediately
echo -e "${BLUE}Sourcing ${YELLOW}$SHELL_RC${BLUE} to load new functions for this script's context...${NC}"
source "$SHELL_RC" || { echo -e "${RED}Error: Failed to source ${YELLOW}$SHELL_RC${RED} within the script. Functions might not be available immediately for this test.${NC}"; }


# Check if get-ip.js exists
GET_IP_JS_PATH="$SCRIPT_DIR/get-ip.js"
if [ ! -f "$GET_IP_JS_PATH" ]; then
    echo -e "${YELLOW}Warning: '${GET_IP_JS_PATH}' not found. Skipping automatic IP test.${NC}"
    echo -e "${YELLOW}Please create 'get-ip.js' or use your own Node.js script to test.${NC}"
    echo -e "${YELLOW}Remember to run 'source ${YELLOW}$SHELL_RC${YELLOW}' in new terminals to use 'np'.${NC}"
else
    echo -e "${BLUE}Attempting to enable proxy and run test script...${NC}"
    
    # Run np set with no arguments, so it uses the default
    if ! np set; then
        echo -e "${RED}Error: 'np set' command failed during automatic test. Check previous messages.${NC}"
        # Do not exit, let the user see the IP test result anyway
    fi

    # Run the test script
    echo -e "${BLUE}Running 'node get-ip.js' to check public IP via proxy...${NC}"
    node "$GET_IP_JS_PATH"
    echo -e "${BLUE}Automatic test finished.${NC}"
    
    # It's generally good practice to unset the proxy after the automatic test
    echo -e "${BLUE}Unsetting proxy after automatic test...${NC}"
    np unset
fi

echo -e "\n${GREEN}Installation attempt complete.${NC}"
echo -e "${GREEN}Please remember to run 'source ${YELLOW}$SHELL_RC${YELLOW}' or open a new terminal window/tab${NC}"
echo -e "${GREEN}to use the 'np' command for your Node.js projects.${NC}"
echo -e "${BLUE}If 'np' function is still not visible after opening a new terminal, please provide the full output of this script.${NC}"
echo -e "${BLUE}Thank you for your patience!${NC}"