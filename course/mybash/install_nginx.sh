#!/bin/bash

# 获取操作系统的名称和版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    echo "无法检测操作系统版本。"
    exit 1
fi

# 安装 Nginx 最新版
case $OS in
    ubuntu|debian)
        echo "检测到 $OS 系统，使用 apt-get 安装最新的 Nginx..."
        sudo apt-get update
        sudo apt-get install -y curl gnupg2 ca-certificates lsb-release
        echo "deb http://nginx.org/packages/$OS/ $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
        curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
        sudo apt-get update
        sudo apt-get install -y nginx
        ;;
    centos|rhel|almalinux|rocky)
        echo "检测到 $OS 系统，使用 yum 安装最新的 Nginx..."
        sudo yum install -y epel-release
        sudo yum install -y yum-utils
        sudo yum-config-manager --enable nginx-mainline
        sudo yum install -y nginx
        ;;
    fedora)
        echo "检测到 Fedora 系统，使用 dnf 安装最新的 Nginx..."
        sudo dnf install -y dnf-plugins-core
        sudo dnf config-manager --set-enabled nginx-mainline
        sudo dnf install -y nginx
        ;;
    arch|manjaro)
        echo "检测到 $OS 系统，使用 pacman 安装最新的 Nginx..."
        sudo pacman -Syu --noconfirm nginx-mainline
        ;;
    opensuse-leap|opensuse-tumbleweed|sles)
        echo "检测到 openSUSE/SLES 系统，使用 zypper 安装最新的 Nginx..."
        sudo zypper addrepo -G -f http://nginx.org/packages/sles/$(. /etc/os-release && echo $VERSION_ID)/ nginx
        sudo zypper refresh
        sudo zypper install -y nginx
        ;;
    alpine)
        echo "检测到 Alpine Linux 系统，使用 apk 安装最新的 Nginx..."
        sudo apk add --no-cache nginx
        ;;
    *)
        echo "未知的操作系统: $OS。无法安装 Nginx。"
        exit 1
        ;;
esac

# 启动并设置 Nginx 开机自启
sudo systemctl start nginx
sudo systemctl enable nginx

echo "Nginx 已成功安装并启动。"
