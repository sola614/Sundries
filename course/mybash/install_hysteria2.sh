hysteria2_install(){
   check_command docker
  if [ $? == 0 ]; then
    echo "正在安装docker"
    docker_install
  fi
  if [[ -n $(docker ps -q -f "name=^hysteria2$") ]];then
    echo "hysteria2运行中！"
    echo "配置文件路径:/etc/hysteria/server.yaml，请自行修改配置文件&restart即可"
    exit 1
  fi
  CONFIG_PATH=/etc/hysteria
  mkdir $CONFIG_PATH
  mkdir $CONFIG_PATH/cert
  CONFIG_FILE=$CONFIG_PATH/server.yaml
  wget https://raw.githubusercontent.com/sola614/Sundries/master/course/hy2/server.yaml -O $CONFIG_FILE
  read -p "面板地址(如http(s)://): " ApiHost
  if [ -z "$ApiHost" ]; then
    echo "面板地址为空！"
    exit 1
  fi
  #转义//
  # ApiHost=$(echo "$ApiHost" | sed 's/\//\\\//g')
  read -p "面板通讯密钥: " ApiKey
  if [ -z "$ApiKey" ]; then
    echo "板通讯密钥为空！"
    exit 1
  fi
  read -p "节点id: " NodeID
  if [ -z "$NodeID" ]; then
    echo "节点id为空！"
    exit 1
  fi
  read -p "证书名(如xxx.yyy.com): " domain
  if [ -z "$domain" ]; then
    echo "证书名为空！"
    exit 1
  fi

  echo "正在写入配置信息"
  # 修改 apiHost
  sed -i "s|^\(\s*apiHost:\).*|\1 ${ApiHost}|" $CONFIG_FILE
  # 修改 apiKey
  sed -i "s|^\(\s*apiKey:\).*|\1 ${ApiKey}|" $CONFIG_FILE
  # 修改 nodeID
  sed -i "s|^\(\s*nodeID:\).*|\1 ${NodeID}|" $CONFIG_FILE
  # 修改 xxx.pem
  sed -i "s|^\(\s*cert:\s*/etc/hysteria/cert/\)[^ ]*|\1${domain}.pem|" $CONFIG_FILE
  #  修改yyy.key
  sed -i "s|^\(\s*key:\s*/etc/hysteria/cert/\)[^ ]*|\1${domain}.key|" $CONFIG_FILE
  echo "正在启动"
  docker run -itd --restart=unless-stopped  --network=host -v /etc/hysteria:/etc/hysteria --name hysteria2 ghcr.io/cedar2025/hysteria:latest
  echo "请自行准备好证书放在/etc/hysteria/cert下，然后重启服务，配置文件路径:/etc/hysteria/server.yaml"
}
hysteria2_install
