#!/bin/bash
# 安装 markitdown 到项目的 venv 中
# 按照官方 README: https://github.com/microsoft/markitdown

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
VENV_DIR="$SCRIPT_DIR/.venv"
REPO_DIR="$SCRIPT_DIR/markitdown"

if [ -d "$VENV_DIR" ] && [ -f "$VENV_DIR/bin/python" ]; then
  echo "markitdown 已安装，跳过。如需重装，先删除 $VENV_DIR 和 $REPO_DIR"
  exit 0
fi

echo "正在创建 Python 虚拟环境..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "正在克隆 markitdown 仓库..."
git clone https://github.com/microsoft/markitdown.git "$REPO_DIR"

echo "正在安装 markitdown[all]..."
pip install -e "$REPO_DIR/packages/markitdown[all]"

echo "安装完成: $VENV_DIR/bin/python"
