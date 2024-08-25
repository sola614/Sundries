red='\033[0;31m'
bblue='\033[0;34m'
yellow='\033[0;33m'
green='\033[0;32m'
plain='\033[0m'
red(){ echo -e "\033[31m\033[01m$1\033[0m";}
green(){ echo -e "\033[32m\033[01m$1\033[0m";}
yellow(){ echo -e "\033[33m\033[01m$1\033[0m";}
blue(){ echo -e "\033[36m\033[01m$1\033[0m";}
white(){ echo -e "\033[37m\033[01m$1\033[0m";}
bblue(){ echo -e "\033[34m\033[01m$1\033[0m";}
rred(){ echo -e "\033[35m\033[01m$1\033[0m";}

chatgpt4(){
	gpt1=$(curl -s4 https://chat.openai.com 2>&1)
	gpt2=$(curl -s4 https://android.chat.openai.com 2>&1)
}
chatgpt6(){
	gpt1=$(curl -s6 https://chat.openai.com 2>&1)
	gpt2=$(curl -s6 https://android.chat.openai.com 2>&1)
}
checkgpt(){
	if [[ $gpt1 == *location* ]]; then
		if [[ $gpt2 == *VPN* ]]; then
			chat='遗憾，当前IP仅解锁ChatGPT网页，未解锁客户端'
		elif [[ $gpt2 == *Request* ]]; then
			chat='恭喜，当前IP完整解锁ChatGPT (网页+客户端)'
		else
			chat='杯具，当前IP无法解锁ChatGPT服务'
		fi
	else
		chat='杯具，当前IP无法解锁ChatGPT服务'
	fi
}

nf4(){
	UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
	result=$(curl -4fsL --user-agent "${UA_Browser}" --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
	if [[ "$result" == "404" ]]; then 
		NF="遗憾，当前IP仅解锁Netflix自制剧"
	elif [[ "$result" == "403" ]]; then
		NF="杯具，当前IP不能看Netflix"
	elif [[ "$result" == "200" ]]; then
		NF="恭喜，当前IP完整解锁Netflix非自制剧"
	else
		NF="死心吧，Netflix不服务当前IP地区"
	fi
}

nf6(){
	UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
	result=$(curl -6fsL --user-agent "${UA_Browser}" --write-out %{http_code} --output /dev/null --max-time 10 "https://www.netflix.com/title/70143836" 2>&1)
	if [[ "$result" == "404" ]]; then 
		NF="遗憾，当前IP仅解锁Netflix自制剧"
	elif [[ "$result" == "403" ]]; then
		NF="杯具，当前IP不能看Netflix"
	elif [[ "$result" == "200" ]]; then
		NF="恭喜，当前IP完整解锁Netflix非自制剧"
	else
		NF="死心吧，Netflix不服务当前IP地区"
	fi
}

v4v6(){
	v4=$(curl -s4m5 icanhazip.com -k)
	v6=$(curl -s6m5 icanhazip.com -k)
}

v4v6
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"
if [[ -n $v6 ]]; then
	nonf=$(curl -s6 --user-agent "${UA_Browser}" http://ip-api.com/json/$v6?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
	nf6;chatgpt6;checkgpt
	v6Status=$(white "IPV6地址：\c" ; blue "$v6   $nonf" ; white " Netflix： \c" ; blue "$NF" ; white " ChatGPT： \c" ; blue "$chat")
else
	v6Status=$(white "IPV6地址：\c" ; red "不存在IPV6地址")
fi
if [[ -n $v4 ]]; then
	nonf=$(curl -s4 --user-agent "${UA_Browser}" http://ip-api.com/json/$v4?lang=zh-CN -k | cut -f2 -d"," | cut -f4 -d '"')
	nf4;chatgpt4;checkgpt
	v4Status=$(white "IPV4地址：\c" ; blue "$v4   $nonf" ; white " Netflix： \c" ; blue "$NF" ; white " ChatGPT： \c" ; blue "$chat")
else
	v4Status=$(white "IPV4地址：\c" ; red "不存在IPV4地址")
fi

echo -e "$v4Status"
echo -e "$v6Status"
