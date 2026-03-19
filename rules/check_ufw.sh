#!/bin/bash
# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "------------------------------------------------"
echo "正在检查：访问控制 - UFW 主机防火墙状态"

# 底层逻辑 1：使用 command -v 检查命令是否存在
# 这是一个非常优雅的 shell 技巧，如果 ufw 没安装，它不会报错，只会悄悄返回失败
if ! command -v ufw &> /dev/null; then
    echo -e "${YELLOW}[Warning] 未检测到 UFW 防火墙工具。如果使用的是 CentOS，请检查 firewalld 状态。${NC}"
    echo "------------------------------------------------"
    exit 0
fi

# 底层逻辑 2：执行命令并截取结果
# 使用 grep 过滤出带 "Status" 的行，再用 awk 提取状态值
UFW_STATUS=$(ufw status | grep -i "Status" | awk '{print $2}')

# 判断临界值：是不是 active
if [ "$UFW_STATUS" == "active" ]; then
    echo -e "${GREEN}[Pass] UFW 防火墙已开启 (Status: active)，符合基线要求。${NC}"
else
    echo -e "${RED}[Danger] UFW 防火墙处于关闭状态或未配置 (Status: $UFW_STATUS)！${NC}"
    echo -e "${YELLOW}👉 修复建议：请执行 'sudo ufw enable' 开启防火墙，并配置默认拒绝策略。${NC}"
fi
echo "------------------------------------------------"