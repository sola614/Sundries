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

3、centos7利用yum安装nginx完整nginx配置
```
user nginx;
worker_processes auto;
pid /run/nginx.pid;

# Load dynamic modules. See /usr/share/doc/nginx/README.dynamic.
include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http {
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    sendfile            on;
    tcp_nopush          on;
    tcp_nodelay         on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    # Load modular configuration files from the /etc/nginx/conf.d directory.
    # See http://nginx.org/en/docs/ngx_core_module.html#include
    # for more information.
    include /etc/nginx/conf.d/*.conf;
    
    server {
      listen 80;
      listen 443 ssl http2;
      listen [::]:443 ssl http2;
      listen [::]:80;
      server_name yourdomain; #修改为自己的
      index index.php index.html index.htm default.php default.htm default.html;
      root /usr/share/nginx/html;

      #SSL-START SSL related configuration, do NOT delete or modify the next line of commented-out 404 rules
      #error_page 404/404.html;
      #HTTP_TO_HTTPS_START
      #if ($server_port !~ 443){
      #   rewrite ^(/.*)$ https://$host$1 permanent;
      #}
      #HTTP_TO_HTTPS_END
      ssl_certificate    /etc/nginx/cert/main.pem;#修改为自己的
      ssl_certificate_key    /etc/nginx/cert/main.key;#修改为自己的
      ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
      ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
      ssl_prefer_server_ciphers on;
      ssl_session_cache shared:SSL:10m;
      ssl_session_timeout 10m;
      add_header Strict-Transport-Security "max-age=31536000";
      error_page 497  https://$host$request_uri;

      #v2
      location /chat { 
        proxy_redirect off;
        proxy_pass http://127.0.0.1:32576; # 端口为服务端口,修改为自己的
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      }
      # Forbidden files or directories
      location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)
      {
          return 404;
      }

      # Directory verification related settings for one-click application for SSL certificate
      location ~ \.well-known{
          allow all;
      }

      location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
      {
          expires      30d;
          error_log /dev/null;
          access_log off;
      }
      location ~ .*\.(js|css)?$
      {
          expires      12h;
          error_log /dev/null;
          access_log off;
      }
      access_log  /var/log/nginx/hk-newtudou.nowtime.icu.log;
      error_log  /var/log/nginx/hk-newtudou.nowtime.icu-error.log;
    }
}
```

参考文章：https://blog.rssan.com/archives/1593
