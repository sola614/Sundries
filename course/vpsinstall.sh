#!/bin/bash
. /etc/profile
. ~/.bash_profile

ROOT_PATH="/usr/mybash"
SYSTEM_OS=""
INSTALL_CMD=""
green='\033[0;32m'
plain='\033[0m'

show_menu() {
  echo -e "
  常用脚本集合
  ${green}0.${plain} 退出脚本
  ————————————————
  ${green}1.${plain} NEKE家linux网络优化脚本
  ${green}2.${plain} besttrace
  ${green}3.${plain} 探针
  ${green}4.${plain} x-ui
  ${green}5.${plain} 流媒体检测
  ${green}6.${plain} iptables转发
  ${green}7.${plain} 查看本机ip
  ${green}8.${plain} 安装docker
  ${green}9.${plain} 使用nvm安装nodejs
  ${green}10.${plain} 下载cf-v4-ddns
  ${green}11.${plain} DNS解锁
  ${green}12.${plain} iptables屏蔽端口
  ${green}13.${plain} iptables开放端口
 "
    echo && read -p "请输入选择 [0-13]: " num

    case "${num}" in
    0)
        exit 0
        ;;
    1)
        start_neko_linux
        ;;
    2)
        start_besttrace
        ;;
    3)
        start_server_status
        ;;
    4)
        start_xui
        ;;
    5)
        start_check_unlock_media
        ;;
    6)
        start_iptables
        ;;
    7) 
      check_ip
      ;;
    8) 
      docker_install
      ;;
    9) 
      install_nodejs_by_nvm
      ;;
    10) 
      download_cf_v4_ddns
      ;;
    11) 
      dns_unblock
      ;;
    12) 
      read -p "请输入需要屏蔽的端口和协议(默认:tcp): " port protocol
      if [ $port ];then
        echo "$port $protocol"
        ban_iptables $port $protocol
      fi
      ;;
    13) 
      read -p "请输入需要放开的端口: " port protocol
      if [ $port ];then
        unban_iptables $port
      fi
       ;;
    *)
      LOGE "请输入正确的数字 [0-11]"
      ;;
    esac
}
# 判断文件是否存在
check_file_status(){
  if [ ! -f "$1" ]; then
    return 0
  else
    return 1
  fi
}
# 检查命令
check_command(){
  if command -v $1 >/dev/null 2>&1; then
    return 1
  else
    return 0
  fi
}
# 检查文件夹
check_folder_status(){
  if [ ! -d "$1" ]; then
  mkdir $1
fi
}
start_neko_linux(){
  check_file_status $ROOT_PATH/tools.sh
  if [ $? == 0 ]; then
    wget http://sh.nekoneko.cloud/tools.sh -O $ROOT_PATH/tools.sh
  fi
  bash $ROOT_PATH/tools.sh
}
start_besttrace(){
  check_command unzip
  if [ $? == 0 ]; then
    $INSTALL_CMD unzip
  fi
  check_command $ROOT_PATH/besttrace/besttrace
  if [ $? == 0 ]; then
    wget https://cdn.ipip.net/17mon/besttrace4linux.zip -P $ROOT_PATH && unzip -o -d $ROOT_PATH/besttrace $ROOT_PATH/besttrace4linux.zip && sudo chmod -R 777 $ROOT_PATH/besttrace
  fi
  read -p "请输入需要测试的IP或域名: " host
  $ROOT_PATH/besttrace/besttrace -q 1 $host
}
start_server_status(){
  check_file_status $ROOT_PATH/status.sh
  if [ $? == 0 ]; then
    wget https://raw.githubusercontent.com/CokeMine/ServerStatus-Hotaru/master/status.sh -P $ROOT_PATH && chmod +x $ROOT_PATH/status.sh
  fi
  read -p "请输入需要执行客户端还是服务端(c/s)，默认c: " type
  $ROOT_PATH/status.sh ${type:=c}
}
start_xui(){
  check_command x-ui
  if [ $? == 0 ]; then
    bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)
  else
    x-ui
  fi
}
start_check_unlock_media(){
  echo "正在执行流媒体检测脚本，请稍等"
  bash <(curl -L -s check.unlock.media)
}
start_iptables(){
  check_file_status $ROOT_PATH/iptables-pf.sh
  if [ $? == 0 ]; then
     wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/iptables-pf.sh && chmod +x iptables-pf.sh
  fi
  bash iptables-pf.sh
}
get_lan_ip(){
  local_ip=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|awk '{print $2}'|tr -d "addr:"`
}
get_wan_ip(){
  wan_ip=`curl -Ls ip.sb`
}
check_ip(){
  get_lan_ip
  get_wan_ip
  echo -e "内网IP：$local_ip\n外网IP：$wan_ip"
}
docker_install(){
  check_command docker
  if [ $? == 0 ]; then
    $INSTALL_CMD docker
  fi
  echo "docker已安装完毕,正在启动:"
  systemctl start docker
  read -p "是否设置开机启动(y/n): " type
  type=${type:"y"}
  if [ $type == 'y' || $type == 'Y' ];then
    systemctl enable docker
  fi
  echo -e "
  常用命令:
  docker ps [-a]
  docker start/stop/restart/rm [CONTAINER ID or name]
  "
}
install_nodejs_by_nvm(){
  check_command nvm
  if [ $? == 0 ]; then
    wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | sh
    echo "nvm脚本下载完成，请自行重启后执行nvm命令即可"
  fi
  echo -e "
    常用命令:
    nvm install [version or stable] #stable为最新尝鲜版
    nvm use [version] #切换版本
    nvm ls-remote #查看可用的安裝版本
    nvm ls #查看现有配置
  "
}
download_cf_v4_ddns(){
  check_file_status $ROOT_PATH/cf-v4-ddns.sh
  if [ $? == 0 ]; then
    wget https://raw.githubusercontent.com/sola614/sola614/master/course/cf-v4-ddns.sh -P $ROOT_PATH && chmod +x $ROOT_PATH/cf-v4-ddns.sh
    echo "文件已下载"
  else
    echo "文件已存在"
  fi
  echo "如需使用请自行修改$ROOT_PATH/cf-v4-ddns.sh中的参数，并设置crontab定时更改"
}
dns_unblock(){
  read -p "请输入当前机子是否是落地鸡(y/n)，默认y: " flag
  flag=${flag:='y'}
  case $flag in
    Y | y)
      wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/sola614/dnsmasq_sniproxy_install/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -f
      read -p "是否设置白名单(y/n)，默认y: " flag2
      flag2=${flag2:='y'}
      if [ $flag2 == 'y' || $flag2 == 'Y'];then
        ban_iptables 53 tcp
      fi
      get_wan_ip
      echo "落地鸡设置完毕，请在解锁机继续执行本脚本，本机IP为：$wan_ip";;
    N | n)
      $INSTALL_CMD dnsmasq
      echo -e "
      1、请自行编辑/etc/dnsmasq.conf填入以下内容：
        server=8.8.8.8
        server=/需要解锁的域名/解锁ip
      2、编辑 /etc/resolv.conf：
        nameserver 127.0.0.1
      防止重启后失效可以直接编辑 /etc/sysconfig/network-scripts/ifcfg-eth0：
        DNS1=127.0.0.1
        DNS2=8.8.8.8
      保存然后重启即可生效
      3、重启：systemctl restart dnsmasq
      ";;
    *)
     echo "error choice";;
  esac
}
ban_iptables(){
  echo "正在屏蔽$1"
  type=$2
  type=${type:='tcp'}
  iptables -I INPUT -p $type --dport $1 -j DROP
  set_iptables $1 $type
  save_iptables
}
set_iptables(){
  read -p "需要添加白名单？(y/n): " flag
  flag=${flag:='y'}
  case $flag in
    Y | y)
      set_ip_iptables $1 $2;;
    N | n)
      echo "不设置白名单，所以ip都不可访问"
     ;;
    *)
    echo "error choice";;
  esac
}
set_ip_iptables(){
  read -p "请输入开启白名单的ip: " ip
  if [ ip ];then
    iptables -I INPUT -s $ip -p $2 --dport $1 -j ACCEPT
    echo "$ip设置成功"
    read -p "是否继续添加？(y/n): " flag
    case $flag in
      Y | y)
      set_ip_iptables $1 $2
    esac
  fi
}
save_iptables(){
  read -p "是否保存iptables规则，使其重启也可生效(y/n): " flag
  flag=${flag:='y'}
  case $flag in
    Y | y)
    $INSTALL_CMD iptables-services
    service iptables save
    chkconfig iptables on
    ;;
    N | n)
      echo "选择了不保存"
     ;;
    *)
    echo "error choice";;
  esac
 
}
unban_iptables(){
  echo "正在放开端口：$1"
  type=$2
  type=${type:='tcp'}
  iptables -I INPUT -p $type --dport $1 -j ACCEPT
  save_iptables
}


# check os
if [[ -f /etc/redhat-release ]]; then
  SYSTEM_OS="centos"
  INSTALL_CMD="yum install -y"
elif cat /etc/issue | grep -Eqi "debian"; then
  SYSTEM_OS="debian"
  INSTALL_CMD="apt-get install"
elif cat /etc/issue | grep -Eqi "ubuntu"; then
  SYSTEM_OS="ubuntu"
  INSTALL_CMD="apt-get install"
elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
  SYSTEM_OS="centos"
  INSTALL_CMD="yum install -y"
elif cat /proc/version | grep -Eqi "debian"; then
  SYSTEM_OS="debian"
  INSTALL_CMD="apt-get install"
elif cat /proc/version | grep -Eqi "ubuntu"; then
  SYSTEM_OS="ubuntu"
  INSTALL_CMD="apt-get install"
elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
  SYSTEM_OS="centos"
  INSTALL_CMD="yum install -y"
else
    LOGE "未检测到系统版本，请联系脚本作者！\n" && exit 1
fi
# 判断文件夹是否存在
if [ ! -d "${ROOT_PATH}" ]; then
  mkdir $ROOT_PATH
fi
check_command wget
if [ $? == 0 ]; then
  echo "正在安装wget"
  $INSTALL_CMD wget    
fi

show_menu
