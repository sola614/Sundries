#!/bin/bash
installed_version=0
latest_version=0
# 获取操作系统信息
get_os_info() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo "无法检测操作系统版本。"
        exit 1
    fi
}

# 检查 Nginx 是否已安装
is_nginx_installed() {
    if command -v nginx &> /dev/null; then
        echo "true"
    else
        echo "false"
    fi
}

# 检查 Nginx 是否为最新版本
is_nginx_latest() {
    installed_version=$(nginx -v 2>&1 | grep -o '[0-9.]*')
    latest_version=$(curl -s https://nginx.org/en/download.html | grep -oP 'nginx-\K[0-9.]+(?=\.tar\.gz)' | head -n 1)
    if [ "$installed_version" = "$latest_version" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# 提示用户是否更新 Nginx
prompt_update_nginx() {
    echo "当前安装版本为：$installed_version，最新版本为：$latest_version"
    read -p "Nginx 已安装，但不是最新版本。是否要更新？ (y/n): " choice
    case "$choice" in
        y|Y ) return 0 ;;
        n|N ) return 1 ;;
        * ) echo "无效选择"; prompt_update_nginx ;;
    esac
}

# 安装或更新 Nginx 的函数
install_or_update_nginx() {
    if [ "$(is_nginx_installed)" = "true" ]; then
        echo "Nginx 已安装，正在检查版本..."
        if [ "$(is_nginx_latest)" = "true" ]; then
            echo "Nginx 已是最新版本，无需重复安装"
            return
        else
            if prompt_update_nginx; then
                echo "正在更新 Nginx..."
                install_nginx
            else
                echo "已选择不更新 Nginx。"
                return
            fi
        fi
    else
        echo "Nginx 未安装，正在安装..."
        install_nginx
    fi
}

# 各系统对应的 Nginx 安装函数（与之前相同）
install_nginx_ubuntu_debian() {
    echo "检测到 $OS 系统，使用 apt-get 安装最新的 Nginx..."
    sudo apt-get update
    sudo apt-get install -y curl gnupg2 ca-certificates lsb-release
    echo "deb http://nginx.org/packages/$OS/ $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
    sudo apt-get update
    sudo apt-get install -y nginx
}
# 
check_nginx_repo() {
    REPO_FILE="/etc/yum.repos.d/nginx.repo"

    # 检查文件是否存在
    if [ -f "$REPO_FILE" ]; then
        echo "文件 $REPO_FILE 已存在，不会覆盖。"
    else
        # 创建文件并写入内容
        sudo tee "$REPO_FILE" > /dev/null <<EOF
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
EOF

        echo "nginx.repo 文件已成功创建并写入内容。"
    fi
}
install_nginx_centos_rhel() {
    echo "检测到 $OS 系统，使用 yum 安装最新的 Nginx..."
    sudo yum install -y epel-release
    sudo yum install -y yum-utils
    # 检查文件是否存在
    check_nginx_repo
    # 使用默认版本仓库
    sudo yum-config-manager --enable nginx-mainline
    sudo yum install -y nginx
}

install_nginx_fedora() {
    echo "检测到 Fedora 系统，使用 dnf 安装最新的 Nginx..."
    sudo dnf install -y dnf-plugins-core
    sudo dnf config-manager --set-enabled nginx-mainline
    sudo dnf install -y nginx
}

install_nginx_arch_manjaro() {
    echo "检测到 $OS 系统，使用 pacman 安装最新的 Nginx..."
    sudo pacman -Syu --noconfirm nginx-mainline
}

install_nginx_opensuse() {
    echo "检测到 openSUSE/SLES 系统，使用 zypper 安装最新的 Nginx..."
    sudo zypper addrepo -G -f http://nginx.org/packages/sles/$(. /etc/os-release && echo $VERSION_ID)/ nginx
    sudo zypper refresh
    sudo zypper install -y nginx
}

install_nginx_alpine() {
    echo "检测到 Alpine Linux 系统，使用 apk 安装最新的 Nginx..."
    sudo apk add --no-cache nginx
}

install_nginx() {
    case $OS in
        ubuntu|debian)
            install_nginx_ubuntu_debian
            ;;
        centos|rhel|almalinux|rocky)
            install_nginx_centos_rhel
            ;;
        fedora)
            install_nginx_fedora
            ;;
        arch|manjaro)
            install_nginx_arch_manjaro
            ;;
        opensuse-leap|opensuse-tumbleweed|sles)
            install_nginx_opensuse
            ;;
        alpine)
            install_nginx_alpine
            ;;
        *)
            echo "未知的操作系统: $OS。无法安装 Nginx。"
            exit 1
            ;;
    esac
}

# 启动并设置 Nginx 开机自启的函数
start_and_enable_nginx() {
    sudo systemctl start nginx
    sudo systemctl enable nginx
    echo "Nginx 已成功安装并启动。"
}

# 主程序逻辑
get_os_info
install_or_update_nginx
start_and_enable_nginx
