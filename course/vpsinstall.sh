#!/bin/bash
. /etc/profile
. ~/.bash_profile

ROOT_PATH="/usr/mybash"
SYSTEM_OS=""
INSTALL_CMD=""
green='\033[0;32m'
plain='\033[0m'
length='34'
show_menu() {
  echo -e "
  常用脚本集合(仅在Centos下测试可用)
  ${green}0.${plain} 更新脚本
  ${green}999.${plain} 初始化安装
  ————————————————
  ${green}1.${plain}  NEKE家linux网络优化脚本
  ${green}2.${plain}  besttrace测试路由
  ${green}3.${plain}  serverStatus探针
  ${green}4.${plain}  x-ui安装
  ${green}5.${plain}  流媒体检测(速度较慢)
  ${green}6.${plain}  iptables端口转发
  ${green}7.${plain}  iptables端口转发(支持域名)
  ${green}8.${plain}  查看本机ip
  ${green}9.${plain}  安装docker
  ${green}10.${plain} 使用nvm安装nodejs
  ${green}11.${plain} 下载cf-v4-ddns
  ${green}12.${plain} DNS解锁(安装dnsmasq或sniproxy)
  ${green}13.${plain} iptables屏蔽端口
  ${green}14.${plain} iptables开放端口
  ${green}15.${plain} 安装nginx
  ${green}16.${plain} 测试ip被ban脚本
  ${green}17.${plain} 安装wikihost-Looking-glass Server(vps测试用)
  ${green}18.${plain} Air-Universe 开源多功能机场后端一键安装脚本
  ${green}19.${plain} 哪吒监控一键脚本
  ${green}20.${plain} 永久修改DNS
  ${green}21.${plain} NEKO版流媒体检测（速度更快）
  ${green}22.${plain} 三网回程路由测试(https://github.com/zhanghanyun/backtrace)
  ${green}23.${plain} 快速查询本机IP和区域
  ${green}24.${plain} nexttrace路由跟踪工具(https://github.com/sjlleo/nexttrace)
  ${green}25.${plain} Cloudflare Warp GO一键脚本(https://maobuni.com/2022/05/08/cloudflare-warp/)
  ${green}26.${plain} Cloudflare Warp一键脚本(https://github.com/fscarmen/warp)
  ${green}27.${plain} 一键准备nginx和利用acme申请证书
  ${green}28.${plain} acme申请证书(CF_DNS模式，准备工作请参考：https://github.com/sola614/Sundries/blob/master/course/%E5%88%A9%E7%94%A8acme.sh%E7%94%B3%E8%AF%B7ssl%E8%AF%81%E4%B9%A6%26%E8%87%AA%E5%8A%A8%E6%9B%B4%E6%96%B0%E8%AF%81%E4%B9%A6.md)
  ${green}29.${plain} node-ddns(https://github.com/sola614/node-ddns)
  ${green}30.${plain} dnsproxy
  ${green}31.${plain} 一键安装XrayR后端
  ${green}32.${plain} Hi Hysteria脚本(https://github.com/emptysuns/Hi_Hysteria)
  ${green}33.${plain} gost脚本(https://github.com/KANIKIG/Multi-EasyGost)(可实现ipv4流量转发到ipv6地址)
  ${green}34.${plain} warp多功能一键脚本
  
 "
    echo && read -p "请输入选择 [0-${length}]: " num

    case "${num}" in
    0)
        update_sh
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
        start_iptables2
        ;;
    8) 
      check_ip
      ;;
    9) 
      docker_install
      ;;
    10) 
      install_nodejs_by_nvm
      ;;
    11) 
      download_cf_v4_ddns
      ;;
    12) 
      dns_unblock
      ;;
    13) 
      read -p "请输入需要屏蔽的端口和协议(默认:tcp): " port protocol
      if [ $port ];then
        echo "$port $protocol"
        ban_iptables $port $protocol
      fi
      ;;
    14) 
      read -p "请输入需要放开的端口: " port protocol
      if [ $port ];then
        unban_iptables $port
      fi
       ;;
    15)
      nginx_install
    ;;
    16)
      ip_test
    ;;
    17)
      wikihost_LookingGlass_install
    ;;
    18)
      Air_Universe_install
    ;;
    19)
      nezha_sh
    ;;
    20)
      dns_change
    ;;
    21)
      start_neko_unlock_test
    ;;
    22)
      mtr_trace
    ;;
    23)
      check_ip_location
    ;;
    24)
      next_trace
    ;;
    25)
      warp_go_install
    ;;
    26)
      warp_install
    ;;
    27)
      ws_tls_install
    ;;
    28)
      acme_install
    ;;
    29)
      node_ddns
    ;;
    30)
      dnsproxy
    ;;
    31)
      xrayr_install
    ;;
    32)
      hi_hysteria_install
    ;;
    33)
      gost_install
    ;;
    34)
      bash <(wget -qO- https://gitlab.com/rwkgyg/CFwarp/raw/main/CFwarp.sh 2> /dev/null)
    ;;
    
    999)
      vps_install
    ;;
    *)
      echo "请输入正确的数字 [0-${length}]"
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
  bash ./vpsinstall.sh
}
vps_install(){
  echo "正在安装常用软件"
  $INSTALL_CMD vim wget unzip tar bind-utils mtr curl crontabs socat iptables-services net-tools cronie -y
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
Air_Universe_install(){
  bash <(curl -Ls https://raw.githubusercontent.com/crossfw/Air-Universe-install/master/AirU.sh)
}
xrayr_install(){
  check_command xrayr
  if [ $? == 0 ]; then
    wget -N https://raw.githubusercontent.com/XrayR-project/XrayR-release/master/install.sh && bash install.sh
  fi
  read -p "面板类型(SSpanel, V2board, NewV2board, PMpanel, Proxypanel, V2RaySocks): " PanelType
  if [ -z "$PanelType" ]; then
    echo "面板类型为空！"
    exit 1
  fi
  read -p "面板地址(如http(s)://): " ApiHost
  if [ -z "$ApiHost" ]; then
    echo "面板地址为空！"
    exit 1
  fi
  #转义//
  ApiHost=$(echo "$ApiHost" | sed 's/\//\\\//g')
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
  read -p "节点类型(V2ray, Shadowsocks, Trojan, Shadowsocks-Plugin): " NodeType
  if [ -z "$NodeType" ]; then
    echo "节点类型为空！"
    exit 1
  fi
   echo "正在写入配置信息"
  all=".*"
  CONFIG_PATH=/etc/XrayR/config.yml
  sed -i "s/PanelType: ${all}/PanelType: \"${PanelType}\"/" $CONFIG_PATH
  sed -i "s/ApiHost: ${all}/ApiHost: \"${ApiHost}\"/" $CONFIG_PATH
  sed -i "s/ApiKey: ${all}/ApiKey: \"${ApiKey}\"/" $CONFIG_PATH
  sed -i "s/NodeID: ${all}/NodeID: ${NodeID}/" $CONFIG_PATH
  sed -i "s/NodeType: ${all}/NodeType: ${NodeType}/" $CONFIG_PATH
  echo "正在启动XrayR"
  XrayR start

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
  curl 3.0.3.0
}
docker_install(){
  check_command docker
  if [ $? == 0 ]; then
    curl -fsSL https://get.docker.com | sh
  fi
  echo "docker已安装完毕,正在启动:"
  systemctl start docker
  read -p "是否设置开机启动(y/n): " flag
  flag=${flag:='y'}
  case $flag in
    Y | y)
     systemctl enable docker;;
    N | n)
    echo:'不设置开机启动';;
  esac
  echo -e "
  常用命令:
  docker ps [-a]
  docker start/stop/restart/rm [CONTAINER ID or name]
  停止所有容器运行： docker stop $(docker ps -a -q)
  删除所有停止运行的容器： docker rm $(docker ps -a -q)
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
  check_command nginx
  if [ $? == 0 ]; then
    echo "正在安装nginx"
    $INSTALL_CMD epel-release
    $INSTALL_CMD nginx
    echo "正在启动"
    systemctl start nginx
    echo "正在设置开机启动"
    systemctl enable nginx
  fi
  echo -e "
    nginx已存在，请自行修改/etc/nginx目录下的配置文件，然后使用nginx -s reload 重启
    其他命令：
      ${green}systemctl start nginx${plain} 启动
      ${green}systemctl enable nginx${plain} 设置开机启动
  "
   echo ""
}
ip_test(){
  check_file_status $ROOT_PATH/testip.sh
  if [ $? == 0 ]; then
    wget -O $ROOT_PATH/testip.sh https://raw.githubusercontent.com/sola614/sola614/master/course/testip.sh && chmod +x $ROOT_PATH/testip.sh
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
    bash <(curl -Ls https://raw.githubusercontent.com/sjlleo/nexttrace/main/nt_install.sh)
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
  check_file_status /root/.acme.sh/acme.sh
  if [ $? == 0 ]; then
    echo "正在下载acme脚本"
    curl  https://get.acme.sh | sh
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
    wget https://raw.githubusercontent.com/sola614/Sundries/master/course/dnsproxy.service -P /etc/systemd/system/
    systemctl daemon-reload
    systemctl restart dnsproxy
    systemctl enable dnsproxy
    systemctl status dnsproxy
    echo "dnsproxy启动完毕"
  else
    echo "dnsproxy服务已存在"
  fi 
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
  echo "未检测到系统版本，请联系脚本作者！\n" && exit 1
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
