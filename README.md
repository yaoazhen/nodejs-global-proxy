-----

# Node.js Process SOCKS5 Proxy Manager

This project gives you a simple way to set up a **SOCKS5 proxy for Node.js processes** without touching any project code. It works by injecting a proxy agent into Node.js's built-in `http` and `https` modules using the `NODE_OPTIONS` environment variable.

> **⚠️ Important Notes:**
> - **This tool requires an existing SOCKS5 proxy server like Shadowsocks** - it does NOT create or provide a SOCKS5 server for you
> - **Node.js applications only** - this proxy configuration affects ONLY Node.js processes, not your system-wide network traffic or other applications (browsers, curl, etc.)

## Project Purpose

**Main Use Cases:**
- **Network Proxy Management**: Provides a unified SOCKS5 proxy solution for Node.js applications
- **Development Environment Setup**: Essential for development environments that need to access external resources through a proxy
- **Network Request Routing**: Automatically routes all HTTP/HTTPS requests through a specified SOCKS5 proxy server
- **Transparent Proxy Injection**: Adds proxy functionality to any Node.js project without modifying existing code

**Ideal Scenarios:**
- Development environments requiring proxy server access to external APIs
- Node.js application development in corporate intranet environments
- Network request scenarios requiring IP address masking
- Testing application behavior under different network conditions
- Bypassing network restrictions or firewalls during development

-----

## Features

  * **Process Scope**: The proxy applies to any Node.js process you start in the configured terminal session.
  * **No Code Changes**: Your Node.js projects stay exactly as they are.
  * **Easy Control**: Simple `np set` and `np unset` commands let you turn the proxy on and off.
  * **SOCKS5 Support**: It uses `socks-proxy-agent` for robust SOCKS5 proxy handling, including authentication.

-----

## Prerequisites

  * **Node.js** (v14 or higher recommended) and **npm** installed on your system.
  * **A running SOCKS5 proxy server** that you can connect to (e.g., `socks5://127.0.0.1:1086`).
    
    > **📋 Note:** You must have your own SOCKS5 proxy server already set up and running. This could be:
    > - A local proxy server (like Shadowsocks, V2Ray, Clash, etc.)
    > - A remote SOCKS5 proxy service
    > - A corporate proxy server
    > 
    > This tool does **NOT** provide or create a SOCKS5 server - it only configures Node.js to use an existing one.

-----

## Installation

Install globally using npm:

```bash
npm install -g nodejs-process-proxy
```

That's it! The installation will automatically set up shell functions, and the `np` command will be available in your terminal after restarting it or running `source ~/.zshrc` (or `~/.bashrc`).

-----

## Usage

After installation, you can use the following commands in your terminal:

### 1. Enable the Proxy

To activate the global SOCKS5 proxy for all subsequent Node.js processes in the current terminal session:

```bash
np set "socks5://your.proxy.address:port"
```

**Example (using default local proxy):**

```bash
np set "socks5://127.0.0.1:1086"
```

**Example (with authentication, replace `user` and `pass`):**

```bash
np set "socks5://user:pass@127.0.0.1:1086"
```

**Example (using default proxy):**

```bash
np set
```

**Example (with debug logging):**

```bash
np set -log
```

### 2. Disable the Proxy

To deactivate the global SOCKS5 proxy for all subsequent Node.js processes in the current terminal session:

```bash
np unset
```

### 3. Check Status

To check the current proxy status:

```bash
np status
```

### 4. Get Help

To see all available commands:

```bash
np help
```

### 5. Shell Integration (Optional)

The installation automatically adds shell functions to your `~/.zshrc` or `~/.bashrc`. If you need to set up manually or for persistent settings across all terminals, you can add:

```bash
# Add to ~/.bashrc or ~/.zshrc
export NODEJS_GLOBAL_SOCKS5_PROXY="socks5://127.0.0.1:1086"
export NODE_OPTIONS="--require $(npm root -g)/nodejs-process-proxy/socks5-agent-injector.js"
```

-----

## Testing the Proxy

The package includes a comprehensive test script to verify that your proxy is working correctly:

1.  **Enable the proxy with debug logging**:
    ```bash
    np set -log
    ```

2.  **Run the test script**:
    ```bash
    node $(npm root -g)/nodejs-process-proxy/test/test-proxy.js
    ```

3.  **Expected Outcome**: 
    - The test will check HTTP, HTTPS, and Fetch API requests
    - All methods should return your **proxy server's public IP**, not your original IP
    - Debug logs will show requests being routed through the proxy
    - Location information will be displayed

4.  **Test without proxy**:
    ```bash
    np unset
    node $(npm root -g)/nodejs-process-proxy/test/test-proxy.js
    ```
    This should show your original IP address.

You can also create your own test script using Node.js's standard `http`, `https` modules or `fetch()` API to verify the proxy functionality.

-----

## How It Works

  * **`npm install -g`**: Installs the package globally, making the `np` command available system-wide.
  * **`np set`**:
      * Sets the `NODEJS_GLOBAL_SOCKS5_PROXY` environment variable to your specified proxy address.
      * Sets the `NODE_OPTIONS` environment variable to `--require /path/to/socks5-agent-injector.js`.
      * Provides shell commands to make the settings persistent.
  * **`NODE_OPTIONS`**: This powerful Node.js environment variable tells Node.js to load `socks5-agent-injector.js` *before* any other application code runs.
  * **`socks5-agent-injector.js`**:
      * Reads the `NODEJS_GLOBAL_SOCKS5_PROXY` variable.
      * Creates a `SocksProxyAgent` instance using this URI.
      * **Crucially, it sets `http.globalAgent` and `https.globalAgent` to this `SocksProxyAgent` instance.** This ensures that any Node.js `http.get`, `https.get`, or `http/https.request` calls (that don't explicitly specify their own `agent`) will automatically route through your SOCKS5 proxy.
  * **`np unset`**: Unsets the `NODEJS_GLOBAL_SOCKS5_PROXY` and `NODE_OPTIONS` environment variables, effectively disabling the proxy for new Node.js processes.

-----

## Troubleshooting

  * **`np` command not found**: 
      * Make sure the global installation was successful: `npm list -g nodejs-process-proxy`
      * Try reinstalling: `npm install -g nodejs-process-proxy`
      * Restart your terminal or run `source ~/.zshrc` (or `~/.bashrc`)
  * **IP address not changing**:
      * **Verify your SOCKS5 proxy server is running and accessible** on the specified address/port. Use `curl -x socks5h://your.proxy.address:port https://ipv4.icanhazip.com` to test independently.
      * Check current status: `np status`
      * Ensure you set the proxy in the **same terminal session** where you're running your Node.js app.
      * Check for any errors when `node` starts (look for `[Node.js Global Proxy]` messages).
      * If your proxy requires authentication, make sure the `np set` command includes the `user:pass@` part in the URI.
  * **Permission errors during installation**: Try using `sudo npm install -g nodejs-process-proxy` (on macOS/Linux) or run your terminal as administrator (on Windows).
  * **Environment variables not persisting**: Use the shell integration commands provided by `np set` to make settings permanent.

-----

Feel free to open an issue on GitHub if you hit any further snags\!