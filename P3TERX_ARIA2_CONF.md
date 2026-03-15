# Aria2 Pro 完美配置深度解析 (P3TERX 版)

此文档对比了 P3TERX 的优化配置与 aria2 官方默认参数，旨在说明其在应对国内复杂网络环境时的技术优势。

## 1. 核心性能参数对比表

| 参数 (aria2.conf) | 官方默认值 | 优化推荐值 | 技术意图 (解决国内环境痛点) |
| :--- | :--- | :--- | :--- |
| `max-connection-per-server` | 1 | 128 | 暴力突破服务器单线程限速。 |
| `split` | 5 | 128 | 最大化并发连接，对冲高延时导致的吞吐量下降。 |
| `min-split-size` | 20M | 1M | 即使针对小文件也强制切片，实现“秒传”感。 |
| `disk-cache` | 16M | 64M | 适配 500M/1000M 宽带，保护硬盘免受高并发写入冲击。 |
| `file-allocation` | prealloc | falloc | 消除大文件下载前的磁盘预分配等待时间。 |
| `bt-max-peers` | 55 | 0 (无限制) | 扩大 BT 节点搜寻范围，应对国内 DHT 网络污染。 |
| `enable-dht6` | false | true | 优先利用 IPv6 通道，解决内网穿透难题。 |

## 2. BT Tracker 自动维护方案

P3TERX 配置的核心灵魂在于对 Tracker 列表的动态维护：

- **自动化脚本**：集成 `tracker.sh`。
- **数据源**：聚合多个上游高质量 Tracker 列表（如 XIU2、TrackersList）。
- **注入方式**：
  - **静态注入**：修改 `aria2.conf` 中的 `bt-tracker` 字段。
  - **动态注入**：通过 RPC 调用 `aria2.changeGlobalOption` 实现无感更新。

## 3. 部署指引 (注入原生 aria2)

```bash
# 1. 下载 P3TERX 基础配置
wget https://raw.githubusercontent.com/P3TERX/aria2.conf/master/aria2.conf

# 2. 补全必要的会话与 DHT 数据文件
touch aria2.session
wget https://github.com/P3TERX/aria2.conf/raw/master/dht.dat
wget https://github.com/P3TERX/aria2.conf/raw/master/dht6.dat

# 3. 建议配合脚本自动更新 Tracker (Crontab)
# 0 3 * * * /path/to/tracker.sh /path/to/aria2.conf RPC_SECRET
```

## 4. 特色脚本增强
P3TERX 仓库还包含了如 `clean.sh` (清理残留文件)、`delete.sh` (删除任务时同步删除本地文件) 等脚本，通过 `on-download-complete` 等钩子函数调用，极大提升了原生 aria2 的管理能力。
