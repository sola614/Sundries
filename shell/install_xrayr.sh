#!/bin/bash

# 判断是否是 Alpine Linux
is_alpine() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    [ "$ID" = "alpine" ]
  else
    echo "无法检测操作系统版本。"
    exit 1
  fi
}

# 检查命令是否存在
check_command() {
  command -v "$1" >/dev/null 2>&1
}

# 安装 XrayR
install_xrayr() {
  if is_alpine; then
    apk add wget sudo curl
    wget -N https://github.com/Cd1s/alpineXrayR/releases/download/one-click/install-xrayr.sh
    chmod +x install-xrayr.sh
    bash install-xrayr.sh
  else
    if ! check_command xrayr; then
      wget -N https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh
      bash install.sh
    fi
  fi
}

# 配置 XrayR
configure_xrayr() {
  read -p "面板类型 (SSpanel, V2board, NewV2board, PMpanel, Proxypanel, V2RaySocks): " PanelType
  [ -z "$PanelType" ] && { echo "面板类型为空！"; exit 1; }
  
  read -p "面板地址 (如 http(s)://): " ApiHost
  [ -z "$ApiHost" ] && { echo "面板地址为空！"; exit 1; }
  
  ApiHost=$(echo "$ApiHost" | sed 's/\//\\\//g')
  
  read -p "面板通讯密钥: " ApiKey
  [ -z "$ApiKey" ] && { echo "面板通讯密钥为空！"; exit 1; }
  
  read -p "节点 ID: " NodeID
  [ -z "$NodeID" ] && { echo "节点 ID 为空！"; exit 1; }
  
  read -p "节点类型 (V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin): " NodeType
  [ -z "$NodeType" ] && { echo "节点类型为空！"; exit 1; }
  
  echo "正在写入配置信息..."
  CONFIG_PATH=/etc/XrayR/config.yml
  sed -i "s/PanelType: .*/PanelType: \"${PanelType}\"/" "$CONFIG_PATH"
  sed -i "s/ApiHost: .*/ApiHost: \"${ApiHost}\"/" "$CONFIG_PATH"
  sed -i "s/ApiKey: .*/ApiKey: \"${ApiKey}\"/" "$CONFIG_PATH"
  sed -i "s/NodeID: .*/NodeID: ${NodeID}/" "$CONFIG_PATH"
  sed -i "s/NodeType: .*/NodeType: ${NodeType}/" "$CONFIG_PATH"
  sed -i "s/EnableREALITY: .*/NodeType: false/" "$CONFIG_PATH"
  
  echo "正在启动 XrayR..."
  if is_alpine; then
    /etc/init.d/XrayR restart
  else
    XrayR start
  fi
}

# 执行主安装流程
install_xrayr
configure_xrayr
