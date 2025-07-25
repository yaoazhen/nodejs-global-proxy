-----

# Node.js Global SOCKS5 Proxy Manager

This project gives you a simple way to set up a **global SOCKS5 proxy** for all your Node.js apps without touching any project code. It works by injecting a proxy agent into Node.js's built-in `http` and `https` modules using the `NODE_OPTIONS` environment variable.

-----

## Features

  * **Global Scope**: The proxy applies to any Node.js process you start in the configured terminal session.
  * **No Code Changes**: Your Node.js projects stay exactly as they are.
  * **Easy Control**: Simple `np set` and `np unset` commands let you turn the proxy on and off.
  * **SOCKS5 Support**: It uses `socks-proxy-agent` for robust SOCKS5 proxy handling, including authentication.

-----

## Prerequisites

  * **Node.js** (v14 or higher recommended) and **npm** installed on your system.
  * A **running SOCKS5 proxy server** that you can connect to (e.g., `socks5://127.0.0.1:1086`).

-----

## Installation

1.  **Clone this repository** to your local machine:

    ```bash
    git clone https://github.com/your-username/your-repo-name.git
    cd your-repo-name
    ```

    (Replace `your-username/your-repo-name` with your actual GitHub repository path.)

2.  **Run the installation script**:
    This script will set up the necessary Node.js module (`socks-proxy-agent`) and configure shell functions (`np`) in your `~/.zshrc` (or `~/.bashrc`).

    ```bash
    chmod +x install.sh
    ./install.sh
    ```

      * The script will detect your shell (`.zshrc` or `.bashrc`) and add the functions there.
      * You might see `package.json already exists. Skipping npm init.` if you've run it before; this is normal.

3.  **Reload your shell configuration**:
    Open a **new terminal window/tab**, or run:

    ```bash
    source ~/.zshrc  # If you use Zsh
    # OR
    source ~/.bashrc # If you use Bash
    ```

    This step is essential for the `np` command to become available in your current terminal session.

-----

## Usage

Once installed and your shell reloaded, you can use the following commands in your terminal:

### 1\. Enable the Proxy

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

You'll see a confirmation message indicating the proxy is enabled.

### 2\. Disable the Proxy

To deactivate the global SOCKS5 proxy for all subsequent Node.js processes in the current terminal session:

```bash
np unset
```

You'll see a confirmation message indicating the proxy is disabled.

-----

## Testing the Proxy

To confirm that your Node.js applications are routing traffic through the proxy, you can use your existing `get-ip.js` file (or any other Node.js script that makes HTTP/HTTPS requests to the public internet).

1.  **Ensure your `get-ip.js` (or similar) file is ready**:
    Make sure your `get-ip.js` file uses Node.js's standard `http` or `https` modules to fetch a public IP address (e.g., from `https://ipv4.icanhazip.com`).

2.  **Run your test script** in the **same terminal session** where you enabled the proxy:

    ```bash
    node /path/to/your/get-ip.js
    ```

    (Replace `/path/to/your/get-ip.js` with the actual path to your file, or navigate to its directory first.)

3.  **Expected Outcome**: If the proxy is working correctly, the outputted IP address should be your **proxy server's public IP**, not your original direct IP. If it shows your original IP, the proxy isn't being used by Node.js.

-----

## How It Works

  * **`install.sh`**: Sets up the project directory, installs `socks-proxy-agent`, and adds the `np` shell function to your `~/.zshrc` (or `~/.bashrc`).
  * **`np set`**:
      * Sets the `NODEJS_GLOBAL_SOCKS5_PROXY` environment variable to your specified proxy address.
      * Sets the `NODE_OPTIONS` environment variable to `--require /path/to/this/repo/socks5-agent-injector.js`.
  * **`NODE_OPTIONS`**: This powerful Node.js environment variable tells Node.js to load `socks5-agent-injector.js` *before* any other application code runs.
  * **`socks5-agent-injector.js`**:
      * Reads the `NODEJS_GLOBAL_SOCKS5_PROXY` variable.
      * Creates a `SocksProxyAgent` instance using this URI.
      * **Crucially, it sets `http.globalAgent` and `https.globalAgent` to this `SocksProxyAgent` instance.** This ensures that any Node.js `http.get`, `https.get`, or `http/https.request` calls (that don't explicitly specify their own `agent`) will automatically route through your SOCKS5 proxy.
  * **`np unset`**: Unsets the `NODEJS_GLOBAL_SOCKS5_PROXY` and `NODE_OPTIONS` environment variables, effectively disabling the proxy for new Node.js processes.

-----

## Troubleshooting

  * **`np` command not found**: Make sure you ran `source ~/.zshrc` (or `~/.bashrc`) or opened a new terminal after installation.
  * **IP address not changing**:
      * **Verify your SOCKS5 proxy server is running and accessible** on the specified address/port. Use `curl -x socks5h://your.proxy.address:port https://ipv4.icanhazip.com` to test independently.
      * Ensure you ran `np set` in the **same terminal session** where you're running your Node.js app.
      * Check for any errors during `install.sh` or when `node` starts (look for `[Node.js Global Proxy]` messages).
      * If your proxy requires authentication, make sure the `np set` command includes the `user:pass@` part in the URI.
  * **`ReferenceError: require is not defined`**: Your Node.js environment is running in ES Module (ESM) mode. The `socks5-agent-injector.js` file has been adjusted for this (using `import`). Make sure you're using the latest version of `socks5-agent-injector.js` provided in our previous discussion.
  * **Performance Warning (`MODULE_TYPELESS_PACKAGE_JSON`)**: This is a warning, not an error. To remove it, add `"type": "module"` to your `package.json` file in the project root.

-----

Feel free to open an issue on GitHub if you hit any further snags\!