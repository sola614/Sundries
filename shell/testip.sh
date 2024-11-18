#!/bin/bash

BOT_TOKEN=
CHAN_ID=
SERVER_NAME=
TEST_LIST="113.91.63.155
47.104.38.82
59.110.190.69
47.92.17.36
39.104.9.1
118.31.219.247
106.14.228.194
120.77.166.226
www.189.cn
"
length="2"
count=0
max_count=0
text_result=''
ROOT_PATH="/usr/mybash"

show_menu() {
  echo -e "
  常用脚本集合
  ${green}0.${plain} 更新脚本
  ————————————————
  ${green}1.${plain}  直接开始测试
  ${green}2.${plain}  填写配置
 "
  echo && read -p "请输入选择 [0-${length}]: " num
  select_menu $num
    
}
select_menu(){
  case "$1" in
    0)
        update
        ;;
    1)
        start
        ;;
    2)
        settting
        ;;
    *)
      LOGE "请输入正确的数字 [0-${length}]"
      ;;
  esac
}
update(){
  echo "正在下载最新文件到$ROOT_PATH"
  wget -O $ROOT_PATH/testip.sh https://file.meaqua.fun/shell/testip.sh && chmod +x $ROOT_PATH/testip.sh
}
start(){
  if [ ! $BOT_TOKEN ]; then
    echo "如需TG推送，请填写TG的BOT_TOKEN，获取方法：https://core.telegram.org/bots#3-how-do-i-create-a-bot" 
    # exit 0
  fi
  if [ ! $CHAN_ID ]; then
    echo "如需TG推送，请填写TG的CHAN_ID，获取方法：添加(@userinfobot) 机器人查看个人id" 
    # exit 0
  fi
  if [ ! $SERVER_NAME ]; then
    echo "如需TG推送，请填写SERVER_NAME服务器名称" 
    # exit 0
  fi
  echo "正在测试，请稍后"
  for i in ${TEST_LIST}
  do
    max_count=$((max_count+1))
    if `ping -c 4 $i|grep -q 'ttl='`;then
    text="
    $i ok"
    count=$((count+1))
    else
      text="
      $i failed"
    fi
    text_result=$text_result$text
  done
  pass_rate=`awk 'BEGIN{printf "%.1f%%\n",('$count'/'$max_count')*100}'`
  result="服务器：<b>$SERVER_NAME</b>
  通过率：$pass_rate($count/$max_count)
  测试结果汇总：$text_result"

  if [ $BOT_TOKEN ] && [ $CHAN_ID ];then
    if command -v curl >/dev/null 2>&1; then
      echo "正在发送测速结果"
      curl --data chat_id="$CHAN_ID" --data-urlencode "text=$result" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?parse_mode=HTML" >/dev/null 2>&1;
    else
      echo 'curl命令不存在！'
      exit 0
    fi 
  fi
  echo "测试结果：
    $result"
}
settting(){
  SH_PATH=$(cd "$(dirname "$0")";pwd)
  echo "$SH_PATH"
  all=".*"
  read -p "请填写TG的BOT_TOKEN，获取方法：https://core.telegram.org/bots#3-how-do-i-create-a-bot：" bot_token
  str="BOT_TOKEN="
  sed -i "0,/${str}${all}/s/${str}${all}/${str}${bot_token}/" $SH_PATH/testip.sh
  read -p "请填写TG的CHAN_ID，获取方法：添加(@userinfobot) 机器人查看个人id：" chat_id
  str="CHAN_ID="
  sed -i "0,/${str}${all}/s/${str}${all}/${str}${chat_id}/" $SH_PATH/testip.sh
  read -p "请填写SERVER_NAME服务器名称：" server_name
  str="SERVER_NAME="
  sed -i "0,/${str}${all}/s/${str}${all}/${str}${server_name}/" $SH_PATH/testip.sh
  echo "配置完成"
  show_menu
}
if [ $1 ];then
  select_menu $1
else
  show_menu
fi
