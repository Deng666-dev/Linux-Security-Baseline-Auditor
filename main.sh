#!/bin/bash

# ==========================================
# 项目：Linux-Security-Baseline-Auditor
# 描述：基于等保 2.0 的 Linux 主机安全基线核查工具
# ==========================================

# 定义颜色输出变量 (终端颜色控制字符的底层应用)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # 恢复默认颜色

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   Linux 安全基线自动化核查工具 v0.1 初始化   ${NC}"
echo -e "${GREEN}==========================================${NC}"

# 核心逻辑：检查是否为 root 用户执行
# 底层原理：Linux 系统中 root 用户的 UID 固定为 0
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[错误] 本工具需要最高权限以读取系统配置文件。${NC}"
  echo -e "${YELLOW}请使用 sudo ./main.sh 或切换到 root 用户执行。${NC}"
  exit 1
else
  echo -e "${GREEN}[+] 权限校验通过，当前用户拥有管理员权限。${NC}"
fi

# 预留扩展位置：后续将在这里动态加载 rules/ 目录下的检查脚本
echo -e "${YELLOW}[*] 环境初始化完成，等待加载检查模块...${NC}"

bash rules/check_shadow.sh
bash rules/check_ssh.sh