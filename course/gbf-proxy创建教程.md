# 前期准备
1、一台日本VPS（任意，没要求）  
2、流量转发服务或者流量中转vps或nat（便宜的就流量转发服务，要速度快就选iplc中转）

# 日本VPS要进行的操作
1.下载gbf-proxy
```
wget https://github.com/Frizz925/gbf-proxy/releases/download/v0.1.0/gbf-proxy-linux-amd64 -O gbf-proxy
```
2.赋权
```
chmod +x gbf-proxy
```
3.使用screen后台启动gbf-proxy程序
```
yum install screen 
screen -S gbf
./gbf-proxy local --host 0.0.0.0 --port 12345
```
PS：输入完毕之后需要按Ctrl+a再按d退出

# 如果是流量转发服务
请在商家的服务后台设置你的ip和上面设置的12345端口，然后把商家提供的ip和端口记下来填到`SwitchyOmega`中

# 如果是转发vps或nat
1.下载一键转发脚本
```
wget -N --no-check-certificate https://raw.githubusercontent.com/ToyoDAdoubiBackup/doubi/master/iptables-pf.sh && chmod +x iptables-pf.sh && bash iptables-pf.sh
```
2.下载完成执行脚本后会出现一个菜单，选1安装`iptables`  
3.安装完`iptables`后再选择4添加规则
```
第一个远程端口填上面设置的12345
第二个远程ip填日本vps的ip
第三个本地监听端口自行填写，可以与远程端口相同
第四个网卡ip需要填写内网ip（如何获取请看下面`如何获取内网ip`）
第五个选tcp+udp
最后回车即可
```
# 使用
做完以上步骤后即可使用你自己专属的gbf-proxy了  
一般PC浏览器使用`SwitchyOmega`
简单步骤：  
1.新建一个情景模式，选择`PAC情景模式`，名称自己定，最后点创建
2.在建好的模式的PCA脚本填入
```
function FindProxyForURL(url, host) {
    if (dnsDomainIs(host, ".granbluefantasy.jp")) {
        return "PROXY 你自己的转发ip:你自己设定的端口";
    }
    return "DIRECT";
}
```
后点应用选项保存
3.SwitchyOmega选择你刚创建的情景模式即可使用
4.如果需要auto switch需添加添加`*.granbluefantasy.jp`,情景模式选刚刚创建的情景模式
5.具体可参照[这里](https://github.com/Frizz925/gbf-proxy/blob/master/docs/setup-google-chrome.md)

# 如何获取内网ip
输入`ifconfig`后会有信息出现，eht0 inet 后面那个ip就是了

# Docker+Nginx组合
1.安装docker
```
yum install docker
systemctl enable docker # 开机自动启动docker
systemctl start docker # 启动docker
mkdir ~/gbf_proxy&& cd ~/gbf_proxy && mkdir app && mkdir script
cd ~/gbf_proxy/app/
wget https://github.com/Frizz925/gbf-proxy/releases/download/v0.1.0/gbf-proxy-linux-amd64 -O gbf-proxy
```
2.创建dockerfile
```
cd ~/gbf_proxy/
echo 'FROM golang
MAINTAINER  MING
WORKDIR /go/src/
COPY . .
EXPOSE 8088
CMD ["/bin/bash", "/go/src/script/build.sh"]' >Dockerfile
```
3.创建build.sh
```
cd ~/gbf_proxy/script
echo '#!/usr/bin/env bash
cd /go/src/app/ && chmod +x gbf-proxy && ./gbf-proxy local --host 0.0.0.0 --port 8088' >build.sh
```
4.构建
```
cd ~/gbf_proxy
docker build -t gbf-proxy .
```
5.启动进程
```
docker run -p 自定义端口:8088 --name gbf_proxy -d gbf-proxy
```
6.安装nginx
```
sudo yum install epel-release
sudo yum install nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```
7.安装ngx_stream_module.so(这一步可以先省略，如果nginx重启提示不存在这个文件再安装)
```
yum install nginx-mod-stream
```
8.编辑nginx.conf
```
vim etc/nginx/nginx.conf   
改成如下内容：   

load_module /usr/lib64/nginx/modules/ngx_stream_module.so;
user  nginx;
worker_processes  1;

events {
    worker_connections  1024;
}

stream {

    upstream gbf {
        server localhost:自定义端口 weight=1;     # ip:port 有多少个进程填多少
        server localhost:自定义端口 weight=2;
        server localhost:自定义端口 weight=3;
    }

    server {
        listen 8088;
        proxy_pass gbf;
    }
}
```
保存，然后执行`nginx -s reload`，剩下步骤和上面一样
9.crontab定时重启docker
```
crontab -e
填入以下内容
0 * * * * docker restart gbf_proxy_1 >/dev/null 2>&1
20 * * * * docker restart gbf_proxy_2 >/dev/null 2>&1
40 * * * * docker restart gbf_proxy_3 >/dev/null 2>&1
ps：这里的gbf_proxy_1是你启动的docker进程，合理安排重启时间段
```
# 一些报错解决方案
1.nginx提示`nginx: [emerg] bind() to 0.0.0.0:8088 failed (13: Permission denied)`   
这种一般是aws的机器存在，编辑`/etc/selinux/config`，把SELINUX设为disabled即可   
2.提示`ngx_stream_module`已引入，请把nginx.conf引入的那行去除
