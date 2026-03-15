# aria2-unlock (LLVM 21 High-Performance Edition)

[![LLVM 21 Multi-Platform Build](https://github.com/Bigzhangbig/aria2-unlock/actions/workflows/release.yml/badge.svg)](https://github.com/Bigzhangbig/aria2-unlock/actions)

本项目是基于官方 `aria2` 的深度增强版，采用 **LLVM 21 (Clang 21)** 构建链，旨在提供极致性能的解锁体验。

## 0. 预编译版本下载 (LLVM 21 Artifacts)
您可以从 GitHub Actions 的 **[最新运行记录](https://github.com/Bigzhangbig/aria2-unlock/actions)** 中直接下载各架构的解锁版二进制文件：
- **Windows (x64)**: `aria2c-windows-x64-llvm21`
- **macOS (Universal)**: `aria2c-macos-universal-llvm21` (支持 Apple Silicon & Intel)
- **Linux (x64)**: `aria2c-linux-x64-llvm21` (Static)
- **Linux (ARM64)**: `aria2c-linux-arm64-llvm21` (Static)

## 1. 核心增强特性
- **LLVM 21 编译器优化**：利用最新的 Clang 21 特性，提升内核运行效率与稳定性。
- **性能枷锁彻底解除**：移除 16 线程硬限制，支持 1K 极细分段及 128+ 极限线程。
- **高性能默认参数注入**：默认开启 RPC、禁用文件预分配、64M 缓存、无限重试逻辑。
- **增强补丁集成**：Async DNS 优化、4xx/520/521 错误自动重试、连接断开自动恢复。

## 2. 编译指引
本项目推荐通过 GitHub Actions 进行自动化构建。若需本地手动编译，请参考 `.github/workflows/release.yml` 中的 LLVM 21 环境配置及编译参数。

---
*本项目完美融合了 P3TERX 的优化思想与现代编译器技术的巅峰。*
