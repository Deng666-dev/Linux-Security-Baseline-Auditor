#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "------------------------------------------------"
echo "正在检查：身份鉴别 - 空口令账户检查"

# 底层核心逻辑：使用 awk 以冒号为分隔符，判断第二列是否为空
# 并过滤掉系统默认带 * 或 ! 的不可登录账户
EMPTY_PASS_USERS=$(awk -F: '($2 == "") {print $1}' /etc/shadow)

if [ -z "$EMPTY_PASS_USERS" ]; then
    echo -e "${GREEN}[Pass] 未发现空口令账户，符合等保要求。${NC}"
else
    echo -e "${RED}[Danger] 发现危险的空口令账户！${NC}"
    echo -e "${RED}账户列表：$EMPTY_PASS_USERS${NC}"
fi
echo "------------------------------------------------"