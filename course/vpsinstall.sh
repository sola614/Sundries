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
 "
    echo && read -p "请输入选择 [0-7]: " num

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
    *)
        LOGE "请输入正确的数字 [0-7]"
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
