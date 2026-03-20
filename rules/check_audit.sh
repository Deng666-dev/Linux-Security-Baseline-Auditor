#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# MD 报告内容变量（供主控脚本捕获）
MD_CONTENT=""

echo "------------------------------------------------"
echo "正在检查：安全审计 - 系统日志服务状态"

# 底层逻辑：使用 systemctl 检查 rsyslog 服务状态
if systemctl is-active --quiet rsyslog; then
    echo -e "${GREEN}[Pass] rsyslog 日志服务正在运行，系统访问事件已记录。${NC}"
    MD_CONTENT="- **安全审计 (日志服务)**: ✅ \`rsyslog\` 运行正常，符合基线要求。"
else
    echo -e "${RED}[Danger] rsyslog 日志服务未运行！黑客入侵将失去关键审计线索！${NC}"
    MD_CONTENT="- **安全审计 (日志服务)**: ❌ \`rsyslog\` 未运行，存在严重安全隐患！\n  - *修复建议*: 执行 \`systemctl start rsyslog\` 并设置开机自启。"
fi
echo "------------------------------------------------"

# 将结果写入临时文件，供主控脚本读取生成报告
echo -e "$MD_CONTENT" >> /tmp/audit_report_tmp.md