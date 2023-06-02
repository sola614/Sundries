#!/bin/bash
TRAFF_TOTAL=980 #改成自己的预定额度，建议稍小些，单位GB。
TRAFF_USED=$(vnstat --oneline b | awk -F';' '{print $11}')
CHANGE_TO_GB=$(expr $TRAFF_USED / 1073741824)

if [ $CHANGE_TO_GB -gt $TRAFF_TOTAL ]; then
    shutdown -h now
    curl https://api.meaqua.fun/api/sendMsg -X POST -d '{"msgType": 30,"msg": "服务器流量超标自动关机了","qqPojo":{}}' --header "Content-Type: application/json"
fi
