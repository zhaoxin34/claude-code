#!/bin/bash
#
# zellij-helper.sh - Zellij pane 操作封装脚本
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

usage() {
  cat <<EOF
Usage: zellij-helper.sh <command> [options]

Commands:
    create [direction] [name] [width] [height] [x] [y]
                              创建新 pane
                              direction: right, down, left, up, float（默认 right）
                              当 direction 为 float 时:
                                name: pane 名称（可选）
                                width: 宽度（默认 150）
                                height: 高度（默认 60）
                                x: X 位置，支持百分比如 1%（默认 1%）
                                y: Y 位置，支持百分比如 5%（默认 5%）
    send-text <pane_id> <text>   发送文本（不含回车）
    send-command <pane_id> <text> 发送文本并执行（send-text + Enter）
    send-keys <pane_id> <key>    发送按键（Enter, Ctrl+c, Ctrl+d 等）
    write <pane_id> <text>       安全发送文本（隐蔽输入，用于密码）
    dump-screen <pane_id>         获取当前屏幕内容
    wait-for <pane_id> <pattern> [--timeout <seconds>]   等待特定字符串
    close-pane <pane_id>  关闭 pane

Examples:
    zellij-helper.sh create right
    zellij-helper.sh create float mypane 150 60 1% 5%
    zellij-helper.sh send-text terminal_xxx "ls -la"
    zellij-helper.sh send-command terminal_xxx "ls -la"
    zellij-helper.sh send-keys terminal_xxx "Enter"
    zellij-helper.sh write terminal_xxx "password123"
    zellij-helper.sh wait-for terminal_xxx "root@"
    zellij-helper.sh close-pane terminal_xxx
EOF
  exit 1
}

# 执行 zellij action
zellij_action() {
  local action="$1"
  shift
  zellij action "$action" "$@" 2>/dev/null || true
}

# 创建新 pane
cmd_create() {
  local direction="${1:-down}"
  local pane_info

  # 处理浮动 pane
  if [ "$direction" = "float" ]; then
    local name="${2:-}"
    local width="${3:-150}"
    local height="${4:-60}"
    local x="${5:-1%}"
    local y="${6:-5%}"

    pane_info=$(zellij action new-pane --floating --width "$width" --height "$height" -x "$x" -y "$y" --pinned true 2>&1)

    local pane_id
    pane_id=$(echo "$pane_info" | grep -oE 'terminal_[a-zA-Z0-9]+' | head -1)

    if [ -z "$pane_id" ]; then
      pane_id="float_$$"
    fi

    if [ -n "$name" ]; then
      zellij action rename-pane "$name" --pane-id "$pane_id" 2>/dev/null || true
    fi

    cat <<EOF
{
    "pane_id": "$pane_id",
    "type": "floating",
    "name": "${name:-null}",
    "width": "$width",
    "height": "$height",
    "position": {"x": "$x", "y": "$y"},
    "pinned": true,
    "created": "$(date -Iseconds)"
}
EOF
    return
  fi

  # 普通 pane 创建
  pane_info=$(zellij action new-pane -d "$direction" 2>&1)

  local pane_id
  pane_id=$(echo "$pane_info" | grep -oE 'terminal_[a-zA-Z0-9]+' | head -1)

  if [ -z "$pane_id" ]; then
    pane_id="terminal_$$"
  fi

  cat <<EOF
{
    "pane_id": "$pane_id",
    "direction": "$direction",
    "created": "$(date -Iseconds)"
}
EOF
}

# 发送文本（不含回车）
cmd_send_text() {
  local pane_id="$1"
  local text="$2"

  [ -z "$pane_id" ] && usage
  [ -z "$text" ] && usage

  zellij action write-chars "$text" --pane-id "$pane_id"
}

# 发送命令（文本 + 回车）
cmd_send_command() {
  local pane_id="$1"
  local text="$2"

  [ -z "$pane_id" ] && usage
  [ -z "$text" ] && usage

  zellij action write-chars "$text" --pane-id "$pane_id"
  zellij action send-keys "Enter" --pane-id "$pane_id"
}

# 发送按键
cmd_send_keys() {
  local pane_id="$1"
  local key="$2"

  [ -z "$pane_id" ] && usage
  [ -z "$key" ] && usage

  zellij action send-keys "$key" --pane-id "$pane_id"
}

# 安全发送（隐蔽输入，用于密码）
cmd_write() {
  local pane_id="$1"
  local text="$2"

  [ -z "$pane_id" ] && usage
  [ -z "$text" ] && usage

  # 使用 write 而非 write-chars，避免回显
  zellij action write "$text" --pane-id "$pane_id"
}

# 获取屏幕内容
cmd_dump_screen() {
  local pane_id="$1"

  [ -z "$pane_id" ] && usage

  zellij action dump-screen -f --pane-id "$pane_id" 2>/dev/null || echo ""
}

# 等待特定字符串
cmd_wait_for() {
  local pane_id="$1"
  local pattern="$2"
  local timeout="${3:-60}"
  local elapsed=0
  local interval=1

  [ -z "$pane_id" ] && usage
  [ -z "$pattern" ] && usage

  while [ $elapsed -lt $timeout ]; do
    local content
    content=$(cmd_dump_screen "$pane_id")

    if echo "$content" | grep -q "$pattern"; then
      echo "Found '$pattern' after ${elapsed}s"
      return 0
    fi

    sleep $interval
    elapsed=$((elapsed + interval))
  done

  echo "Timeout waiting for '$pattern' after ${timeout}s"
  return 1
}

# 关闭 pane
cmd_close_pane() {
  local pane_id="$1"

  [ -z "$pane_id" ] && usage

  zellij action close-pane --pane-id "$pane_id"
}

# 主命令处理
main() {
  local command="${1:-}"
  shift || true

  case "$command" in
  create)
    cmd_create "$@"
    ;;
  send-text)
    cmd_send_text "$@"
    ;;
  send-command)
    cmd_send_command "$@"
    ;;
  send-keys)
    cmd_send_keys "$@"
    ;;
  write)
    cmd_write "$@"
    ;;
  dump-screen)
    cmd_dump_screen "$@"
    ;;
  wait-for)
    cmd_wait_for "$@"
    ;;
  close-pane)
    cmd_close_pane "$@"
    ;;
  help | --help | -h)
    usage
    ;;
  *)
    usage
    ;;
  esac
}

main "$@"
