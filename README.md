# aria2-unlock (High-Performance Core)

[![Multi-Platform Release Build](https://github.com/Bigzhangbig/aria2-unlock/actions/workflows/release.yml/badge.svg)](https://github.com/Bigzhangbig/aria2-unlock/actions)

本项目是基于官方 `aria2` 的深度增强版，核心目标是**彻底解除性能枷锁**，并针对国内网络环境注入 P3TERX 的高性能默认配置。

## 0. 预编译版本下载 (Artifacts)
您可以从 GitHub Actions 的 **[最新运行记录](https://github.com/Bigzhangbig/aria2-unlock/actions)** 中直接下载各平台的解锁版二进制文件：
- **Windows**: `aria2c-windows-unlock` (.exe)
- **macOS**: `aria2c-macos-unlock`
- **Linux (Static)**: `aria2c-linux-static-unlock`

## 1. 核心增强特性 (相对于官方版)

### 1.1 性能解锁
- **线程数限制解除**：`max-connection-per-server` 的 16 线程硬编码上限已移除 (1-无限制)。
- **极细粒度分段**：支持 **1K** 最小分段大小 (`min-split-size`)，允许对小文件进行多线程下载。
- **高性能分片**：默认 `split` 提升至 **32**，最高支持无限制分段。

### 1.2 高性能默认配置 (开箱即 Pro)
- **默认开启 RPC**：方便直接对接 AriaNg 等 WebUI。
- **极速启动**：默认禁用文件预分配 (`file-allocation=none`)，对 SSD 极其友好。
- **磁盘缓存优化**：默认缓存提升至 **64M**，显著减少高并发下的 IO 压力。
- **稳健连接**：默认开启**无限重试** (`max-tries=0`) 及 10s 短间隔重连。

### 1.3 核心补丁集成
- **Async DNS 优化**：重构异步解析逻辑，提升高并发下的域名解析稳定性。
- **增强重试逻辑**：支持针对 HTTP **400, 403, 406** 以及 Cloudflare **520/521** 等状态码的自动重试。
- **掉线自动恢复**：将 SSL 握手失败及连接断开的异常由报错改为自动重试。

## 2. 编译与安装

### 2.1 macOS 编译
```bash
brew install autoconf automake libtool pkg-config gettext cppunit
autoreconf -i
./configure --with-appletls --with-libxml2 --disable-nls
make -j$(sysctl -n hw.ncpu)
```

### 2.2 验证解锁
编译完成后运行以下命令，若不报错则说明解锁成功：
```bash
./src/aria2c -x 128 -s 128 https://example.com
```

## 3. 分支说明
- `master`: 专注于高性能内核及补丁集成。
- `feat-automation-scripts`: 在 master 基础上，整合了自动清理、自动上传等运维脚本。

---
*本项目深度融合了 P3TERX 的核心优化思想与补丁集。*
