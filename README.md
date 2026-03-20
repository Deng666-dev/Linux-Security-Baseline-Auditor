# 🛡️ Linux-Security-Baseline-Auditor (v2.0)

> **基于“等保 2.0”三级标准打造的 Linux 主机安全基线自动化核查与交互式加固工具。**

## 📖 项目简介

在企业级 Linux 运维与安全合规（信息安全等级保护 2.0）场景中，主机安全基线的核查是极其重要的一环。本项目提供了一个轻量级、无依赖、开箱即用的自动化审计脚本。
它不仅能一键扫描 Linux 服务器的核心安全配置、自动生成结构化的 Markdown 审计报告，**更提供了安全可靠的交互式一键加固功能**。

## ✨ 核心特性

- **🛡️ 多维度基线审计**：覆盖身份鉴别（空口令/密码策略）、入侵防范（SSH 防爆破）、访问控制（关键文件权限防提权/UFW 防火墙）以及安全审计（日志服务）。
- **📑 自动化报告引擎**：每次执行完毕后，自动在 `reports/` 目录下生成带有时间戳的 Markdown 格式安全审计报告。
- **🛠️ 交互式一键加固 (v2.0 亮点)**：
  - 发现不合规配置时，自动拦截并询问是否修复。
  - **底层安全铁律**：所有对配置文件的修改（如 `sshd_config`, `login.defs`）均会自动生成 `.bak` 时间戳备份文件，支持随时回滚。
  - 自动接管服务重启（如 `systemctl restart sshd`），确保配置即刻生效。

## 📂 核心模块清单

| 模块文件 | 核查维度 | 一键加固支持 |
| :--- | :--- | :---: |
| `check_shadow.sh` | 身份鉴别：空口令与无密码账户深度排查 | ❌ (高危动作需人工) |
| `check_pwd_policy.sh` | 身份鉴别：密码有效期与长度策略核查 | ✅ (自动备份并修改) |
| `check_ssh.sh` | 入侵防范：Root 登录限制与密码防爆破阈值 | ✅ (自动备份/修改/重启) |
| `check_perms.sh` | 访问控制：`/etc/passwd` 等关键文件防提权 | ✅ (自动重置安全权限) |
| `check_ufw.sh` | 访问控制：主机防火墙状态探测 | ❌ (需结合业务开放端口) |
| `check_audit.sh` | 安全审计：系统核心日志守护进程状态 | ❌ (仅检查运行状态) |

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