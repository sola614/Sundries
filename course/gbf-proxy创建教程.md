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
