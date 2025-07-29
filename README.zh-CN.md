
# Node.js 全局 SOCKS5 代理管理器

本项目为您提供了一种简单的方法，为所有 Node.js 应用程序设置**全局 SOCKS5 代理**，而无需修改任何项目代码。它通过使用 `NODE_OPTIONS` 环境变量，将代理代理注入到 Node.js 内置的 `http` 和 `https` 模块中来实现。

> **⚠️ 重要说明：**
> - **本工具需要您已有一个SOCKS5代理服务器（如Shadowsocks）** - 它不会为您创建或提供SOCKS5服务器
> - **仅影响Node.js应用程序** - 此代理配置仅影响Node.js进程，不会影响您的系统全局网络流量或其他应用程序（浏览器、curl等）

## 项目用途

**主要功能：**
- **网络代理管理**：为Node.js应用程序提供统一的SOCKS5代理解决方案
- **开发环境配置**：在需要通过代理访问外部资源的开发环境中使用  
- **网络请求路由**：自动将所有HTTP/HTTPS请求路由通过指定的SOCKS5代理服务器
- **透明代理注入**：无需修改现有代码，即可为任何Node.js项目添加代理功能

**适用场景：**
- 需要通过代理服务器访问外部API的开发环境
- 企业内网环境下的Node.js应用开发
- 需要隐藏真实IP地址的网络请求场景
- 测试不同网络环境下的应用行为
- 绕过网络限制或防火墙的开发需求

---

## 功能特性

* **全局范围**：代理适用于在已配置的终端会话中启动的任何 Node.js 进程。
* **无需代码更改**：您的 Node.js 项目保持原样，无需任何修改。
* **轻松控制**：简单的 `np set` 和 `np unset` 命令让您可以轻松开启和关闭代理。
* **SOCKS5 支持**：使用 `socks-proxy-agent` 提供稳定的 SOCKS5 代理处理能力，包括身份验证。

---

## 前提条件

* 系统已安装 **Node.js**（推荐 v14 或更高版本）和 **npm**。
* **一个正在运行的 SOCKS5 代理服务器**，并且您可以连接到它（例如：`socks5://127.0.0.1:1086`）。
    
    > **📋 注意：** 您必须已经设置并运行了自己的SOCKS5代理服务器。这可以是：
    > - 本地代理服务器（如 Shadowsocks、V2Ray、Clash 等）
    > - 远程 SOCKS5 代理服务
    > - 企业代理服务器
    > 
    > 本工具**不会**提供或创建SOCKS5服务器 - 它只是配置Node.js使用现有的代理服务器。

---

## 安装

使用 npm 全局安装：

```bash
npm install -g nodejs-process-proxy
```

就这么简单！安装程序会自动设置 shell 函数，重启终端或运行 `source ~/.zshrc`（或 `~/.bashrc`）后，`np` 命令将在您的终端中可用。

---

## 使用方法

安装完成后，您可以在终端中使用以下命令：

### 1. 启用代理

在当前终端会话中，为所有后续的 Node.js 进程激活全局 SOCKS5 代理：

```bash
np set "socks5://您的代理地址:端口"
```

**示例（使用默认本地代理）：**

```bash
np set "socks5://127.0.0.1:1086"
```

**示例（带身份验证，请替换 `user` 和 `pass`）：**

```bash
np set "socks5://user:pass@127.0.0.1:1086"
```

**示例（使用默认代理）：**

```bash
np set
```

**示例（启用调试日志）：**

```bash
np set -log
```

### 2. 禁用代理

在当前终端会话中，为所有后续的 Node.js 进程停用全局 SOCKS5 代理：

```bash
np unset
```

### 3. 检查状态

检查当前代理状态：

```bash
np status
```

### 4. 获取帮助

查看所有可用命令：

```bash
np help
```

### 5. Shell 集成（可选）

安装程序会自动将 shell 函数添加到您的 `~/.zshrc` 或 `~/.bashrc`。如果需要手动设置或在所有终端中持久化设置，您可以添加：

