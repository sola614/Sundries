#!/bin/bash
ROOT_PATH="/usr/mybash"
SYSTEM_OS=""
INSTALL_CMD=""
green='\033[0;32m'
plain='\033[0m'
BOLD='\033[1m'
CYAN='\033[0;36m'
# 获取操作系统的名称和版本
if [ -f /etc/os-release ]; then
    . /etc/os-release
    SYSTEM_OS=$ID
    VERSION=$VERSION_ID
else
    echo "无法检测操作系统版本。"
    exit 1
fi
# 根据不同的发行版赋予不同的安装命令
case $SYSTEM_OS in
    ubuntu|debian)
        INSTALL_CMD="apt install -y";;
    centos|rhel|almalinux|rocky)
        INSTALL_CMD="yum install -y";;
    fedora)
        INSTALL_CMD="dnf install -y";;
    arch|manjaro)
        INSTALL_CMD="pacman -Syu";;
    opensuse-leap|opensuse-tumbleweed|sles)
        INSTALL_CMD="zypper install -y";;
    alpine)
        INSTALL_CMD="apk add --no-cache";;
    *)
        echo "未知的操作系统: $OS。无法安装软件。"
        exit 1
        ;;
esac
echo "检测到:$SYSTEM_OS系统，版本为：$VERSION，软件安装命令为：$INSTALL_CMD"
# 判断文件夹是否存在
if [ ! -d "${ROOT_PATH}" ]; then
  mkdir $ROOT_PATH
fi

show_menu() {
  while true; do
    echo -e "
  ${BOLD}常用脚本集合${plain}
  ════════════════════════════════
  ${green}0.${plain}  更新脚本
  ${green}1.${plain}  网络工具
  ${green}2.${plain}  流媒体检测
  ${green}3.${plain}  代理/节点
  ${green}4.${plain}  DNS相关
  ${green}5.${plain}  防火墙/转发
  ${green}6.${plain}  Cloudflare Warp
  ${green}7.${plain}  环境/软件安装
  ${green}8.${plain}  证书/TLS
  ${green}9.${plain}  监控/其他
  ${green}999.${plain} 初始化安装
  ${green}q.${plain}  退出
    "
    read -p "请选择分组 [0-9/999/q]: " group
    case "$group" in
      0) update_sh ;;
      1) menu_network ;;
      2) menu_media ;;
      3) menu_proxy ;;
      4) menu_dns ;;
      5) menu_firewall ;;
      6) menu_warp ;;
      7) menu_software ;;
      8) menu_tls ;;
      9) menu_other ;;
      999) vps_install ;;
      q|Q) exit 0 ;;
      *) echo "请输入正确的选项" ;;
    esac
  done
}

