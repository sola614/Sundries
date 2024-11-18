#!/bin/bash

MENU_MAX_OPTION="4"
green='\033[0;32m'
plain='\033[0m'

show_menu() {
  echo -e "
  常用流媒体检测脚本集合
  ${green}0.${plain} 更新本脚本
  ————————————————
  ${green}1.${plain} 脚本1(https://github.com/lmc999/RegionRestrictionCheck)
  ${green}2.${plain} 脚本2(https://github.com/nkeonkeo/MediaUnlockTest)
  ${green}3.${plain} 脚本3(https://github.com/1-stream/RegionRestrictionCheck)
  ${green}4.${plain} 脚本4(https://github.com/xykt/RegionRestrictionCheck)
 "
 echo && read -p "请输入选择 [0-${MENU_MAX_OPTION}]: " num
  if [[ ! $num =~ ^[0-9]+$ ]] || (( num < 0 || num > MENU_MAX_OPTION )); then
    echo -e "${red}请输入正确的数字 [0-${MENU_MAX_OPTION}]${plain}"
    return
  fi
  select_menu $num
    
}
select_menu(){
  case "$1" in
    0)
        update ;;
    1)
        check1 ;;
    2)
        check2 ;;
    3)
        check3 ;;
    4)
        check4 ;;
    *)
      LOGE "请输入正确的数字 [0-${MENU_MAX_OPTION}]"
      ;;
  esac
}
update(){
  echo "正在下载最新脚本到当前目录..."
  if wget -O check_media.sh https://raw.githubusercontent.com/sola614/Sundries/refs/heads/master/shell/check_media.sh; then
    chmod +x ./check_media.sh
    echo -e "${green}脚本更新成功！${plain}"
  else
    echo -e "${red}脚本更新失败，请检查网络或地址！${plain}"
  fi
}
check1(){
  bash <(curl -L -s check.unlock.media)
}
check2(){
  bash <(curl -Ls unlock.moe)
}
check3(){
  bash <(curl -L -s https://github.com/1-stream/RegionRestrictionCheck/raw/main/check.sh)
}
check4(){
  bash <(curl -sL Media.Check.Place)
}

if [ $1 ];then
  select_menu $1
else
  show_menu
fi
