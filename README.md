# aria2-unlock (Automation Scripts Branch)

[![Multi-Platform Build](https://github.com/Bigzhangbig/aria2-unlock/actions/workflows/ci.yml/badge.svg)](https://github.com/Bigzhangbig/aria2-unlock/actions)

本分支 (`feat-automation-scripts`) 在高性能内核的基础上，进一步整合了基于 P3TERX 方案的自动化运维脚本集。

## 0. 预编译版本下载 (Artifacts)
您可以从 GitHub Actions 的 **[最新运行记录](https://github.com/Bigzhangbig/aria2-unlock/actions)** 中直接下载各平台的解锁版二进制文件：
- **macOS**: `aria2c-macos-unlock`
- **Linux (Static)**: `aria2c-linux-static-unlock`

## 1. 分支特性
- **全套脚本集成**：内置 `clean.sh`、`upload.sh`、`delete.sh` 及 `tracker.sh`。
- **运维自动化**：支持下载完成后自动清理垃圾、自动上传云端（Rclone 联动）以及 BT Tracker 每日自动更新。
- **独立配置**：通过 `scripts/script.conf` 灵活控制自动化行为。

## 2. 目录结构
- `/src`: 已解锁 16 线程限制并注入高性能默认值的内核源码。
- `/scripts`: 自动化运维配套脚本及说明文档。

## 3. 使用方法
1. **编译内核**：参考主分支方法编译 `src/aria2c`。
2. **配置脚本**：根据 `scripts/README.md` 修改路径及 Rclone 配置。
3. **激活钩子**：在 `aria2.conf` 中添加 `on-download-complete` 等指令指向 `scripts/` 下的对应脚本。

---
*建议生产环境使用此分支以获得全自动下载体验。*
