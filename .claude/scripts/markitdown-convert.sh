#!/bin/bash
# markitdown 格式转换脚本
# 用法: markitdown-convert.sh <输入文件> <输出文件>

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_PYTHON="$SCRIPT_DIR/.venv/bin/python"

INPUT="$1"
OUTPUT="$2"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
  echo "用法: $0 <输入文件> <输出文件>"
  exit 1
fi

# 如果 venv 不存在，自动安装
if [ ! -f "$VENV_PYTHON" ]; then
  echo "首次使用，正在安装 markitdown..."
  bash "$SCRIPT_DIR/install-markitdown.sh"
fi

"$VENV_PYTHON" -c "
from markitdown import MarkItDown
md = MarkItDown()
result = md.convert('$INPUT')
with open('$OUTPUT', 'w', encoding='utf-8') as f:
    f.write(result.markdown)
"
