# P3TERX aria2.sh 深度分析与自动化运维指南

本报告旨在深入分析 `https://github.com/P3TERX/aria2.sh` 脚本的内部逻辑，并探讨其如何作为“运维外挂”与原版 Aria2 或 `aria2-unlock` 内核协同工作。

## 1. `install_aria2()` 逻辑深度分析

### 1.1 二进制下载源
脚本通过 `Download_aria2` 函数从以下地址获取二进制文件：
-   **项目库**: `https://github.com/P3TERX/Aria2-Pro-Core`
-   **构建方式**: 全静态编译 (Static Linux Build)，内置了最新版本的 `OpenSSL`, `c-ares`, `libssh2`, `jemalloc` 等依赖库。
-   **架构支持**: 自动识别并匹配 `amd64`, `arm64`, `armhf`, `i386`。

### 1.2 相比原版的内核级改动 (Diff)
`Aria2-Pro-Core` 相比官方原版 (Source Forge / GitHub Official) 进行了以下核心解锁：
1.  **解除连接数限制**: 官方原版硬编码 `max-connection-per-server` 上限为 16，Pro 版解锁至 **无限制 (实际推荐 64/128)**。
2.  **降低分段阈值**: 官方原版 `min-split-size` 最小为 1M，Pro 版降低至 **1K**，允许极小文件也能多线程下载。
3.  **激进重试机制**: 针对 HTTP `400`, `403`, `406` 等错误增加了自动重试逻辑，显著提升了网盘直链下载的成功率。
4.  **IO 与内存优化**: 针对高并发场景优化了磁盘 I/O 调度，降低了长任务下的内存抖动。

---

## 2. 集成功能实现机制映射

脚本通过多种系统级组件实现了高度自动化的下载体验：

| 集成功能 | 实现组件 | 具体触发机制 | 实现细节 |
| :--- | :--- | :--- | :--- |
| **BT Tracker 更新** | **Cron 任务** | `0 7 * * *` (每天早 7 点) | 调用 `tracker.sh` 从 `trackerslist.com` 获取最新列表并通过 RPC 更新 Aria2 配置。 |
| **Rclone 自动上传** | **Aria2 Hook** | `on-download-complete` | 下载完成后触发 `upload.sh`，读取 `rclone.env` 配置并调用 `rclone move` 上传至云端。 |
| **残余文件清理** | **Aria2 Hook** | `on-download-stop` & `complete` | 触发 `clean.sh` 或 `delete.sh`，删除 `.aria2` 状态文件、`.torrent` 种子及空目录。 |
| **自动任务调度** | **Aria2 Hook** | `on-download-error` | 触发 `clean.sh` 删除损坏的分片文件，防止磁盘溢出。 |
| **服务守护/自启** | **Init.d / LSB** | 系统启动/进程监控 | `/etc/init.d/aria2` 脚本负责进程存活检查与系统级生命周期管理。 |

---

## 3. “自动化运维外挂”使用方案

如果你已经安装了官方原版 Aria2 且不想替换二进制内核，可以将此脚本及其配置作为“运维外挂”：

### 3.1 非破坏性集成步骤
1.  **获取辅助脚本**: 只下载 `clean.sh`, `upload.sh`, `tracker.sh` 三个核心脚本至 `/root/.aria2c/`（或自定义目录）。
2.  **注入配置文件**: 在现有的 `aria2.conf` 中添加以下钩子配置：
    ```bash
    # 下载完成后自动清理与搬运
    on-download-complete=/root/.aria2c/clean.sh
    on-download-complete=/root/.aria2c/upload.sh
    # 停止/删除时清理
    on-download-stop=/root/.aria2c/delete.sh
    ```
3.  **手动配置 Cron**:
    ```bash
    # 每天自动更新 Tracker (注意替换路径)
    0 7 * * * /bin/bash /root/.aria2c/tracker.sh /path/to/aria2.conf RPC
    ```
4.  **环境适配**: 确保 `rclone.env` 中配置了正确的 remote 名称，即可在不更改 `aria2c` 主程序的情况下获得全部自动化运维能力。

---

## 4. 详细逻辑流程图描述

### 4.1 安装与环境初始化流程
1.  **[权限检查]**: 验证 root 权限。
2.  **[环境检测]**: 识别 OS 发行版 (CentOS/Debian/Ubuntu) 及 CPU 架构 (AMD64/ARM64)。
3.  **[依赖安装]**: 自动部署 `wget`, `curl`, `jq`, `ca-certificates`。
4.  **[二进制部署]**: 下载并解压 `Aria2-Pro-Core` 至 `/usr/local/bin/`。
5.  **[完美配置部署]**: 
    - 下载 `aria2.conf` 并自动生成随机 `rpc-secret`。
    - 自动配置下载目录权限。
6.  **[服务化]**: 安装 `init.d` 脚本并注册系统自启动。

### 4.2 任务执行闭环流程 (Download-Upload-Clean)
1.  **用户提交任务**: 通过 RPC 或种子文件。
2.  **多线程下载**: 使用 Pro 版内核，多线程全力拉取。
3.  **下载完成信号**: Aria2 核心发出 `on-download-complete` 事件。
4.  **触发清理逻辑**: 
    - 执行 `clean.sh`：删除 `.aria2` 状态文件，保留源文件。
5.  **触发上传逻辑**:
    - 执行 `upload.sh`：
        - 检查目标目录是否有空余空间。
        - 调用 `rclone` 进行后台搬运。
        - 搬运成功后删除本地源文件。
6.  **后续维护**:
    - `Cron` 每日定时更新 Tracker 列表。
    - `init.d` 确保后台进程全天候在线。

---
*本文档由 Gemini CLI 自动化生成，基于对 aria2.sh 源代码的深度逆向分析。*
