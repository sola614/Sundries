1、安装Air-Universe
重点是`/usr/local/etc/au/au.json`中`Proxy`配置要添加`"force_close_tls": true`,完整示例：
```
{
  "panel": {
    "type": "v2board",
    "url": "V2board域名",
    "key": "V2board密钥",
    "node_ids": [节点ID],
    "nodes_type": ["vmess"]
  },
  "proxy": {
    "type": "xray",
    "force_close_tls": true,#重要
    "log_path": "./v2.log"
  }
}
```
2、安装nginx(这里简单就用aaPanel全可视化操作，还可以申请证书自动续期)，配置填入：
```
location /你前面设定的路径 { 
   proxy_redirect off;
   proxy_pass http://127.0.0.1:1145; # 端口为服务端口 ，这里我使用1145
   proxy_http_version 1.1;
   proxy_set_header Upgrade $http_upgrade;
   proxy_set_header Connection "upgrade";
   proxy_set_header Host $host;
   proxy_set_header X-Real-IP $remote_addr;
   proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
}
```
最后重启`systemctl restart au`，然后利用浏览器访问`https://节点域名/路径`若返回`bad request`则部署成功

参考文章：https://blog.rssan.com/archives/1593
