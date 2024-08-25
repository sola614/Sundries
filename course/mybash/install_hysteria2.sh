#!/bin/bash

# 检查命令是否存在
check_command() {
  command -v "$1" >/dev/null 2>&1
}

# 安装 Docker
docker_install() {
  if ! check_command docker; then
    echo "正在安装 Docker..."
    curl -fsSL https://get.docker.com | bash
    echo "Docker 已安装完毕，正在启动..."
    systemctl start docker

    read -p "是否设置 Docker 开机启动 (y/n): " flag
    flag=${flag:='y'}
    case $flag in
      Y | y)
        systemctl enable docker
        echo "已设置 Docker 开机启动。"
        ;;
      N | n)
        echo "不设置 Docker 开机启动。"
        ;;
      *)
        echo "无效选项，跳过设置。"
        ;;
    esac

    echo -e "\n常用 Docker 命令:\n"
    echo "docker ps [-a]"
    echo "docker start/stop/restart/rm [CONTAINER ID or name]"
    echo "停止所有容器运行： docker stop \$(docker ps -a -q)"
    echo "删除所有停止运行的容器： docker rm \$(docker ps -a -q)"
  else
    echo "Docker 已经安装。"
  fi
}

# 主安装流程
start_install() {
  if ! check_command docker; then
    docker_install
  fi

  # 检查 hysteria2 是否已经在运行
  if docker ps -q -f "name=^hysteria2$" &>/dev/null; then
    echo "hysteria2 运行中！"
    echo "配置文件路径: /etc/hysteria/server.yaml，请自行修改配置文件并重启服务。"
    exit 1
  fi

  # 配置文件路径
  CONFIG_PATH=/etc/hysteria
  mkdir -p "$CONFIG_PATH/cert"
  CONFIG_FILE="$CONFIG_PATH/server.yaml"

  # 下载默认配置文件
  wget https://raw.githubusercontent.com/sola614/Sundries/master/course/hy2/server.yaml -O "$CONFIG_FILE"

  # 收集用户输入
  read -p "面板地址 (如 http(s)://): " ApiHost
  if [ -z "$ApiHost" ]; then
    echo "面板地址为空！"
    exit 1
  fi

  read -p "面板通讯密钥: " ApiKey
  if [ -z "$ApiKey" ]; then
    echo "面板通讯密钥为空！"
    exit 1
  fi

  read -p "节点 ID: " NodeID
  if [ -z "$NodeID" ]; then
    echo "节点 ID 为空！"
    exit 1
  fi

  read -p "证书名 (如 xxx.yyy.com): " domain
  if [ -z "$domain" ]; then
    echo "证书名为空！"
    exit 1
  fi

  # 写入配置文件
  echo "正在写入配置信息..."
  sed -i "s|^\(\s*apiHost:\).*|\1 $ApiHost|" "$CONFIG_FILE"
  sed -i "s|^\(\s*apiKey:\).*|\1 $ApiKey|" "$CONFIG_FILE"
  sed -i "s|^\(\s*nodeID:\).*|\1 $NodeID|" "$CONFIG_FILE"
  sed -i "s|^\(\s*cert:\s*/etc/hysteria/cert/\)[^ ]*|\1${domain}.pem|" "$CONFIG_FILE"
  sed -i "s|^\(\s*key:\s*/etc/hysteria/cert/\)[^ ]*|\1${domain}.key|" "$CONFIG_FILE"

  # 启动 hysteria2 容器
  echo "正在启动 hysteria2..."
  docker run -itd --restart=unless-stopped --network=host -v "$CONFIG_PATH:/etc/hysteria" --name hysteria2 ghcr.io/cedar2025/hysteria:latest

  echo "请自行准备好证书放在 /etc/hysteria/cert 下，然后重启服务。配置文件路径: /etc/hysteria/server.yaml"
}

# 开始安装流程
start_install
