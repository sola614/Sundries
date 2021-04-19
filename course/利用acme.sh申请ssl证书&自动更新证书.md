# 说明
acme.sh 实现了 acme 协议, 可以从 letsencrypt 生成免费的证书.
# 安装脚本
```
curl  https://get.acme.sh | sh
```
# 生成证书(这里是DNS方式)
## Cloudflare方式:  
### 准备工作：   
1.申请CF_Token：访问[cloudflare 个人账户](https://dash.cloudflare.com/profile/api-tokens)，点击创建令牌，使用`编辑区域 DNS`模板，进行如下配置:
```
权限：
区域 DNS 编辑
账户 账户设置 读取
区域 区域 读取
账户资源：
包括 您的账户
区域资源：
包括 特定资源 选中特定域名
```
然后点击下一步预览，在下一步即可生成复制备用  
2.获取CF_Account_ID：打开[cloudflare](https://dash.cloudflare.com/)，链接后面那串就是所需要的id，复制备用

### 正式安装
在控制台输入:
```
export CF_Token="你准备的CF_Token"
export CF_Account_ID="你准备的CF_Account_ID"
acme.sh --issue --dns dns_cf -d youdomain.com
```
然后就是等待，成功的话你会看到一堆success

# copy/安装 证书（这里是nginx方式）
## nginx
使用以下代码：
```
acme.sh --install-cert -d example.com \
--key-file       你的证书存放路径/cert.key  \
--fullchain-file 你的证书存放路径/cert.pem \
--reloadcmd     "service nginx force-reload"
```

# 更新证书
目前证书在 60 天以后会自动更新, 你无需任何操作. 今后有可能会缩短这个时间, 不过都是自动的, 你不用关心.

# 更新 acme.sh
升级 acme.sh 到最新版 :

```
acme.sh --upgrade
```
如果你不想手动升级, 可以开启自动升级:

```
acme.sh  --upgrade  --auto-upgrade
```
之后, acme.sh 就会自动保持更新了.

你也可以随时关闭自动更新:

```
acme.sh --upgrade  --auto-upgrade  0
```

# 其他
1.其他安装方式请参照：[官方wiki](https://github.com/acmesh-official/acme.sh/wiki/%E8%AF%B4%E6%98%8E)