#!/bin/bash

# 检查命令是否存在
check_command() {
  command -v "$1" >/dev/null 2>&1
}

# 安装 Docker 的函数
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

# 开始安装 Docker
docker_install
