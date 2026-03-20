#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "------------------------------------------------"
echo "正在检查：入侵防范 - SSH 服务安全配置"

SSHD_CONFIG="/etc/ssh/sshd_config"
MD_CONTENT=""
NEEDS_FIX=0

ROOT_LOGIN=$(grep -i "^PermitRootLogin" $SSHD_CONFIG | awk '{print $2}')
AUTH_TRIES=$(grep -i "^MaxAuthTries" $SSHD_CONFIG | awk '{print $2}')

# 检查 1：root 登录
if [ -z "$ROOT_LOGIN" ] || [ "$ROOT_LOGIN" == "yes" ]; then
    echo -e "${RED}[Danger] 允许 root 直接登录或未明确配置！当前状态: ${ROOT_LOGIN:-默认(yes)}${NC}"
    MD_CONTENT+="- **入侵防范 (SSH)**: ❌ 允许 root 登录。\n"
    NEEDS_FIX=1
else
    echo -e "${GREEN}[Pass] 已禁止 root 直接登录。${NC}"
    MD_CONTENT+="- **入侵防范 (SSH)**: ✅ root 登录限制合规。\n"
fi

# 检查 2：尝试次数
if [ -z "$AUTH_TRIES" ] || [ "$AUTH_TRIES" -gt 4 ]; then
    echo -e "${RED}[Danger] SSH 密码最大尝试次数未配置或过大！当前值: ${AUTH_TRIES:-未配置(默认6)}${NC}"
    MD_CONTENT+="- **入侵防范 (SSH)**: ❌ 密码尝试次数存在爆破风险。\n"
    NEEDS_FIX=1
else
    echo -e "${GREEN}[Pass] SSH 密码最大尝试次数合规。${NC}"
fi

# 🌟 自动修复逻辑
if [ $NEEDS_FIX -eq 1 ]; then
    echo -ne "${CYAN}[?] 是否尝试自动修复 SSH 配置并重启服务？(y/N): ${NC}"
    read -r FIX_CHOICE
    if [[ "$FIX_CHOICE" =~ ^[Yy]$ ]]; then
        # 1. 备份原配置
        cp $SSHD_CONFIG "${SSHD_CONFIG}.bak_$(date +%F_%T)"
        
        # 2. 修复 PermitRootLogin
        if grep -q "^PermitRootLogin" $SSHD_CONFIG; then
            sed -i 's/^PermitRootLogin.*/PermitRootLogin no/g' $SSHD_CONFIG
        else
            echo "PermitRootLogin no" >> $SSHD_CONFIG
        fi
        
        # 3. 修复 MaxAuthTries
        if grep -q "^MaxAuthTries" $SSHD_CONFIG; then
            sed -i 's/^MaxAuthTries.*/MaxAuthTries 4/g' $SSHD_CONFIG
        else
            echo "MaxAuthTries 4" >> $SSHD_CONFIG
        fi
        
        # 4. 重启服务使配置生效
        systemctl restart sshd
        echo -e "${GREEN}[+] SSH 自动修复完成，服务已重启！(原配置已备份)${NC}"
    else
        echo -e "${YELLOW}[-] 已跳过自动修复。${NC}"
    fi
fi
echo "------------------------------------------------"
echo -e "$MD_CONTENT" >> /tmp/audit_report_tmp.md