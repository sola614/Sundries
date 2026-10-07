#!/bin/sh
# ==============================================================================
# GOST 管理脚本（安装 / 更新 / 卸载）
#
# 兼容性：
#   - init 系统：systemd（Debian/Ubuntu/CentOS/RHEL/Fedora/Arch...）
#                OpenRC（Alpine Linux、Gentoo/OpenRC...）
#   - shell：POSIX sh，可在 bash / dash / busybox ash 下运行
#            （Alpine 默认只有 busybox ash，无需额外安装 bash）
#   - 包管理：apt / dnf / yum / apk / pacman / zypper / emerge / xbps-install
#   - 下载器：curl 优先，回退 wget（缺失时尝试自动安装 curl）
# ==============================================================================

INSTALL_DIR="/etc/gost"
SERVICE_NAME="gost"
GOST_VERSION="1.4.3"
REPO="bqlpfy/flux-panel"

# 允许通过环境变量预先传入
SERVER_ADDR="${SERVER_ADDR:-}"
SECRET="${SECRET:-}"

# ------------------------------------------------------------------------------
# 基础工具
# ------------------------------------------------------------------------------

# 获取系统架构
get_architecture() {
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64|amd64)
            echo "amd64"
            ;;
        aarch64|arm64)
            echo "arm64"
            ;;
        *)
            echo "amd64"  # 默认使用 amd64
            ;;
    esac
}

# 构建下载地址
build_download_url() {
    ARCH=$(get_architecture)
    echo "https://github.com/${REPO}/releases/download/${GOST_VERSION}/gost-${ARCH}"
}

# 是否有 root 权限；无则给出 sudo/su 前缀
init_privilege() {
    if [ "$(id -u 2>/dev/null)" -eq 0 ]; then
        SUDO_CMD=""
    elif command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    elif command -v doas >/dev/null 2>&1; then
        SUDO_CMD="doas"
    else
        SUDO_CMD=""
    fi
}

# 确保以 root 运行（可在有 sudo/doas 时自动提权）
ensure_root() {
    [ "$(id -u 2>/dev/null)" -eq 0 ] && return 0

    if [ -n "$SUDO_CMD" ] && [ -f "$0" ]; then
        echo "🔐 需要 root 权限，正在使用 ${SUDO_CMD} 重新执行..."
        exec $SUDO_CMD "$0" "$@"
    fi

    echo "❌ 需要 root 权限（未找到可用的 sudo/doas），请以 root 身份运行本脚本。"
    exit 1
}

# 检测发行版
detect_distro() {
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DISTRO="$ID"
    elif [ -f /etc/alpine-release ]; then
        DISTRO="alpine"
    elif [ -f /etc/redhat-release ]; then
        DISTRO="rhel"
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    else
        DISTRO="unknown"
    fi
}

# 检测 init 系统：systemd / openrc / none
detect_init() {
    if [ -d /run/systemd/system ] && command -v systemctl >/dev/null 2>&1; then
        INIT_SYSTEM="systemd"
    elif command -v rc-service >/dev/null 2>&1 || command -v rc-update >/dev/null 2>&1; then
        INIT_SYSTEM="openrc"
    elif [ -x /sbin/openrc-run ] || [ -d /etc/runlevels ]; then
        INIT_SYSTEM="openrc"
    else
        INIT_SYSTEM="none"
    fi
}

# 通用包安装（$1 包名），成功返回 0
install_pkg() {
    PKG="$1"
    [ -n "$PKG" ] || return 1
    case "$DISTRO" in
        ubuntu|debian|linuxmint|raspbian)
            $SUDO_CMD apt-get update >/dev/null 2>&1
            $SUDO_CMD apt-get install -y "$PKG" >/dev/null 2>&1
            ;;
        alpine)
            $SUDO_CMD apk add --no-cache "$PKG" >/dev/null 2>&1
            ;;
        centos|rhel|rocky|almalinux|fedora|ol)
            if command -v dnf >/dev/null 2>&1; then
                $SUDO_CMD dnf install -y "$PKG" >/dev/null 2>&1
            elif command -v yum >/dev/null 2>&1; then
                $SUDO_CMD yum install -y "$PKG" >/dev/null 2>&1
            else
                return 1
            fi
            ;;
        arch|manjaro|endeavouros)
            $SUDO_CMD pacman -S --noconfirm "$PKG" >/dev/null 2>&1
            ;;
        opensuse*|sles|suse)
            $SUDO_CMD zypper install -y "$PKG" >/dev/null 2>&1
            ;;
        gentoo)
            $SUDO_CMD emerge --ask=n "$PKG" >/dev/null 2>&1
            ;;
        void)
            $SUDO_CMD xbps-install -Sy "$PKG" >/dev/null 2>&1
            ;;
        *)
            return 1
            ;;
    esac
}

