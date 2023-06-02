#!/bin/bash
###
 # @Descripttion: 文件描述
 # @Author: sola.zhang
 # @Date: 2023-06-02 09:26:04
 # @LastEditors: sola.zhang
 # @LastEditTime: 2023-06-02 09:26:10
### 
TRAFF_TOTAL=980 #改成自己的预定额度，建议稍小些，单位GB。
TRAFF_USED=$(vnstat --oneline b | awk -F';' '{print $11}')
CHANGE_TO_GB=$(expr $TRAFF_USED / 1073741824)

if [ $CHANGE_TO_GB -gt $TRAFF_TOTAL ]; then
    shutdown -h now
fi