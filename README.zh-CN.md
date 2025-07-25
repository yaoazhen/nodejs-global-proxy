
---

## `zh-cn.md` (Simplified Chinese Usage Instructions)

```markdown
# Node.js 全局 SOCKS5 代理管理器

本项目提供了一种简单的方法，为所有 Node.js 应用程序设置全局 SOCKS5 代理，而无需修改单个项目的代码。它通过使用 `NODE_OPTIONS` 环境变量，将代理代理注入到 Node.js 内置的 `http` 和 `https` 模块中来实现。

---

## 功能特性

* **全局范围**：代理适用于在已配置的终端会话中启动的任何 Node.js 进程。
* **无需代码更改**：您的 Node.js 项目代码无需做任何修改。
* **轻松控制**：提供简单的 `nodesetproxy` 和 `nodeunsetproxy` 命令进行激活/停用。
* **SOCKS5 支持**：利用 `socks-proxy-agent` 库提供稳定的 SOCKS5 代理处理能力，包括认证。

---

## 前提条件

* 系统已安装 **Node.js**（推荐 v14 或更高版本）和 **npm**。
* 一个**正在运行的 SOCKS5 代理服务器**，并且您可以连接到它（例如：`socks5://127.0.0.1:1086`）。

---

## 安装

1.  **克隆此仓库**到您的本地机器：
    ```bash
    git clone [https://github.com/your-username/your-repo-name.git](https://github.com/your-username/your-repo-name.git)
    cd your-repo-name
    ```
    （请将 `your-username/your-repo-name` 替换为您的实际 GitHub 仓库路径。）

2.  **运行安装脚本**：
    此脚本将设置必要的 Node.js 模块（`socks-proxy-agent`），并在您的 `~/.zshrc`（或 `~/.bashrc`）中配置 shell 函数（`nodesetproxy` 和 `nodeunsetproxy`）。

    ```bash
    chmod +x install.sh
    ./install.sh
    ```
    * 脚本将检测您的 shell 类型（`.zshrc` 或 `.bashrc`）并将函数添加到其中。
    * 如果您之前运行过，可能会看到 `package.json already exists. Skipping npm init.`，这是正常现象。

3.  **重新加载您的 shell 配置**：
    打开一个**新的终端窗口/标签页**，或者运行：
    ```bash
    source ~/.zshrc  # 如果您使用 Zsh
    # 或者
    source ~/.bashrc # 如果您使用 Bash
    ```
    此步骤对于 `nodesetproxy` 和 `nodeunsetproxy` 命令在您当前终端会话中可用至关重要。

---

## 使用方法

安装完成后并重新加载 shell 后，您可以在终端中使用以下命令：

### 1. 启用代理

在当前终端会话中，为所有后续的 Node.js 进程激活全局 SOCKS5 代理：

```bash
nodesetproxy "socks5://您的代理地址:端口"
