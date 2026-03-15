# aria2-unlock (Multi-Platform High-Performance Edition)

[![Multi-Platform Release Build](https://github.com/Bigzhangbig/aria2-unlock/actions/workflows/release.yml/badge.svg)](https://github.com/Bigzhangbig/aria2-unlock/actions)

本项目是基于官方 `aria2` 的深度增强版，旨在提供跨平台、高性能的下载解锁体验。

## 0. 预编译版本下载 (Artifacts)
您可以从 GitHub Actions 的 **[最新运行记录](https://github.com/Bigzhangbig/aria2-unlock/actions)** 中直接下载各架构的解锁版二进制文件：
- **Windows (x64)**: `aria2c-windows-x64-unlock`
- **macOS (arm64/x64)**: `aria2c-macos-unlock` (采用 LLVM 21 极致优化)
- **Linux (x64)**: `aria2c-linux-x64-unlock` (Static)
- **Linux (ARM64)**: `aria2c-linux-arm64-unlock` (Static)

## 1. 核心增强特性
- **性能枷锁彻底解除**：移除 16 线程连接数硬限制，支持 1K 极细分段及 128+ 极限线程。
- **高性能默认参数注入**：默认开启 RPC、禁用文件预分配、64M 缓存、开启无限重试逻辑。
- **增强补丁集成**：Async DNS 优化、4xx/520/521 HTTP 错误自动重试、连接断开自动恢复。
- **现代编译器优化**：macOS 版本采用 **LLVM 21 (Clang 21)** 构建，提供巅峰运行效率。

## 2. 编译指引
推荐使用 GitHub Actions 进行自动化构建。具体环境配置及参数详见 `.github/workflows/release.yml`。

---
*本项目深度融合了 P3TERX 的优化思想与现代编译器技术的成果。*
