# Node.js Global SOCKS5 Proxy Manager

This project provides a simple way to set up a global SOCKS5 proxy for all your Node.js applications, without needing to modify individual project code. It works by injecting a proxy agent into Node.js's built-in `http` and `https` modules using the `NODE_OPTIONS` environment variable.

---

## Features

* **Global Scope**: Proxy applies to any Node.js process launched in the configured terminal session.
* **No Code Changes**: Your Node.js projects remain untouched.
* **Easy Control**: Simple `nodesetproxy` and `nodeunsetproxy` commands for activation/deactivation.
* **SOCKS5 Support**: Leverages `socks-proxy-agent` for robust SOCKS5 proxy handling, including authentication.

---

## Prerequisites

* **Node.js** (v14 or higher recommended) and **npm** installed on your system.
* A **running SOCKS5 proxy server** that you can connect to (e.g., `socks5://127.0.0.1:1086`).

---

## Installation

1.  **Clone this repository** to your local machine:
    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    cd your-repo-name
    ```
    (Replace `your-username/your-repo-name` with your actual GitHub repository path.)

2.  **Run the installation script**:
    This script will set up the necessary Node.js module (`socks-proxy-agent`) and configure shell functions (`nodesetproxy` and `nodeunsetproxy`) in your `~/.zshrc` (or `~/.bashrc`).

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
    This step is essential for the `nodesetproxy` and `nodeunsetproxy` commands to become available in your current terminal session.

---

## Usage

Once installed and your shell reloaded, you can use the following commands in your terminal:

### 1. Enable the Proxy

To activate the global SOCKS5 proxy for all subsequent Node.js processes in the current terminal session:

```bash
nodesetproxy "socks5://your.proxy.address:port"