menu_network() {
  echo -e "
  ${CYAN}── 网络工具 ──${plain}
  ${green}1.${plain}  NEKE家linux网络优化脚本
  ${green}2.${plain}  nexttrace路由跟踪工具
  ${green}3.${plain}  三网回程路由测试
  ${green}4.${plain}  查看本机ip
  ${green}5.${plain}  快速查询本机IP和区域
  ${green}6.${plain}  测试ip被ban脚本
  ${green}7.${plain}  IPv4/6 Switch
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-7]: " num
  case "$num" in
    1) start_neko_linux ;;
    2) next_trace ;;
    3) mtr_trace ;;
    4) check_ip ;;
    5) check_ip_location ;;
    6) ip_test ;;
    7) bash <(curl -L -s https://raw.githubusercontent.com/ChellyL/ipv4-6-switch/main/ipv_switch.sh) ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_media() {
  echo -e "
  ${CYAN}── 流媒体检测 ──${plain}
  ${green}1.${plain}  流媒体检测脚本集合
  ${green}2.${plain}  一键检测Netflix和ChatGPT解锁状态
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-2]: " num
  case "$num" in
    1) bash <(curl -L -s https://raw.githubusercontent.com/sola614/Sundries/refs/heads/master/shell/check_media.sh) ;;
    2)
      echo "脚本1开始检测..."
      bash <(curl -Ls https://file.meaqua.fun/shell/check_gpt.sh)
      echo "脚本2开始检测..."
      bash <(curl -Ls https://cdn.jsdelivr.net/gh/missuo/OpenAI-Checker/openai.sh)
      ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_proxy() {
  echo -e "
  ${CYAN}── 代理/节点 ──${plain}
  ${green}1.${plain}  一键安装XrayR后端
  ${green}2.${plain}  x-ui安装
  ${green}3.${plain}  Hi Hysteria脚本
  ${green}4.${plain}  docker安装Hysteria2后端对接xboard
  ${green}5.${plain}  xboard-node安装脚本
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-5]: " num
  case "$num" in
    1) xrayr_install ;;
    2) start_xui ;;
    3) hi_hysteria_install ;;
    4) hysteria2_install ;;
    5) xboard_node_install ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_dns() {
  echo -e "
  ${CYAN}── DNS相关 ──${plain}
  ${green}1.${plain}  dnsproxy
  ${green}2.${plain}  基于CloudFlare的DDNS解析(cf-v4-ddns.sh)
  ${green}3.${plain}  安装dnsmasq或sniproxy实现自建DNS解锁
  ${green}4.${plain}  永久修改DNS
  ${green}5.${plain}  node-ddns
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-5]: " num
  case "$num" in
    1) dnsproxy ;;
    2) download_cf_v4_ddns ;;
    3) dns_unblock ;;
    4) dns_change ;;
    5) node_ddns ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_firewall() {
  echo -e "
  ${CYAN}── 防火墙/转发 ──${plain}
  ${green}1.${plain}  iptables端口转发
  ${green}2.${plain}  iptables端口转发(支持域名)
  ${green}3.${plain}  iptables屏蔽端口
  ${green}4.${plain}  iptables开放端口
  ${green}5.${plain}  gost脚本(ipv4转发到ipv6)
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-5]: " num
  case "$num" in
    1) start_iptables ;;
    2) start_iptables2 ;;
    3)
      read -p "请输入需要屏蔽的端口和协议(默认:tcp): " port protocol
      if [ $port ]; then
        ban_iptables $port $protocol
      fi
      ;;
    4)
      read -p "请输入需要放开的端口: " port protocol
      if [ $port ]; then
        unban_iptables $port
      fi
      ;;
    5) gost_install ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_warp() {
  echo -e "
  ${CYAN}── Cloudflare Warp ──${plain}
  ${green}1.${plain}  Cloudflare Warp GO一键脚本
  ${green}2.${plain}  Cloudflare Warp一键脚本
  ${green}3.${plain}  warp多功能一键脚本
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-3]: " num
  case "$num" in
    1) warp_go_install ;;
    2) warp_install ;;
    3) bash <(wget -qO- https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh 2> /dev/null) ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_software() {
  echo -e "
  ${CYAN}── 环境/软件安装 ──${plain}
  ${green}1.${plain}  安装docker
  ${green}2.${plain}  使用nvm安装nodejs
  ${green}3.${plain}  安装nginx
  ${green}4.${plain}  centos7升级curl
  ${green}5.${plain}  一键更换系统软件源脚本
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-5]: " num
  case "$num" in
    1) docker_install ;;
    2) install_nodejs_by_nvm ;;
    3) nginx_install ;;
    4) update_curl_centos7 ;;
    5) change_sys_repo ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_tls() {
  echo -e "
  ${CYAN}── 证书/TLS ──${plain}
  ${green}1.${plain}  一键准备nginx和利用acme申请证书
  ${green}2.${plain}  acme申请证书(CF_DNS模式)
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-2]: " num
  case "$num" in
    1) ws_tls_install ;;
    2) acme_install ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
  esac
}

