# Aria2 自动化运维参考脚本 (scripts)

本目录整合了基于 P3TERX 方案的高级自动化运维脚本，旨在配合 `aria2-unlock` 解锁版内核实现全自动下载体验。

## 1. 脚本功能说明

| 脚本文件 | 触发条件 | 功能描述 |
| :--- | :--- | :--- |
| `clean.sh` | 下载完成 | 自动清理 `.aria2` 状态文件、`.torrent` 种子及空目录。 |
| `delete.sh` | 任务停止/错误 | 自动清理任务相关的残留垃圾文件。 |
| `upload.sh` | 下载完成 | 联动 Rclone 将下载的文件自动上传至 OneDrive/GoogleDrive。 |
| `tracker.sh` | 定时执行 (Cron) | 自动获取全球最新 BT Tracker 列表并动态注入内核。 |
| `core` | N/A | 各脚本共享的核心逻辑库。 |

## 2. 快速开始

### 2.1 配置参数
编辑 `scripts/script.conf`，设置您的 Rclone 驱动名称 (`drive-name`) 及清理策略。

### 2.2 内核联动
在您的 `aria2.conf` 中添加以下钩子配置（假设脚本存放在 `/root/.aria2/scripts`）：
```conf
# 下载完成后自动清理
on-download-complete=/root/.aria2/scripts/clean.sh
# 任务停止时自动清理
on-download-stop=/root/.aria2/scripts/delete.sh
# 如需自动上传，请将 clean.sh 替换为 upload.sh
```

### 2.3 自动更新 Tracker
建议通过 Crontab 设置每天凌晨自动更新：
```bash
0 7 * * * /bin/bash /path/to/scripts/tracker.sh /path/to/aria2.conf RPC
```

## 3. 注意事项
- 脚本依赖 `curl`, `jq` 和 `rclone` (可选)。
- 确保脚本具有执行权限：`chmod +x scripts/*.sh`。
- 本脚本集仅作为参考实现，生产环境使用请根据实际路径调整。

---
*基于 P3TERX/aria2.conf 项目逻辑整理。*