# 下载文件：$1=url  $2=输出路径
download_file() {
    URL="$1"
    OUT="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fL --connect-timeout 15 --retry 2 "$URL" -o "$OUT"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$OUT" "$URL"
    else
        return 1
    fi
}

# 拉取纯文本（用于判断国家/地区），失败返回空
fetch_text() {
    URL="$1"
    if command -v curl >/dev/null 2>&1; then
        curl -fs --max-time 8 "$URL" 2>/dev/null
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O - --timeout=8 "$URL" 2>/dev/null
    fi
}

# 确保存在下载工具（Alpine 最小系统可能没有 curl/wget）
ensure_download_tool() {
    if command -v curl >/dev/null 2>&1 || command -v wget >/dev/null 2>&1; then
        return 0
    fi
    echo "📦 未检测到 curl/wget，正在安装 curl..."
    install_pkg curl && command -v curl >/dev/null 2>&1 && return 0
    echo "❌ 无法自动安装 curl，请手动安装后重试。"
    return 1
}

# 交互式读取（兼容 curl | sh 场景，优先从 /dev/tty 读取）
# 用法：VAR=$(prompt_read "提示语" "默认值")
prompt_read() {
    _prompt="$1"
    _default="$2"
    _reply=""
    if [ -t 0 ]; then
        # stdin 是终端，直接读取
        printf '%s' "$_prompt"
        IFS= read -r _reply || _reply=""
    elif ( : < /dev/tty ) 2>/dev/null; then
        # stdin 被管道占用（如 curl | sh），但有可用终端，从 /dev/tty 读取
        printf '%s' "$_prompt" > /dev/tty 2>/dev/null
        IFS= read -r _reply < /dev/tty 2>/dev/null || _reply=""
    else
        # 无终端可用（非交互场景），退回到 stdin
        printf '%s' "$_prompt" >&2
        IFS= read -r _reply || _reply=""
    fi
    [ -z "$_reply" ] && _reply="$_default"
    printf '%s' "$_reply"
}

# ------------------------------------------------------------------------------
# 服务管理抽象层（systemd / OpenRC）
# ------------------------------------------------------------------------------

service_exists() {
    case "$INIT_SYSTEM" in
        systemd) [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ] ;;
        openrc)  [ -f "/etc/init.d/${SERVICE_NAME}" ] ;;
        *)       return 1 ;;
    esac
}

service_is_active() {
    case "$INIT_SYSTEM" in
        systemd) systemctl is-active --quiet "$SERVICE_NAME" ;;
        openrc)  rc-service "$SERVICE_NAME" status >/dev/null 2>&1 ;;
        *)       return 1 ;;
    esac
}

service_stop() {
    case "$INIT_SYSTEM" in
        systemd) $SUDO_CMD systemctl stop "$SERVICE_NAME" 2>/dev/null ;;
        openrc)  $SUDO_CMD rc-service "$SERVICE_NAME" stop 2>/dev/null ;;
    esac
}

service_start() {
    case "$INIT_SYSTEM" in
        systemd) $SUDO_CMD systemctl start "$SERVICE_NAME" 2>/dev/null ;;
        openrc)  $SUDO_CMD rc-service "$SERVICE_NAME" start 2>/dev/null ;;
    esac
}