menu_other() {
  echo -e "
  ${CYAN}── 监控/其他 ──${plain}
  ${green}1.${plain}  安装wikihost-Looking-glass Server
  ${green}2.${plain}  安装哪吒监控
  ${green}3.${plain}  一键DD系统脚本
  ${green}0.${plain}  返回主菜单
  "
  read -p "请选择 [0-3]: " num
  case "$num" in
    1) wikihost_LookingGlass_install ;;
    2) nezha_sh ;;
    3)
      echo "正在下载脚本，默认为国外版链接，如果长时间下载不下来，请使用国内版命令：curl -O https://jihulab.com/bin456789/reinstall/-/raw/main/reinstall.sh"
      curl -O https://raw.githubusercontent.com/bin456789/reinstall/main/reinstall.sh
      ;;
    0) return ;;
    *) echo "请输入正确的选项" ;;
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
# 检查文件是否包含某字段
check_file_str(){
  if grep -c $1 $2; then
    return 1
  else
    return 0
  fi
}
update_sh(){
  echo "正在下载最新文件到当前目录"
  wget -O vpsinstall.sh https://file.meaqua.fun/shell/vpsinstall.sh
  sed -i 's/\r$//' ./vpsinstall.sh && bash ./vpsinstall.sh
}
vps_install(){
  echo "正在安装依赖..."
  TOOLS=("vim" "wget" "unzip" "tar" "mtr" "curl" "crontabs" "socat" "iptables-services" "net-tools" "cronie" "bind-utils")
  # 遍历工具列表
  for TOOL in "${TOOLS[@]}"; do
      echo "正在检查 $TOOL..."
      if ! command -v $TOOL &>/dev/null; then
          echo "$TOOL 未安装，尝试安装..."
          if ! sudo $INSTALL_CMD install -y $TOOL; then
              echo "安装 $TOOL 失败，跳过。"
          else
              echo "$TOOL 安装成功。"
          fi
      else
          echo "$TOOL 已安装，跳过。"
      fi
  done

  echo "所有工具检查和安装完成。如果遇到错误安装不上，请根据自身系统搜索相关安装指令进行安装"
  # $INSTALL_CMD vim wget unzip tar mtr curl crontabs socat iptables-services net-tools cronie bind-utils
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
    wget https://cdn.ipip.net/17mon/besttrace4linux.zip -P $ROOT_PATH && unzip -o -d $ROOT_PATH/besttrace $ROOT_PATH/besttrace4linux.zip && chmod -R 777 $ROOT_PATH/besttrace
  fi
  read -p "请输入需要测试的IP或域名: " host
  $ROOT_PATH/besttrace/besttrace -q 1 $host
  read -p "是否继续测试(y/n): " flag
  flag=${flag:='y'}
  case $flag in
    Y | y)
     start_besttrace;;
    *)
    exit 1;;
  esac

}
xrayr_install(){
    bash <(curl -fsSL https://file.meaqua.fun/shell/install_xrayr.sh)
}
hi_hysteria_install(){
  bash <(curl -fsSL https://git.io/hysteria.sh)
}
nezha_sh(){
  check_file_status $ROOT_PATH/nezha.sh
   if [ $? == 0 ]; then
    wget https://raw.githubusercontent.com/naiba/nezha/master/script/install.sh -O $ROOT_PATH/nezha.sh && chmod +x $ROOT_PATH/nezha.sh
  fi
  $ROOT_PATH/nezha.sh
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
start_neko_unlock_test(){
  echo "正在执行流媒体检测脚本，请稍等"
  bash <(curl -Ls unlock.moe)
}
start_iptables(){
  check_file_status $ROOT_PATH/iptables-pf.sh
  if [ $? == 0 ]; then
     wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/iptables-pf.sh -P $ROOT_PATH && chmod +x $ROOT_PATH/iptables-pf.sh
  fi
  bash $ROOT_PATH/iptables-pf.sh
}
start_iptables2(){
  check_file_status $ROOT_PATH/natcfg.sh
  if [ $? == 0 ]; then
    wget --no-check-certificate https://www.arloor.com/sh/iptablesUtils/natcfg.sh -P $ROOT_PATH
  fi
  bash $ROOT_PATH/natcfg.sh
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
check_ip_location(){
    bash <(curl -L -s https://raw.githubusercontent.com/ChellyL/ipv4-6-switch/main/46test.sh)
  # curl 3.0.3.0
}
docker_install(){
  bash <(curl -fsSL https://file.meaqua.fun/shell/install_docker.sh)
}
install_nodejs_by_nvm(){
  check_command nvm
  if [ $? == 0 ]; then
    wget -qO- https://raw.github.com/creationix/nvm/master/install.sh | bash
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
    wget https://file.meaqua.fun/shell/cf-v4-ddns.sh -P $ROOT_PATH && chmod +x $ROOT_PATH/cf-v4-ddns.sh
    echo "文件已下载"
    reset_cf_ddns
  else
    read -p "文件已存在,是否更改配置?: " flag
    case $flag in
    Y | y)
      reset_cf_ddns;;
    esac
  fi
  
}
reset_cf_ddns(){
  all=".*"
  read -p "请输入CFKEY(即Global API Key,获取https://dash.cloudflare.com/profile/api-tokens):" cfkey
  str="CFKEY="
  sed -i "0,/${str}${all}/s/${str}${all}/${str}${cfkey}/" $ROOT_PATH/cf-v4-ddns.sh
  read -p "请输入CFUSER(即登陆CF的邮箱):" cfuser
  str="CFUSER="
  sed -i "0,/${str}${all}/s/${str}${all}/${str}${cfuser}/" $ROOT_PATH/cf-v4-ddns.sh
  read -p "请输入CFZONE_NAME(即根域名):" cfzone_name
  str="CFZONE_NAME="
  sed -i "0,/${str}${all}/s/${str}${all}/${str}${cfzone_name}/" $ROOT_PATH/cf-v4-ddns.sh
  read -p "请输入CFRECORD_NAME(即子域名前缀,如a.example.com则填写a):" cfrecord_name
  str="CFRECORD_NAME="
  sed -i "0,/${str}${all}/s/${str}${all}/${str}${cfrecord_name}/" $ROOT_PATH/cf-v4-ddns.sh
  set_crontab "*/2 * * * * $ROOT_PATH/cf-v4-ddns.sh >/dev/null 2>&1"
  echo "全部配置完毕，已启动crontab定时执行脚本"
}
set_crontab(){
  crontab -l > crontab_conf
  echo "$*" >> crontab_conf
  crontab crontab_conf
  rm -f crontab_conf
}
dns_unblock(){
  read -p "当前vps是否为提供解锁的机器(y/n)，默认y: " flag
  flag=${flag:='y'}
  case $flag in
    Y | y)
      wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/sola614/dnsmasq_sniproxy_install/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -f
      read -p "是否设置白名单，即ban掉53端口，需要自行添加可访问的ip(y/n)，默认y: " flag2
      flag2=${flag2:='y'}
      if [ $flag2 == 'y' || $flag2 == 'Y'];then
        ban_iptables 53 tcp
      fi
      get_wan_ip
      echo "本机设置完毕，请在需要解锁的vps上执行本脚本，本机IP为：$wan_ip";;
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
      保存然后service network restart即可生效
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
nginx_install(){
    bash <(curl -fsSL https://file.meaqua.fun/shell/install_nginx.sh)
}
ip_test(){
  check_file_status $ROOT_PATH/testip.sh
  if [ $? == 0 ]; then
    wget -O $ROOT_PATH/testip.sh https://file.meaqua.fun/shell/testip.sh && chmod +x $ROOT_PATH/testip.sh
  fi
  
  $ROOT_PATH/testip.sh
}
wikihost_LookingGlass_install(){
  echo '正在安装docker'
  docker_install
  read -p "是否自定义端口（默认为80）: " port
  port=${port:='80'}
  docker run -d --restart always --name looking-glass -e HTTP_PORT=$port --network host wikihostinc/looking-glass-server
}
dns_change(){
  FILE_PATH=/etc/sysconfig/network-scripts/ifcfg-eth0
  check_file_status $FILE_PATH
  if [ $? == 0 ]; then
    echo "不存在配置文件ifcfg-eth0，无法进行操作" && exit 1
  fi
  read -p "请输入需要更换的dnsip(多个以;分割): " dns_str
  dns_str=${dns_str:='1.1.1.1'}
  #分割字符串
  IFS=';' read -ra dns_addr <<< "$dns_str"
  #循环插入||替换
  for ((i = 0; i < ${#dns_addr[@]}; ++i)); do
    index=$(( $i + 1 ))
    name_str="DNS$index="
    dnsip=${dns_addr[$i]}
    check_file_str $name_str $FILE_PATH
    if [ $? == 0 ]; then
      # 插入
      echo "$name_str$dnsip" >> $FILE_PATH
    else 
      # 替换
      all=".*"
      sed -i "0,/${name_str}${all}/s/${name_str}${all}/${name_str}${dnsip}/" $FILE_PATH
    fi
  done
  echo "正在重启网络"
  service network restart
  echo "已设置完成，可执行nslookup xxx.com验证"
}
mtr_trace(){
  echo "正在执行请等待..."
  curl https://raw.githubusercontent.com/zhanghanyun/backtrace/main/install.sh -sSf | sh
  # curl https://raw.githubusercontent.com/zhucaidan/mtr_trace/main/mtr_trace.sh|bash;
}
next_trace(){
  check_command nexttrace
  if [ $? == 0 ]; then
    echo "正在安装nexttrace"
    bash <(curl -fsSL nxtrace.org/nt)
  else 
    new_version=$(wget -qO- -t1 -T2 "https://api.github.com/repos/nxtrace/NTrace-core/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')
    check_version=$(nexttrace -v | grep "$new_version")
    if [[ -z $check_version ]]; then
      read -p "检测到有新版本，是否更新(y/n): " update_flag
      update_flag=${update_flag:='n'}
      if [ $update_flag == 'y' ]; then
        echo "正在更新nexttrace"
        bash <(curl -fsSL nxtrace.org/nt)
      fi
    fi
  fi
  read -p "请输入需要测试的IP或域名: " host
  nexttrace $host
  read -p "是否继续测试(y/n): " flag
  flag=${flag:='y'}
  case $flag in
    Y | y)
     next_trace;;
    *)
    exit 1;;
  esac
}
warp_go_install(){
  wget -N https://gitlab.com/fscarmen/warp/-/raw/main/warp-go.sh && bash warp-go.sh
}
warp_install(){
  wget -N https://gitlab.com/fscarmen/warp/-/raw/main/menu.sh && bash menu.sh
}
ws_tls_install(){
  read -p "请输入域名: " hostname
  echo "正在安装nginx"
  nginx_install
  echo "开始申请tls证书"
  acme_install $hostname
  echo -e "
    脚本操作已完成，请自行操作以下步骤：
    1、修改nginx配置，参考：https://github.com/sola614/Sundries/blob/master/course/V2board%20Air-Universe%20V2ray%20tls%20ws%20%E7%AE%80%E6%98%93%E6%95%99%E7%A8%8B.md
    2、如果使用的是Air-Universe搭建的，需要修改配置，参考：https://github.com/sola614/Sundries/blob/master/course/V2board%20Air-Universe%20V2ray%20tls%20ws%20%E7%AE%80%E6%98%93%E6%95%99%E7%A8%8B.md
  " 
}
acme_install(){
  check_file_status /root/.acme.sh/acme.sh
  if [ $? == 0 ]; then
    echo "正在下载acme脚本"
    curl  https://get.acme.sh | sh
  fi
  check_file_str SAVED_CF_Token /root/.acme.sh/account.conf
  if [ $? == 0 ]; then
    read -p "请输入CF_Token: " cf_token
    export CF_Token=$cf_token
  fi
  check_file_str SAVED_CF_Account_ID /root/.acme.sh/account.conf
  if [ $? == 0 ]; then
    read -p "请输入CF_Account_ID: " cf_account_id
    export CF_Account_ID=$cf_account_id
  fi
  if [ $1 ];then
    host=$1
  else
    read -p "请输入域名: " host
  fi
  echo "正在申请（如果报错可重启再执行脚本）"
  /root/.acme.sh/acme.sh --issue --dns dns_cf -d $host --server letsencrypt
  echo "正在导出证书（如果报错可重启再执行脚本）"
  if [ $1 ];then
    /root/.acme.sh/acme.sh --install-cert -d $host --key-file  /etc/nginx/cert/$host.key --fullchain-file /etc/nginx/cert/$host.pem --reloadcmd  "service nginx force-reload"
  else
    mkdir /root/cert
    /root/.acme.sh/acme.sh --install-cert -d $host --key-file  /root/cert/$host.key --fullchain-file /root/cert/$host.pem
    echo "证书导出完毕，路径为：/root/cert"
  fi
}
node_ddns(){
  git clone https://github.com/sola614/node-ddns.git
  echo "代码下载完毕，请自行安装nodejs和pm2，完善相应信息再执行该脚本，具体参考：https://github.com/sola614/node-ddns"
}
gost_install(){
  check_file_status $ROOT_PATH/gost.sh
  if [ $? == 0 ]; then
    wget --no-check-certificate -O $ROOT_PATH/gost.sh https://raw.githubusercontent.com/KANIKIG/Multi-EasyGost/master/gost.sh && chmod +x $ROOT_PATH/gost.sh && $ROOT_PATH/gost.sh
  fi
  $ROOT_PATH/gost.sh
}
dnsproxy(){
  check_file_status $ROOT_PATH/dnsproxy/dnsproxy
  if [ $? == 0 ]; then
      echo "正在下载最新版dnsproxy"
      LATEST_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/AdguardTeam/dnsproxy/releases/latest)
      LATEST_VERSION=$(echo $LATEST_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
      ARTIFACT_URL="https://github.com/AdguardTeam/dnsproxy/releases/download/$LATEST_VERSION/dnsproxy-linux-amd64-$LATEST_VERSION.tar.gz"
      wget $ARTIFACT_URL -P $ROOT_PATH
      tar xvf $ROOT_PATH/dnsproxy-linux-amd64-$LATEST_VERSION.tar.gz -C $ROOT_PATH
      mv $ROOT_PATH/linux-amd64 $ROOT_PATH/dnsproxy
      # rm -rf $ROOT_PATH/dnsproxy-linux-amd64-$LATEST_VERSION.tar.gz
  fi 
  check_file_status $ROOT_PATH/dnsproxy/start.sh
  if [ $? == 0 ]; then
    read -p "请输入需要使用的dns ip或链接(如8.8.8.8或tls://xxx): " dns_url
    read -p "请输入端口号(默认53): " dns_port
    dns_port=${dns_port:='53'}
    echo "-----$ROOT_PATH/dnsproxy/dnsproxy -u $dns_url --cache -p $dns_port------"
    echo "#!/bin/sh" > $ROOT_PATH/dnsproxy/start.sh
    echo "$ROOT_PATH/dnsproxy/dnsproxy -l 127.0.0.1 -u $dns_url --cache -p $dns_port --refuse-any" >> $ROOT_PATH/dnsproxy/start.sh
    chmod +x $ROOT_PATH/dnsproxy/start.sh
  fi 
  check_file_status /etc/systemd/system/dnsproxy.service
  if [ $? == 0 ]; then
    wget https://raw.githubusercontent.com/sola614/Sundries/master/configFile/dnsproxy.service -P /etc/systemd/system/
    systemctl daemon-reload
    systemctl restart dnsproxy
    systemctl enable dnsproxy
    systemctl status dnsproxy
    echo "dnsproxy启动完毕"
  else
    echo "dnsproxy服务已存在"
  fi 
}
update_curl_centos7(){
  yum update
  rpm -ivh https://mirror.city-fan.org/ftp/contrib/yum-repo/city-fan.org-release-3-11.rhel7.noarch.rpm
  yum update curl --enablerepo=city-fan.org -y
  echo "1、如果仓库不存在可以直接https://mirror.city-fan.org/ftp/contrib/yum-repo/ 获取最新版"
  echo "2、如果更新不成功，请尝试vim /etc/yum.repos.d/city-fan.org.repo 将[city-fan.org]的enable值修改为1然后保存再执行update命令；yum update curl -y"
}
hysteria2_install(){
    bash <(curl -fsSL https://file.meaqua.fun/shell/install_hysteria2.sh)
}
change_sys_repo(){
  read -p "使用国内源? (y/n): " use_china_mirror
  if [[ "$use_china_mirror" == "y" || "$use_china_mirror" == "Y" ]]; then
      bash <(curl -sSL https://linuxmirrors.cn/main.sh)
  else
      bash <(curl -sSL https://linuxmirrors.cn/main.sh) --abroad
  fi
}

xboard_node_install(){
  bash <(curl -fsSL https://raw.githubusercontent.com/sola614/Sundries/refs/heads/master/shell/xboard-node-install.sh)
}

check_command wget
if [ $? == 0 ]; then
  echo "正在安装wget"
  $INSTALL_CMD wget
fi
show_menu
