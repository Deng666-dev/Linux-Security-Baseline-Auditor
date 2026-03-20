#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "------------------------------------------------"
echo "正在检查：身份鉴别 - 密码有效期与长度策略"

LOGIN_DEFS="/etc/login.defs"
MD_CONTENT=""

# 底层逻辑：使用 grep 和 awk 提取 PASS_MAX_DAYS (密码最长使用天数)
MAX_DAYS=$(grep -i "^PASS_MAX_DAYS" $LOGIN_DEFS | awk '{print $2}')

# 检查 1：密码最大有效期 (等保建议不超过 90 天)
if [ -n "$MAX_DAYS" ] && [ "$MAX_DAYS" -le 90 ]; then
    echo -e "${GREEN}[Pass] 密码最长有效期合规 (PASS_MAX_DAYS=$MAX_DAYS <= 90)${NC}"
    MD_CONTENT+="- **身份鉴别 (密码有效期)**: ✅ 合规 ($MAX_DAYS 天)。\n"
else
    echo -e "${RED}[Danger] 密码有效期过长或未限制！当前值: ${MAX_DAYS:-未配置}${NC}"
    MD_CONTENT+="- **身份鉴别 (密码有效期)**: ❌ 存在风险 ($MAX_DAYS 天)，期望值 <= 90。\n"
    
    # 🌟 核心功能：一键自动加固交互逻辑
    echo -ne "${CYAN}[?] 是否尝试自动修复 PASS_MAX_DAYS 为 90？(y/N): ${NC}"
    read -r FIX_CHOICE
    if [[ "$FIX_CHOICE" =~ ^[Yy]$ ]]; then
        # 铁律：先备份！
        cp $LOGIN_DEFS "${LOGIN_DEFS}.bak_$(date +%F)"
        
        # 底层逻辑：使用 sed -i 自动替换文本。
        # 如果存在旧配置，就替换它；如果不存在，就不动（防止搞乱文件）
        if grep -q "^PASS_MAX_DAYS" $LOGIN_DEFS; then
            sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/g' $LOGIN_DEFS
            echo -e "${GREEN}[+] 自动修复完成！已将 PASS_MAX_DAYS 设置为 90。(已备份原文件)${NC}"
        else
            echo -e "${YELLOW}[!] 未找到原配置行，请手动修改。${NC}"
        fi
    else
        echo -e "${YELLOW}[-] 已跳过自动修复。${NC}"
    fi
fi

echo "------------------------------------------------"
echo -e "$MD_CONTENT" >> /tmp/audit_report_tmp.mdss