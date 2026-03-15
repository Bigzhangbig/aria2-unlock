# Aria2 Pro Docker (P3TERX) 深度分析与复现报告

## 1. Dockerfile 关键层分析 (与官方/标准镜像对比)

P3TERX 的 `Aria2-Pro-Docker` 相比于简单的 Alpine+Aria2 镜像，在架构上做了如下“非标准”优化：

### A. 基础镜像与进程管理 (s6-overlay)
- **非标准操作**：采用 `p3terx/s6-alpine` 作为基座。
- **改动逻辑**：集成 `s6-overlay`，实现了容器内多进程管理（aria2 + crond）和优雅停机。
- **环境变量控制**：`S6_BEHAVIOUR_IF_STAGE2_FAILS=1` 确保初始化失败时直接报错退出，避免产生僵尸容器。

### B. 增强版内核安装
- **代码行 (Dockerfile)**：`curl -fsSL git.io/aria2c.sh | bash`
- **关键差异**：不使用官方发行版的 `apk add aria2`，而是下载作者预编译的静态二进制。该版本解锁了单服务器线程数上限（16 -> 无限制）和最小分段大小（1M -> 1K）。

### C. 动态配置加载逻辑
- **非标准路径**：`/etc/cont-init.d/08-config`
- **初始化流**：容器启动时，若检测到 `/config` 目录下无配置文件，会从 `https://p3terx.github.io/aria2.conf` 动态拉取最新的 `aria2.conf` 和配套脚本。这保证了用户始终获得最新的优化参数，而无需更新镜像镜像层。

---

## 2. 外部集成脚本逻辑流修改

这些脚本通过 `aria2.conf` 中的钩子（Hook）深度介入了 aria2 的原始逻辑流：

| 脚本名称 | 触发钩子 / 逻辑点 | 修改的逻辑流 | 核心功能 |
| :--- | :--- | :--- | :--- |
| **`clean.sh`** | `on-download-complete` | **后置处理流** | 任务完成后自动删除 `.aria2` 临时文件；根据设置自动移动文件。 |
| **`upload.sh`** | `on-download-complete` | **输出流扩展** | 完成后调用 `rclone move`。将 aria2 的“本地存储”逻辑流扩展为“下载 -> 上传 -> 本地清理”。 |
| **`delete.sh`** | `on-download-stop` | **任务终止流** | 手动删除或停止下载时，物理删除已下载的残留碎块，保持磁盘整洁。 |
| **`tracker.sh`**| `crond` / `init` | **前置配置流** | 定时从 API 拉取最新 Tracker 列表。通过 `sed` 命令动态更新 `aria2.conf` 中的 `bt-tracker` 参数，强制 aria2 重启或重新加载。 |
| **`core`** | (Internal Library) | **通用逻辑流** | 统筹 `CONVERSION_PATH`（路径转换）和环境变量加载，为所有脚本提供统一的基础函数。 |

---

## 3. 如何在原版 aria2 Docker 环境中复现

要在原版镜像（或自定义 Dockerfile）中实现上述功能，需执行以下核心步骤：

### 第一步：解锁内核限制 (编译阶段)
在原版仓库源码中修改 `src/OptionHandlerFactory.cc`：
```cpp
// 约 439 行：解锁单服务器最大线程数 (max-connection-per-server)
// 将原本的 16 修改为 -1 (代表无限制)
OptionHandler* op(new NumberOptionHandler(PREF_MAX_CONNECTION_PER_SERVER,
                                          TEXT_MAX_CONNECTION_PER_SERVER,
                                          "1", 1, -1, 'x'));

// 约 502 行：降低最小分段大小 (min-split-size)
// 将原本的 1_m (1MB) 修改为 1_k (1KB)，并调整默认值为 "1K"
OptionHandler* op(new UnitNumberOptionHandler(
        PREF_MIN_SPLIT_SIZE, TEXT_MIN_SPLIT_SIZE, "1K", 1_k, 1_g, 'k'));
```

### 第二步：引入 s6-overlay 初始化脚本
在 Dockerfile 中添加：
```dockerfile
# 安装 s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/v2.2.0.3/s6-overlay-amd64.tar.gz /tmp/
RUN tar xzf /tmp/s6-overlay-amd64.tar.gz -C /

# 编写 init 脚本 (rootfs/etc/cont-init.d/08-config)
# 逻辑：下载 P3TERX 的核心脚本
RUN mkdir -p /config/script && \
    curl -fsSL https://raw.githubusercontent.com/P3TERX/aria2.conf/master/clean.sh -o /config/script/clean.sh && \
    chmod +x /config/script/clean.sh
```

### 第三步：配置钩子联动
在 `aria2.conf` 中显式指定：
```conf
# 任务完成后触发清理/上传脚本
on-download-complete=/config/script/clean.sh
# 任务停止后触发删除逻辑
on-download-stop=/config/script/delete.sh
```

---

## 4. 优化总结
P3TERX 的方案本质上是**“增强版内核 + 自动化脚本外挂 + 严谨的权限管理”**。
- **内核层**：解决了“能下多快”的问题。
- **脚本层**：解决了“下完怎么办”和“BT 没速度”的问题。
- **Docker 层**：解决了“如何让这一切稳定跑起来”的问题。
