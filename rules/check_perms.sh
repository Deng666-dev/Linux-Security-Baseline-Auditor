#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "------------------------------------------------"
echo "正在检查：访问控制 - 关键系统文件权限"

PASSWD_PERM=$(stat -c %a /etc/passwd 2>/dev/null)
SHADOW_PERM=$(stat -c %a /etc/shadow 2>/dev/null)
MD_CONTENT=""
NEEDS_FIX=0

if [ "$PASSWD_PERM" != "644" ] || { [ "$SHADOW_PERM" != "400" ] && [ "$SHADOW_PERM" != "000" ]; }; then
    echo -e "${RED}[Danger] 关键文件权限异常！/etc/passwd: $PASSWD_PERM, /etc/shadow: $SHADOW_PERM${NC}"
    MD_CONTENT+="- **访问控制 (文件权限)**: ❌ 权限异常，存在提权风险！\n"
    NEEDS_FIX=1
else
    echo -e "${GREEN}[Pass] 关键文件权限合规。${NC}"
    MD_CONTENT+="- **访问控制 (文件权限)**: ✅ 合规。\n"
fi

# 🌟 自动修复逻辑
if [ $NEEDS_FIX -eq 1 ]; then
    echo -ne "${CYAN}[?] 是否尝试自动将关键文件权限恢复至安全基线？(y/N): ${NC}"
    read -r FIX_CHOICE
    if [[ "$FIX_CHOICE" =~ ^[Yy]$ ]]; then
        chmod 644 /etc/passwd
        chmod 400 /etc/shadow
        echo -e "${GREEN}[+] 权限自动修复完成！(/etc/passwd=644, /etc/shadow=400)${NC}"
    else
        echo -e "${YELLOW}[-] 已跳过自动修复。${NC}"
    fi
fi
echo "------------------------------------------------"
echo -e "$MD_CONTENT" >> /tmp/audit_report_tmp.md