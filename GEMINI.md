# aria2-unlock (吾爱破解/52pojie 版)

## 项目概述
`aria2-unlock` 是一个基于官方 `aria2` 的修改版，核心目标是**解除原版 16 线程（连接数）的硬编码限制**。根据吾爱破解社区（thread-1986139）的反馈，该修改能显著提升在特定网络环境下（如低速 S3 存储、国内网盘直链）的下载效率。

- **核心变更：** 
    - 解除 `max-connection-per-server` 的 16 线程上限。
    - 缩小 `min-split-size` 的最小限制（从 1M 降至 1K），允许更细粒度的分段。
- **技术栈：** C++, Autotools, Docker (用于交叉编译 Windows/Android/Raspberry Pi 版本)。

## 关键修改点 (源码级)
本项目主要对 `src/OptionHandlerFactory.cc` 进行了以下手术级修改：

| 配置项 | 官方原版 | 本项目 (Unlock) | 修改位置 |
| :--- | :--- | :--- | :--- |
| `max-connection-per-server` | 1-16 (硬限制) | **1-无限制 (-1)** | `src/OptionHandlerFactory.cc` |
| `min-split-size` | 最小 1M | **最小 1K** | `src/OptionHandlerFactory.cc` |
| `split` (默认分段数) | 5 | **32** | `src/OptionHandlerFactory.cc` |

## 构建指南
本项目推荐使用 Docker 进行跨平台编译，以确保环境一致性。

- **Windows 版编译：** 使用 `Dockerfile.mingw`。
- **Android 版编译：** 使用 `Dockerfile.android`。
- **本地通用编译：**
    ```bash
    autoreconf -i
    ./configure
    make -j$(nproc)
    ```

## 实战优化建议 (针对中国网络环境)
根据 52pojie 社区经验，针对百度网盘、115网盘等环境的优化配置如下：

### 推荐配置 (aria2.conf)
```conf
# 解锁后的高性能配置
max-connection-per-server=64
split=64
min-split-size=1K
# 提高文件分配速度
file-allocation=falloc
# 开启 RPC 方便 WebUI (如 AriaNg) 控制
enable-rpc=true
rpc-listen-all=true
rpc-allow-origin-all=true
```

### 注意事项
1.  **风险提示：** 盲目追求极高线程（如 256+）可能导致服务器端触发反爬机制，造成 IP 临时封禁或账号限速。建议在 32-64 线程间平衡。
2.  **GUI 兼容：** 编译出的 `aria2c` 可直接替换 AriaNg、Aria2GUI 等客户端中的内核文件。
3.  **系统句柄：** 在高并发下载时，请确保系统文件句柄数足够（见 `PREF_RLIMIT_NOFILE` 配置）。

## RPC 交互参考
- **鉴权：** 必须使用 `--rpc-secret` 提高安全性。
- **实时性：** 建议通过 WebSocket 订阅 `onDownloadComplete` 等事件，避免轮询 `tellStatus` 造成的额外开销。

---
*本文档根据官方手册与 52pojie 社区实战经验整合而成。*
