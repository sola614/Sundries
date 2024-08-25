#!/bin/bash
. /etc/profile
. ~/.bash_profile

BOT_TOKEN=""
CHAN_ID=""
EXECUTE_PATH="/root/speedtest.py"

echo "脚本开始"
if [ ! $BOT_TOKEN ]; then
  echo "请填写TG的BOT_TOKEN，获取方法：https://core.telegram.org/bots#3-how-do-i-create-a-bot"
  exit 0
fi
if [ ! $CHAN_ID ]; then
  echo "请填写TG的CHAN_ID，获取方法：添加(@userinfobot) 机器人查看个人id"
  exit 0
fi
if [ ! $EXECUTE_PATH ]; then
  echo "请填写需要执行命令路径EXECUTE_PATH"
  exit 0
fi
if [ ! -f "$EXECUTE_PATH" ]; then
  echo "测速脚本不存在，准备开始下载"
  wget https://raw.github.com/sivel/speedtest-cli/master/speedtest.py && chmod a+rx speedtest.py
fi

if command -v python >/dev/null 2>&1; then
  echo "开始执行测速脚本"
  REUSLT=`python speedtest.py`
else
  echo 'python命令不存在！'
  exit 0
fi
if command -v curl >/dev/null 2>&1; then
  echo "正在发送测速结果"
  curl --data chat_id="$CHAN_ID" --data-urlencode "text=$REUSLT" "https://api.telegram.org/bot$BOT_TOKEN/sendMessage?parse_mode=HTML" >/dev/null 2>&1;
else
  echo 'curl命令不存在！'
  exit 0
fi
echo "脚本已全部执行完毕"
