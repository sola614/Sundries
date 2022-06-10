#!/bin/bash
. /etc/profile
. ~/.bash_profile

BOT_TOKEN=""
CHAN_ID=""
SERVER_NAME=""
TEST_LIST="113.91.63.155
119.91.116.71
www.189.cn
"
count=0
max_count=0
text_result=''

echo "脚本开始"
if [ ! $BOT_TOKEN ]; then
  echo "请填写TG的BOT_TOKEN，获取方法：https://core.telegram.org/bots#3-how-do-i-create-a-bot" 
  exit 0
fi
if [ ! $CHAN_ID ]; then
  echo "请填写TG的CHAN_ID，获取方法：添加(@userinfobot) 机器人查看个人id：" 
  exit 0
fi
if [ ! $SERVER_NAME ]; then
  echo "请填写SERVER_NAME服务器名称：" 
  exit 0
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
echo "脚本已全部执行完毕"
