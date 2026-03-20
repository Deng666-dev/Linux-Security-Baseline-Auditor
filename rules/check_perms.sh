#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "------------------------------------------------"
echo "正在检查：访问控制 - 关键系统文件权限"

# 底层逻辑：使用 stat -c %a 命令，直接提取文件的三位八进制权限数字（如 644）
PASSWD_PERM=$(stat -c %a /etc/passwd 2>/dev/null)
SHADOW_PERM=$(stat -c %a /etc/shadow 2>/dev/null)

MD_CONTENT=""

# 1. 检查 /etc/passwd
if [ "$PASSWD_PERM" == "644" ]; then
    echo -e "${GREEN}[Pass] /etc/passwd 权限合规 ($PASSWD_PERM)${NC}"
    MD_CONTENT+="- **访问控制 (/etc/passwd)**: ✅ 权限合规 (644)。\n"
else
    echo -e "${RED}[Danger] /etc/passwd 权限异常！当前: $PASSWD_PERM，期望: 644${NC}"
    echo -e "${YELLOW}👉 修复建议：执行 chmod 644 /etc/passwd${NC}"
    MD_CONTENT+="- **访问控制 (/etc/passwd)**: ❌ 权限异常 ($PASSWD_PERM)。修复建议: \`chmod 644 /etc/passwd\`。\n"
fi

# 2. 检查 /etc/shadow
if [ "$SHADOW_PERM" == "400" ] || [ "$SHADOW_PERM" == "000" ]; then
    echo -e "${GREEN}[Pass] /etc/shadow 权限合规 ($SHADOW_PERM)${NC}"
    MD_CONTENT+="- **访问控制 (/etc/shadow)**: ✅ 权限合规 ($SHADOW_PERM)。"
else
    echo -e "${RED}[Danger] /etc/shadow 权限异常！当前: $SHADOW_PERM，期望: 400 或 000${NC}"
    echo -e "${YELLOW}👉 修复建议：执行 chmod 400 /etc/shadow${NC}"
    MD_CONTENT+="- **访问控制 (/etc/shadow)**: ❌ 权限异常 ($SHADOW_PERM)，存在提权风险！修复建议: \`chmod 400 /etc/shadow\`。"
fi
echo "------------------------------------------------"

# 写入临时文件供报告收集
echo -e "$MD_CONTENT" >> /tmp/audit_report_tmp.md