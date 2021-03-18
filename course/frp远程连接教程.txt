frp 教程
1.安装服务端

https://github.com/fatedier/frp/releases 下载对应的服务端包
我用的是 weget https://github.com/fatedier/frp/releases/download/v0.31.2/frp_0.31.2_linux_amd64.tar.gz

解压 tar -zxvf ./frp_0.31.2_linux_amd64.tar.gz -C ./frp

cd ./frp/frp_0.31.2_linux_amd64

编辑配置文件
vim ./frpc.ini
默认好像也行

[common]
bind_addr=0.0.0.0
bind_port = 7000
auto_token=yumianfeilong //好像没啥用 可以不加


保存

启动服务
./frps -c ./frps.ini


客户端配置
下载 https://github.com/fatedier/frp/releases/download/v0.31.2/frp_0.31.2_windows_amd64.zip

打开frpc.ini

填写配置文件
[common]
server_addr = 服务器地址
server_port = 服务器端口
auto_token=每个人不一样，专属token，最好与下面一致 也许与服务器端的auto_token有关，没仔细研究过

[专属token，如bao]
type = tcp
local_ip = 127.0.0.1
local_port = 3389 //本地端口，不用改
remote_port = 6001 //服务器端口，唯一

只要token和remote_port即可

保存
然后在客户端根目录用命令行执行这个 frpc.exe -c frpc.ini，如果提示有success字段表示已连接到服务器

电脑开启远程连接

打开随意一个文件夹，在地址栏输入：控制面板\系统和安全\系统 -找到左侧高级系统设置-打开-打开远程tab，把允许远程协助连接这台计算机和允许允许任意版本远程桌面的计算机连接

自己电脑
搜索远程桌面连接 输入ip:端口 即可访问