```bash
# 添加到 ~/.bashrc 或 ~/.zshrc
export NODEJS_GLOBAL_SOCKS5_PROXY="socks5://127.0.0.1:1086"
export NODE_OPTIONS="--require $(npm root -g)/nodejs-process-proxy/socks5-agent-injector.js"
```

---

## 测试代理

本包包含一个综合测试脚本来验证代理是否正常工作：

1. **启用带调试日志的代理**：
   ```bash
   np set -log
   ```

2. **运行测试脚本**：
   ```bash
   node $(npm root -g)/nodejs-process-proxy/test/test-proxy.js
   ```

3. **预期结果**：
   - 测试将检查 HTTP、HTTPS 和 Fetch API 请求
   - 所有方法都应返回您的**代理服务器的公共 IP**，而不是您的原始 IP
   - 调试日志将显示请求通过代理路由
   - 将显示位置信息

4. **测试不使用代理的情况**：
   ```bash
   np unset
   node $(npm root -g)/nodejs-process-proxy/test/test-proxy.js
   ```
   这应该显示您的原始 IP 地址。

您也可以使用 Node.js 的标准 `http`、`https` 模块或 `fetch()` API 创建自己的测试脚本来验证代理功能。

---

## 工作原理

* **`npm install -g`**：全局安装包，使 `np` 命令在系统范围内可用。
* **`np set`**：
  * 将 `NODEJS_GLOBAL_SOCKS5_PROXY` 环境变量设置为您指定的代理地址。
  * 将 `NODE_OPTIONS` 环境变量设置为 `--require /path/to/socks5-agent-injector.js`。
  * 提供 shell 命令以使设置持久化。
* **`NODE_OPTIONS`**：这个强大的 Node.js 环境变量告诉 Node.js 在任何其他应用程序代码运行*之前*加载 `socks5-agent-injector.js`。
* **`socks5-agent-injector.js`**：
  * 读取 `NODEJS_GLOBAL_SOCKS5_PROXY` 变量。
  * 使用此 URI 创建一个 `SocksProxyAgent` 实例。
  * **关键是，它将 `http.globalAgent` 和 `https.globalAgent` 设置为此 `SocksProxyAgent` 实例。** 这确保任何 Node.js `http.get`、`https.get` 或 `http/https.request` 调用（没有明确指定自己的 `agent`）将自动通过您的 SOCKS5 代理路由。
* **`np unset`**：取消设置 `NODEJS_GLOBAL_SOCKS5_PROXY` 和 `NODE_OPTIONS` 环境变量，有效地为新的 Node.js 进程禁用代理。

---

## 故障排除

* **找不到 `np` 命令**：
  * 确保全局安装成功：`npm list -g nodejs-process-proxy`
  * 尝试重新安装：`npm install -g nodejs-process-proxy`
  * 重启终端或运行 `source ~/.zshrc`（或 `~/.bashrc`）
* **IP 地址没有改变**：
  * **验证您的 SOCKS5 代理服务器正在运行并可在指定的地址/端口上访问**。使用 `curl -x socks5h://your.proxy.address:port https://ipv4.icanhazip.com` 进行独立测试。
  * 确保您在运行 Node.js 应用程序的**同一终端会话**中运行了 `np set`。
  * 检查 `install.sh` 期间或 `node` 启动时是否有任何错误（查找 `[Node.js Global Proxy]` 消息）。
  * 如果您的代理需要身份验证，请确保 `np set` 命令在 URI 中包含 `user:pass@` 部分。
* **`ReferenceError: require is not defined`**：您的 Node.js 环境正在 ES Module (ESM) 模式下运行。`socks5-agent-injector.js` 文件已针对此进行了调整（使用 `import`）。确保您使用的是我们之前讨论中提供的最新版本的 `socks5-agent-injector.js`。
* **性能警告（`MODULE_TYPELESS_PACKAGE_JSON`）**：这是一个警告，不是错误。要删除它，请在项目根目录的 `package.json` 文件中添加 `"type": "module"`。

---

如果您遇到任何其他问题，请随时在 GitHub 上提出 issue！
