# Aria2 Pro Core 源码级深度改动分析 (相对于 v1.37.0)

## 1. 核心文件改动与 Rationale (技术动机)

### 1.1 `src/OptionHandlerFactory.cc` (性能限制解锁)
- **修改点**：
    - `PREF_MAX_CONNECTION_PER_SERVER`: 上限从 `16` 修改为 `-1` (无限制)。
    - `PREF_MIN_SPLIT_SIZE`: 最小值从 `1M` 修改为 `1K`，默认值设为 `1K`。
    - `PREF_SPLIT`: 默认值从 `5` 修改为 `32`。
- **Rationale**：官方原版的限制是为了防止用户恶意抢占服务器资源，但在现代高带宽（如 10G 口 VPS）或针对限速严重的网盘（如百度网盘 100KB/s 线程限制）时，16 线程远不足以跑满带宽。1K 分段允许对极小文件或文件末尾残余块进行多线程抢占。

### 1.2 `src/AsyncNameResolver.cc` (异步 DNS 稳定性增强)
- **修改点**：重构了异步名称解析逻辑，调用了更现代的 `ares_getaddrinfo` 接口，并优化了 `ares_socket_callback` 的状态管理。
- **Rationale**：在高并发下载（数百个连接同时发起）时，原版的 DNS 解析可能会在高负荷下出现假死或超时。重构后提升了在复杂网络环境下的解析成功率。

### 1.3 `src/option_processing.cc` (易用性优化)
- **修改点**：调整了 Levenshtein 距离算法的权重。
- **Rationale**：优化了命令行参数输入错误时的“Did you mean...?”建议准确度，提升了 CLI 操作体验。

### 1.4 `src/usage_text.h` & `src/AbstractHttpServerResponseCommand.cc` (纠错)
- **修改点**：修正了 `referrrer` -> `referrer` 等拼写错误。
- **Rationale**：统一日志输出与文档的标准性，消除原版遗留的拼写 Bug。

---

## 2. 如何将改动运用到原版 (Integration Guide)

### 2.1 快速补丁法 (Git Patch)
如果您在原版 aria2 仓库目录下，可以生成 diff 并应用：
```bash
# 在 Aira2-Pro-Core 源码目录下生成 patch
git diff release-1.37.0 > aria2-pro.patch
# 在原版仓库中应用
git apply aria2-pro.patch
```

### 2.2 手动集成建议
1. **参数解锁**：直接编辑 `src/OptionHandlerFactory.cc`，搜索 `16` 并改为 `-1`，搜索 `1_m` 并改为 `1_k`。
2. **DNS 增强**：如果需要极高并发下的稳定性，建议对比并移植 `src/AsyncNameResolver.cc` 的重构逻辑。
3. **编译参数**：建议使用 `--with-libcares` 和 `--with-appletls` (macOS) 或 `--with-openssl` (Linux) 编译，以获得最佳性能。

---
*本文档由 Gemini CLI 结合 GitHub 分析工具深度整合编写。*
