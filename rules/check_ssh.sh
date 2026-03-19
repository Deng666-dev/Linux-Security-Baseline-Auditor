#!/bin/bash
# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "------------------------------------------------"
echo "正在检查：入侵防范 - SSH 服务安全配置"

SSHD_CONFIG="/etc/ssh/sshd_config"

# 检查 1：是否允许 root 直接登录
# 底层逻辑：使用 grep 的 -i 参数忽略大小写，^ 符号代表仅匹配以 PermitRootLogin 开头的有效配置行（过滤掉#开头的注释），再用 awk 提取第二个参数。
ROOT_LOGIN=$(grep -i "^PermitRootLogin" $SSHD_CONFIG | awk '{print $2}')

# 如果变量为空，说明文件里没写这一行，默认就是极其危险的 yes
if [ -z "$ROOT_LOGIN" ] || [ "$ROOT_LOGIN" == "yes" ]; then
    echo -e "${RED}[Danger] 允许 root 直接登录或未明确配置，存在极大的被爆破风险！当前状态: ${ROOT_LOGIN:-默认(yes)}${NC}"
    echo -e "${YELLOW}👉 修复建议：在 sshd_config 中设置 PermitRootLogin no${NC}"
else
    echo -e "${GREEN}[Pass] 已禁止 root 直接登录 (PermitRootLogin=$ROOT_LOGIN)，符合基线要求。${NC}"
fi

# 检查 2：检查密码最大尝试次数 (防爆破)
AUTH_TRIES=$(grep -i "^MaxAuthTries" $SSHD_CONFIG | awk '{print $2}')

# 逻辑判断：如果不为空 (-n) 且 值小于等于 4 (-le 4)
if [ -n "$AUTH_TRIES" ] && [ "$AUTH_TRIES" -le 4 ]; then
    echo -e "${GREEN}[Pass] SSH 密码最大尝试次数合规 (MaxAuthTries=$AUTH_TRIES <= 4)${NC}"
else
    echo -e "${RED}[Danger] SSH 密码最大尝试次数未配置或过大，无法有效防御爆破！当前值: ${AUTH_TRIES:-未配置(默认6)}${NC}"
    echo -e "${YELLOW}👉 修复建议：在 sshd_config 中设置 MaxAuthTries 4${NC}"
fi
echo "------------------------------------------------"