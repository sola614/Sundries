1.编辑网卡文件`vim /etc/sysconfig/network-scripts/ifcfg-eth0`
```
IPV6INIT=yes
IPV6_AUTOCONF=yes
```
2.编辑disable_ipv6.conf文件`vim /etc/modprobe.d/disable_ipv6.conf`
```
options ipv6 disable=0
```
3.编辑 network 文件`vim /etc/sysconfig/network`
```
NETWORKING_IPV6=yes
```
4.编辑 sysctl.conf 文件`vim /etc/sysctl.conf`
```
net.ipv6.conf.all.disable_ipv6 = 0
net.ipv6.conf.default.disable_ipv6 = 0
net.ipv6.conf.lo.disable_ipv6 = 0
```
5.增加 IPv6 的 DNS`vim /etc/resolv.conf`
```
#阿里云
nameserver 2400:3200::1
nameserver 2400:3200:baba::1
#Google
nameserver 2001:4860:4860::8888
nameserver 2001:4860:4860::8844
```
参考文章：https://www.kjarbo.com/archives/638.html
