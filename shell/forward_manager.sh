#!/bin/sh

# 检查是否以 root 权限运行
if [ "$(id -u)" -ne 0 ]; then
    echo "错误：请使用 root 权限运行此脚本！"
    exit 1
fi

# 显示主菜单：选择工具
show_main_menu() {
    clear
    echo "========================================"
    echo "      多功能端口转发统一管理脚本        "
    echo "========================================"
    echo "1. Iptables / Firewall (系统内核转发，适合纯TCP/UDP映射)"
    echo "2. Realm (高性能 Rust 转发，支持TCP/UDP及TLS)"
    echo "3. Gost (全协议隧道转发工具)"
    echo "4. Socat (轻量级双向数据流转发)"
    echo "5. 退出脚本"
    echo "========================================"
}

# ----------------------------------------------------------------
# 1. IPTABLES 模块
# ----------------------------------------------------------------
manage_iptables() {
    while true; do
        clear
        echo "========================================"
        echo "        Iptables 转发管理菜单           "
        echo "========================================"
        echo "1. 添加 Iptables 转发规则 (支持域名)"
        echo "2. 查看 Iptables 转发规则"
        echo "3. 删除指定的 Iptables 规则"
        echo "4. 返回上级菜单"
        echo "========================================"
        read -p "请选择操作 [1-4]: " ipt_choice

        case "$ipt_choice" in
            1)
                # 检查并安装 iptables
                if ! command -v iptables >/dev/null 2>&1; then
                    echo "正在安装 iptables..."
                    if command -v apt-get >/dev/null 2>&1; then apt-get update && apt-get install -y iptables
                    elif command -v apk >/dev/null 2>&1; then apk update && apk add iptables
                    elif command -v dnf >/dev/null 2>&1; then dnf install -y iptables
                    elif command -v yum >/dev/null 2>&1; then yum install -y iptables; fi
                fi
                sysctl -w net.ipv4.ip_forward=1 >/dev/null 2>&1

                read -p "请输入本地监听端口: " local_port
                read -p "请输入目标地址 (IP 或 域名): " target_host
                read -p "请输入目标端口: " target_port

                if [ -z "$local_port" ] || [ -z "$target_host" ] || [ -z "$target_port" ]; then
                    echo "错误：内容不能为空！"
                else
                    echo "正在解析目标地址..."
                    target_ip=$(getent ahosts "$target_host" 2>/dev/null | awk '{print $1}' | head -n 1)
                    if [ -z "$target_ip" ]; then
                        target_ip=$(ping -c 1 "$target_host" 2>/dev/null | head -n 1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
                    fi
                    if [ -z "$target_ip" ] && echo "$target_host" | grep -E '^[0-9.]+$' >/dev/null; then
                        target_ip="$target_host"
                    fi

                    if [ -z "$target_ip" ]; then
                        echo "错误：无法解析目标地址 [$target_host]"
                    else
                        for proto in tcp udp; do
                            iptables -t nat -A PREROUTING -p "$proto" --dport "$local_port" -j DNAT --to-destination "$target_ip":"$target_port"
                            iptables -t nat -A POSTROUTING -p "$proto" -d "$target_ip" --dport "$target_port" -j MASQUERADE
                            iptables -A FORWARD -p "$proto" -d "$target_ip" --dport "$target_port" -j ACCEPT
                        done
                        echo "成功添加 Iptables 转发: :$local_port -> $target_ip:$target_port"
                    fi
                fi
                ;;
            2)
                echo "=== NAT 转发规则列表 ==="
                iptables -t nat -L PREROUTING -v -n --line-numbers
                echo ""
                echo "=== FORWARD 过滤规则列表 ==="
                iptables -L FORWARD -v -n --line-numbers
                ;;
            3)
                iptables -t nat -L PREROUTING -v -n --line-numbers
                read -p "请输入要删除的 PREROUTING 规则序号: " line_num
                if [ -n "$line_num" ]; then
                    iptables -t nat -D PREROUTING "$line_num"
                    echo "规则已删除（建议检查并清理关联的FORWARD规则）。"
                fi
                ;;
            4)
                break
                ;;
        esac
        echo ""
        read -p "按回车键继续..." dummy
    done
}

