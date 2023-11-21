# 安装openssl(https://slproweb.com/products/Win32OpenSSL.html)
下载安装然后配置环境变量(https://juejin.cn/post/7074036802394259469)

# 生成ssl证书(https://cloud.tencent.com/developer/article/1813403)
```
#创建一个私钥
openssl genrsa -des3 -out server.key 2048
#生成 CSR 注意Common Name 要输入域名 其他回车即可
openssl req -new -key server.key -out server.csr 
#删除私钥中的密码, 有利于自动化部署
openssl rsa -in server.key -out server.key 
#生成自签名证书
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt 
#生成 PEM 格式的证书
openssl x509 -in server.crt -out server.pem -outform PEM 
```

# nginx配置
```

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;
    #可去除80的配置
    server {
        listen       80;
        server_name  sola.com;

        #charset koi8-r;

        #access_log  logs/host.access.log  main;

        location / {
            proxy_pass  http://127.0.0.1:8081/;
        }

        #error_page  404              /404.html;

        # redirect server error pages to the static page /50x.html
        #
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }

    server {
        listen       443 ssl;
        server_name  sola.com; # 开成接口请求域名 记得本地host改为本机地址，否则无法劫持
        # ssl on;
        ssl_session_timeout 5m;        
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;      
        ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
        # 证书位置
        ssl_certificate   C:/Users/SOLA/Desktop/nginx-1.24.0/ssl/server.crt;
        ssl_certificate_key C:/Users/SOLA/Desktop/nginx-1.24.0/ssl/server.key;
        location / {
            proxy_pass http://192.168.0.244:8081/; #这里的换成后端ip
        }
    }

}

```


# nginx命令
```
./nginx.exe #启动
./nginx.exe -s reload #重启
./nginx.exe -s stop # 停止
```