service_enable() {
    case "$INIT_SYSTEM" in
        systemd) $SUDO_CMD systemctl enable "$SERVICE_NAME" >/dev/null 2>&1 ;;
        openrc)  $SUDO_CMD rc-update add "$SERVICE_NAME" default >/dev/null 2>&1 ;;
    esac
}

service_disable() {
    case "$INIT_SYSTEM" in
        systemd) $SUDO_CMD systemctl disable "$SERVICE_NAME" >/dev/null 2>&1 ;;
        openrc)  $SUDO_CMD rc-update del "$SERVICE_NAME" default >/dev/null 2>&1 ;;
    esac
}

service_reload() {
    case "$INIT_SYSTEM" in
        systemd) $SUDO_CMD systemctl daemon-reload 2>/dev/null ;;
        *)       : ;;
    esac
}

# 写入服务定义文件
service_install_file() {
    case "$INIT_SYSTEM" in
        systemd)
            SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"
            cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Gost Proxy Service
After=network.target

[Service]
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/gost
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
            ;;
        openrc)
            SERVICE_FILE="/etc/init.d/${SERVICE_NAME}"
            cat > "$SERVICE_FILE" <<EOF
#!/sbin/openrc-run

name="${SERVICE_NAME}"
description="Gost Proxy Service"

command="${INSTALL_DIR}/gost"
command_background="yes"
pidfile="/run/${SERVICE_NAME}.pid"
directory="${INSTALL_DIR}"

output_log="/var/log/${SERVICE_NAME}.log"
error_log="/var/log/${SERVICE_NAME}.log"

depend() {
    need net
    after firewall
}
EOF
            chmod +x "$SERVICE_FILE"
            : > "/var/log/${SERVICE_NAME}.log" 2>/dev/null || true
            ;;
        *)
            echo "⚠️ 未识别的 init 系统，跳过服务注册（可手动启动 $INSTALL_DIR/gost）。"
            return 1
            ;;
    esac
    return 0
}

service_remove_file() {
    case "$INIT_SYSTEM" in
        systemd)
            [ -f "/etc/systemd/system/${SERVICE_NAME}.service" ] && \
                rm -f "/etc/systemd/system/${SERVICE_NAME}.service" && \
                echo "🧹 删除服务文件"
            ;;
        openrc)
            [ -f "/etc/init.d/${SERVICE_NAME}" ] && \
                rm -f "/etc/init.d/${SERVICE_NAME}" && \
                echo "🧹 删除服务文件"
            ;;
    esac
}

service_log_hint() {
    case "$INIT_SYSTEM" in
        systemd) echo "journalctl -u ${SERVICE_NAME} -f" ;;
        openrc)  echo "tail -f /var/log/${SERVICE_NAME}.log" ;;
        *)       echo "无需查看" ;;
    esac
}

# ------------------------------------------------------------------------------
# tcpkill 检查与安装
# ------------------------------------------------------------------------------
check_and_install_tcpkill() {
    # 已安装则直接返回
    if command -v tcpkill >/dev/null 2>&1; then
        return 0
    fi

    OS_TYPE=$(uname -s)

    # macOS：通过 brew 安装 dsniff
    if [ "$OS_TYPE" = "Darwin" ]; then
        if command -v brew >/dev/null 2>&1; then
            brew install dsniff >/dev/null 2>&1
        fi
        return 0
    fi

    case "$DISTRO" in
        ubuntu|debian|linuxmint|raspbian|centos|rhel|rocky|almalinux|fedora|ol|arch|manjaro|endeavouros|opensuse*|sles|suse|void)
            install_pkg dsniff || true
            ;;
        alpine)
            # 注意：Alpine 官方仓库不提供 dsniff/tcpkill（需自行编译），
            # 这里尝试安装，失败也不影响主流程。
            if ! install_pkg dsniff; then
                echo "ℹ️ Alpine 仓库中无 dsniff 包，跳过 tcpkill（如需使用请自行编译 dsniff）。"
            fi
            ;;
        gentoo)
            install_pkg net-analyzer/dsniff || true
            ;;
        *)
            : ;;
    esac

    return 0
}