# ----------------------------------------------------------------
# 2. REALM 模块 (Rust 编写的高性能转发，极其稳定防kill)
# ----------------------------------------------------------------
manage_realm() {
    # 检查 realm 是否存在，不存在提示安装
    if ! command -v realm >/dev/null 2>&1; then
        echo "检测到未安装 Realm 转发工具。"
        read -p "是否自动下载安装 Realm? (y/n): " install_realm
        if [ "$install_realm" = "y" ] || [ "$install_realm" = "Y" ]; then
            echo "正在下载安装 Realm..."
            # 自动获取最新版本或下载通用二进制
            ARCH=$(uname -m)
            if [ "$ARCH" = "x86_64" ]; then
                REALM_URL="https://github.com/zhadao/realm/releases/latest/download/realm-x86_64-unknown-linux-musl.tar.gz"
            elif [ "$ARCH" = "aarch64" ]; then
                REALM_URL="https://github.com/zhadao/realm/releases/latest/download/realm-aarch64-unknown-linux-musl.tar.gz"
            else
                echo "不支持的架构: $ARCH"
                return
            fi
            wget -O realm.tar.gz "$REALM_URL" && tar -zxvf realm.tar.gz && chmod +x realm && mv realm /usr/local/bin/ && rm -f realm.tar.gz LICENSE README.md
            mkdir -p /etc/realm
        else
            return
        fi
    fi

    # 确保配置文件存在
    CONFIG_FILE="/etc/realm/config.json"
    if [ ! -f "$CONFIG_FILE" ]; then
        echo '{"endpoints": []}' > "$CONFIG_FILE"
    fi

    while true; do
        clear
        echo "========================================"
        echo "         Realm 转发管理菜单             "
        echo "========================================"
        echo "1. 添加 Realm 转发规则 (支持域名/IP)"
        echo "2. 查看当前 Realm 规则"
        echo "3. 启动/重启 Realm 服务"
        echo "4. 返回上级菜单"
        echo "========================================"
        read -p "请选择操作 [1-4]: " realm_choice

        case "$realm_choice" in
            1)
                read -p "请输入本地监听端口: " l_port
                read -p "请输入目标地址 (支持域名或IP): " r_addr
                read -p "请输入目标端口: " r_port

                if [ -z "$l_port" ] || [ -z "$r_addr" ] || [ -z "$r_port" ]; then
                    echo "错误：内容不能为空！"
                else
                    # 借助 Python 或 Node 或 awk 简单向 json 中插入数据（此处用简单文件追加或重写，或者直接引导用户）
                    echo "提示：Realm 原生支持域名。建议将规则写入 /etc/realm/config.json。"
                    echo "当前规则格式模板："
                    echo "  { \"listen\": \"0.0.0.0:$l_port\", \"remote\": \"$r_addr:$r_port\" }"
                    echo "你可以手动编辑 $CONFIG_FILE 文件，或使用专业管理面板。"
                fi
                ;;
            2)
                if [ -f "$CONFIG_FILE" ]; then
                    echo "=== Realm 配置文件内容 ==="
                    cat "$CONFIG_FILE"
                else
                    echo "暂无配置文件。"
                fi
                ;;
            3)
                # 后台运行 realm
                pkill realm
                nohup realm -c "$CONFIG_FILE" > /var/log/realm.log 2>&1 &
                echo "Realm 服务已重新启动！日志输出在 /var/log/realm.log"
                ;;
            4)
                break
                ;;
        esac
        echo ""
        read -p "按回车键继续..." dummy
    done
}

# ----------------------------------------------------------------
# 3. GOST 模块
# ----------------------------------------------------------------
manage_gost() {
    while true; do
        clear
        echo "========================================"
        echo "          Gost 转发管理菜单             "
        echo "========================================"
        echo "1. 使用命令行快速启动 Gost 转发"
        echo "2. 返回上级菜单"
        echo "========================================"
        read -p "请选择操作 [1-2]: " gost_choice

        case "$gost_choice" in
            1)
                if ! command -v gost >/dev/null 2>&1; then
                    echo "检测到未安装 gost，正在尝试通过 apk/wget 安装..."
                    apk add gost 2>/dev/null || echo "请手动安装 gost 后使用。"
                fi
                read -p "请输入本地监听端口: " g_local
                read -p "请输入目标地址 (域名/IP): " g_remote_host
                read -p "请输入目标端口: " g_remote_port
                
                if [ -n "$g_local" ] && [ -n "$g_remote_host" ] && [ -n "$g_remote_port" ]; then
                    # 以后台进程运行 gost 转发
                    nohup gost -L="tcp://:$g_local/$g_remote_host:$g_remote_port" -L="udp://:$g_local/$g_remote_host:$g_remote_port" > /var/log/gost.log 2>&1 &
                    echo "Gost 转发已在后台启动！监听端口: $g_local ==> 目标: $g_remote_host:$g_remote_port"
                fi
                ;;
            2)
                break
                ;;
        esac
        echo ""
        read -p "按回车键继续..." dummy
    done
}

# ----------------------------------------------------------------
# 4. SOCAT 模块
# ----------------------------------------------------------------
manage_socat() {
    if ! command -v socat >/dev/null 2>&1; then
        echo "正在安装 socat..."
        if command -v apt-get >/dev/null 2>&1; then apt-get update && apt-get install -y socat
        elif command -v apk >/dev/null 2>&1; then apk update && apk add socat
        elif command -v dnf >/dev/null 2>&1; then dnf install -y socat; fi
    fi

    echo ""
    read -p "请输入本地监听端口: " s_local
    read -p "请输入目标 IP/域名: " s_host
    read -p "请输入目标端口: " s_port

    if [ -n "$s_local" ] && [ -n "$s_host" ] && [ -n "$s_port" ]; then
        # 解析域名为 IP（socat 对域名的支持在部分版本不稳定，统一转为 IP）
        s_ip=$(getent ahosts "$s_host" 2>/dev/null | awk '{print $1}' | head -n 1)
        [ -z "$s_ip" ] && s_ip="$s_host"
        
        nohup socat TCP-LISTEN:"$s_local",fork,reuseaddr TCP:"$s_ip":"$s_port" > /var/log/socat_"$s_local".log 2>&1 &
        echo "Socat 转发已成功在后台运行！"
    fi
}

# 主循环
while true; do
    show_main_menu
    read -p "请选择您要使用的转发工具 [1-5]: " main_choice
    case "$main_choice" in
        1) manage_iptables ;;
        2) manage_realm ;;
        3) manage_gost ;;
        4) manage_socat ;;
        5) echo "退出脚本。" ; exit 0 ;;
        *) echo "无效选择，请重新输入。" ;;
    esac
    echo ""
    read -p "按回车键返回主菜单..." dummy
done
