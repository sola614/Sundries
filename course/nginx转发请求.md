### nginx转发请求

例子：请求`http://a.com/api`需自动转发到`http://b.com/api`
```
server {
      server_name a.com;

      location /api/ {
          proxy_pass http://b.com/;
      }
}
```