# ------------------------------------------------------------------------------
# 配置参数
# ------------------------------------------------------------------------------
get_config_params() {
    if [ -z "$SERVER_ADDR" ] || [ -z "$SECRET" ]; then
        echo "请输入配置参数："

        if [ -z "$SERVER_ADDR" ]; then
            SERVER_ADDR=$(prompt_read "服务器地址: " "")
        fi

        if [ -z "$SECRET" ]; then
            SECRET=$(prompt_read "密钥: " "")
        fi

        if [ -z "$SERVER_ADDR" ] || [ -z "$SECRET" ]; then
            echo "❌ 参数不完整，操作取消。"
            exit 1
        fi
    fi
}

# 根据 IP 所在地判断是否使用加速镜像
apply_mirror() {
    DOWNLOAD_URL=$(build_download_url)
    COUNTRY=$(fetch_text "https://ipinfo.io/country" | tr -d '[:space:]')
    if [ "$COUNTRY" = "CN" ]; then
        DOWNLOAD_URL="https://ghfast.top/${DOWNLOAD_URL}"
    fi
}

# 解析命令行参数
while getopts "a:s:" opt; do
    case "$opt" in
        a) SERVER_ADDR="$OPTARG" ;;
        s) SECRET="$OPTARG" ;;
        *) echo "❌ 无效参数"; exit 1 ;;
    esac
done

# ------------------------------------------------------------------------------
# 菜单 / 清理
# ------------------------------------------------------------------------------
show_menu() {
  echo "==============================================="
  echo "              管理脚本"
  echo "==============================================="
  echo "请选择操作："
  echo "1. 安装"
  echo "2. 更新"
  echo "3. 卸载"
  echo "4. 退出"
  echo "==============================================="
}

# 删除脚本自身
delete_self() {
  echo ""
  echo "🗑️ 操作已完成，正在清理脚本文件..."
  SCRIPT_PATH="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || echo "$0")"
  sleep 1
  rm -f "$SCRIPT_PATH" && echo "✅ 脚本文件已删除" || echo "❌ 删除脚本文件失败"
}

