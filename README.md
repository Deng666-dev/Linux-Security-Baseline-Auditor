# 🛡️ Linux-Security-Baseline-Auditor

> **基于“等保 2.0”三级标准打造的 Linux 主机安全基线自动化核查与报告生成工具。**

## 📖 项目简介

在企业级 Linux 运维与安全合规（信息安全等级保护 2.0）场景中，主机安全基线的核查是极其重要的一环。本项目旨在提供一个轻量级、无依赖、开箱即用的自动化审计脚本。
它能够一键扫描 Linux 服务器的核心安全配置，识别潜在的入侵风险，并自动生成结构化的 Markdown 审计报告。

## ✨ 核心功能

本项目采用高度**模块化**的设计，目前支持以下维度的自动化核查：

- **身份鉴别 (Identity & Authentication)**
  - 🔍 `check_shadow.sh`: 解析 `/etc/shadow`，深度排查极其危险的空口令/无密码账户。
- **入侵防范 (Intrusion Prevention)**
  - 🛡️ `check_ssh.sh`: 审计 SSH 服务配置 (`sshd_config`)，核查 `PermitRootLogin` 状态与 `MaxAuthTries` 爆破防御阈值。
- **访问控制 (Access Control)**
  - 🧱 `check_ufw.sh`: 探测 UFW 主机防火墙激活状态，确保网络边界收敛。
- **安全审计 (Security Audit)**
  - 📜 `check_audit.sh`: 监控系统核心日志守护进程 (`rsyslog` 等) 状态，保障操作溯源防线。
- **📑 自动化报告引擎**
  - 执行完毕后，自动在 `reports/` 目录下生成带有时间戳的 Markdown 格式安全审计报告。

## 📂 目录结构

```text
Linux-Security-Baseline-Auditor/
├── main.sh                 # 主控引擎与报告生成器
├── README.md               # 项目说明文档
├── rules/                  # 安全审计模块库
│   ├── check_audit.sh      # 日志审计检查
│   ├── check_shadow.sh     # 空口令账户检查
│   ├── check_ssh.sh        # SSH 防爆破检查
│   └── check_ufw.sh        # UFW 防火墙状态检查
└── reports/                # 自动生成的 Markdown 审计报告存放处

🚀 快速开始
本项目为纯 Bash 脚本编写，无需按照Python或其他第三方依赖，即拉即用
1. ## 克隆仓库
git clone [https://github.com/Deng666-dev/Linux-Security-Baseline-Auditor.git](https://github.com/Deng666-dev/Linux-Security-Baseline-Auditor.git)
cd Linux-Security-Baseline-Auditor

2. ## 赋予执行权限
chmod +x main.sh rules/*.sh

3. ## 一键执行审计 (需 sudo 提权执行)
sudo ./main.sh

⚠️ 免责声明
本工具仅供授权的企业内网合规检查、安全学习与研究使用。请勿用于任何未经授权的非法目标探测。