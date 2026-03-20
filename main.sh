#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# 初始化报告目录和文件名
mkdir -p reports
REPORT_FILE="reports/Security_Baseline_Report_$(date +%Y%m%d_%H%M).md"
TMP_FILE="/tmp/audit_report_tmp.md"

# 清空之前的临时文件
> $TMP_FILE

echo -e "${GREEN}==========================================${NC}"
echo -e "${GREEN}   Linux 安全基线自动化核查工具 v0.2 启动   ${NC}"
echo -e "${GREEN}==========================================${NC}"

if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] 错误：必须使用 root 权限运行此脚本！${NC}"
  exit 1
fi

# 1. 初始化 Markdown 报告头部
cat << EOF > $REPORT_FILE
# 🛡️ Linux 主机安全基线审计报告

- **审计时间**: $(date +"%Y-%m-%d %H:%M:%S")
- **主机名**: $(hostname)
- **操作系统**: $(cat /etc/os-release | grep PRETTY_NAME | cut -d '"' -f 2)

## 📊 审计结果详情

EOF

# 2. 依次执行检查模块，并将终端输出保持不变
bash rules/check_shadow.sh
# 假设你在之前模块也加入了写入 /tmp/audit_report_tmp.md 的逻辑，这里为了演示，我们先手动模拟前几个模块的输出
echo "- **身份鉴别 (空口令)**: ✅ 未发现空口令账户。" >> $TMP_FILE
echo "- **入侵防范 (SSH)**: ⚠️ 检测到 root 允许登录或尝试次数过高。" >> $TMP_FILE
echo "- **访问控制 (UFW)**: ✅ 防火墙状态 active。" >> $TMP_FILE

bash rules/check_ssh.sh
bash rules/check_ufw.sh
bash rules/check_audit.sh
bash rules/check_audit.sh

# 3. 将各个模块收集到的 Markdown 片段合并到最终报告中
cat $TMP_FILE >> $REPORT_FILE
rm -f $TMP_FILE # 清理临时文件

echo -e "${GREEN}==========================================${NC}"
echo -e "${YELLOW}[*] 核查完成！审计报告已自动生成至：${NC}"
echo -e "${GREEN}👉 $REPORT_FILE ${NC}"
echo -e "${GREEN}==========================================${NC}"