# ------------------------------------------------------------------------------
# 安装
# ------------------------------------------------------------------------------
install_gost() {
  echo "🚀 开始安装 GOST..."
  get_config_params

  apply_mirror

  # 检查并安装 tcpkill
  check_and_install_tcpkill

  mkdir -p "$INSTALL_DIR"

  # 停止并禁用已有服务
  if service_exists; then
    echo "🔍 检测到已存在的 ${SERVICE_NAME} 服务"
    service_stop && echo "🛑 停止服务"
    service_disable && echo "🚫 禁用自启"
  fi

  # 删除旧文件
  [ -f "$INSTALL_DIR/gost" ] && echo "🧹 删除旧文件 gost" && rm -f "$INSTALL_DIR/gost"

  # 下载 gost
  echo "⬇️ 下载 gost 中..."
  echo "   地址: $DOWNLOAD_URL"
  download_file "$DOWNLOAD_URL" "$INSTALL_DIR/gost"
  if [ ! -f "$INSTALL_DIR/gost" ] || [ ! -s "$INSTALL_DIR/gost" ]; then
    echo "❌ 下载失败，请检查网络或下载链接。"
    exit 1
  fi
  chmod +x "$INSTALL_DIR/gost"
  echo "✅ 下载完成"

  # 打印版本
  echo "🔎 gost 版本：$("$INSTALL_DIR/gost" -V 2>/dev/null)"

  # 写入 config.json (安装时总是创建新的)
  CONFIG_FILE="$INSTALL_DIR/config.json"
  echo "📄 创建新配置: config.json"
  cat > "$CONFIG_FILE" <<EOF
{
  "addr": "$SERVER_ADDR",
  "secret": "$SECRET"
}
EOF

  # 写入 gost.json
  GOST_CONFIG="$INSTALL_DIR/gost.json"
  if [ -f "$GOST_CONFIG" ]; then
    echo "⏭️ 跳过配置文件: gost.json (已存在)"
  else
    echo "📄 创建新配置: gost.json"
    cat > "$GOST_CONFIG" <<EOF
{}
EOF
  fi

  # 加强权限
  chmod 600 "$INSTALL_DIR"/*.json 2>/dev/null

  # 创建服务并启动
  if ! service_install_file; then
    echo "⚠️ 服务未注册，请手动运行: $INSTALL_DIR/gost"
    return 0
  fi

  service_reload
  service_enable
  service_start

  # 检查状态
  echo "🔄 检查服务状态..."
  if service_is_active; then
    echo "✅ 安装完成，${SERVICE_NAME} 服务已启动并设置为开机启动。"
    echo "📁 配置目录: $INSTALL_DIR"
    echo "🔧 服务状态: 运行中 (init: ${INIT_SYSTEM})"
  else
    echo "❌ ${SERVICE_NAME} 服务启动失败，请执行以下命令查看日志："
    echo "$(service_log_hint)"
  fi
}

# ------------------------------------------------------------------------------
# 更新
# ------------------------------------------------------------------------------
update_gost() {
  echo "🔄 开始更新 GOST..."

  if [ ! -d "$INSTALL_DIR" ]; then
    echo "❌ GOST 未安装，请先选择安装。"
    return 1
  fi

  apply_mirror
  echo "📥 使用下载地址: $DOWNLOAD_URL"

  # 检查并安装 tcpkill
  check_and_install_tcpkill

  # 先下载新版本
  echo "⬇️ 下载最新版本..."
  download_file "$DOWNLOAD_URL" "$INSTALL_DIR/gost.new"
  if [ ! -f "$INSTALL_DIR/gost.new" ] || [ ! -s "$INSTALL_DIR/gost.new" ]; then
    echo "❌ 下载失败。"
    rm -f "$INSTALL_DIR/gost.new"
    return 1
  fi

  # 停止服务
  if service_exists; then
    echo "🛑 停止 ${SERVICE_NAME} 服务..."
    service_stop
  fi

  # 替换文件
  mv "$INSTALL_DIR/gost.new" "$INSTALL_DIR/gost"
  chmod +x "$INSTALL_DIR/gost"

  # 打印版本
  echo "🔎 新版本：$("$INSTALL_DIR/gost" -V 2>/dev/null)"

  # 重启服务
  echo "🔄 重启服务..."
  service_start

  echo "✅ 更新完成，服务已重新启动。"
}

# ------------------------------------------------------------------------------
# 卸载
# ------------------------------------------------------------------------------
uninstall_gost() {
  echo "🗑️ 开始卸载 GOST..."

  confirm=$(prompt_read "确认卸载 GOST 吗？此操作将删除所有相关文件 (y/N): " "N")
  if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "❌ 取消卸载"
    return 0
  fi

  # 停止并禁用服务
  if service_exists; then
    echo "🛑 停止并禁用服务..."
    service_stop
    service_disable
  fi

  # 删除服务文件
  service_remove_file

  # 删除安装目录
  if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "🧹 删除安装目录: $INSTALL_DIR"
  fi

  # 重载 init
  service_reload

  echo "✅ 卸载完成"
}

# ------------------------------------------------------------------------------
# 主逻辑
# ------------------------------------------------------------------------------
main() {
  init_privilege
  ensure_root
  detect_distro
  detect_init

  # 如果提供了命令行参数，直接执行安装
  if [ -n "$SERVER_ADDR" ] && [ -n "$SECRET" ]; then
    ensure_download_tool || exit 1
    install_gost
    delete_self
    exit 0
  fi

  ensure_download_tool || exit 1

  # 显示交互式菜单
  while true; do
    show_menu
    choice=$(prompt_read "请输入选项 (1-4): " "")

    case "$choice" in
      1)
        install_gost
        delete_self
        exit 0
        ;;
      2)
        update_gost
        delete_self
        exit 0
        ;;
      3)
        uninstall_gost
        delete_self
        exit 0
        ;;
      4)
        echo "👋 退出脚本"
        delete_self
        exit 0
        ;;
      *)
        echo "❌ 无效选项，请输入 1-4"
        echo ""
        ;;
    esac
  done
}

# 执行主函数
main
