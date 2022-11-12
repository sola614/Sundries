# 自建dns解锁教程
### 一、落地机安装[dnsmasq_sniproxy](https://github.com/sola614/dnsmasq_sniproxy_install)
```
wget --no-check-certificate -O dnsmasq_sniproxy.sh https://raw.githubusercontent.com/sola614/dnsmasq_sniproxy_install/master/dnsmasq_sniproxy.sh && bash dnsmasq_sniproxy.sh -f
```
### 二、利用iptables设置白名单
```
iptables -I INPUT -p tcp --dport 53 -j DROP  #先限制所有IP访问53端口
iptables -I INPUT -s x.x.x.x -p tcp --dport 53 -j ACCEPT   #再允许VPS B（不能解锁Netflix的VPS）的IP访问，要允许多个IP则添加多条即可
```
### 三、需要解锁的机器安装dnsmasq
1.安装   
```
yum install -y dnsmasq
```
2.编辑自定义解锁配置`vim /etc/dnsmasq.conf`   
```
server=8.8.8.8
server=/example.com/x.x.x.x
```
3.编辑本机dns配置`vim /etc/resolv.conf`
```
nameserver 127.0.0.1
```
4.重启dnsmasq`systemctl restart dnsmasq`

ps:  
1、解决iptables重启失效问题
```
service iptables save #如果是centos7需要先安装yum install iptables-services -y
chkconfig iptables on
```
自用配置参考
```
server=8.8.8.8 #通用
server=/api-priconne-redive.cygames.jp/x.x.x.x #PCR解锁
server=/abema.tv/x.x.x.x #abema解锁
server=/abema.io/x.x.x.x #abema解锁
server=/nicovideo.jp/x.x.x.x #nicovideo解锁
server=/worldflipper.jp/x.x.x.x #弹射世界解锁
```
