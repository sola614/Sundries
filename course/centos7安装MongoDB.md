# 新建配置文件
命令
```
vim /etc/yum.repos.d/mongodb-org-4.2.repo
```
在该文件填入

```
[mongodb-org-4.2]
name=MongoDB Repository
baseurl=https://repo.mongodb.org/yum/redhat/$releasever/mongodb-org/4.2/x86_64/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-4.2.asc
```
ps:如果提示vim不存在则执行`yum install vim -y`安装
vim命令下i为编辑，:wq为保存

# 用yum安装
命令
```
sudo yum install -y mongodb-org
```

# 启动
命令
```
sudo systemctl start mongod
```
# 验证能否使用
命令
```
mongo
```

# 其他命令
查询状态：`sudo systemctl status mongod`
重启：`sudo systemctl stop mongod`
停止：`sudo systemctl restart mongod`

# 卸载
1.停止mongodb服务
`sudo service mongod stop`
2.移除mongodb所有安装包
`sudo yum erase $(rpm -qa | grep mongodb-org)`
3.删除日志和数据
```
sudo rm -r /var/log/mongodb
sudo rm -r /var/lib/mongo
```

# 数据导出和导入

mongodump -h dbhost  -d dbname -o dbdirectory

-h:  mongodb所在服务器地址，例如127.0.0.1，也可以指定端口:127.0.0.1:8080 

-d:  需要备份的数据库名称，例如：test_data

-o:  备份的数据存放的位置，例如：/home/bak

-u:  用户名称，使用权限验证的mongodb服务，需要指明导出账号

-p：用户密码，使用权限验证的mongodb服务，需要指明导出账号密码

//多个
mongorestore -h dbhost -d dbname -dorectoryperdb dbdireactory

-h:  mongodb所在服务器地址

-d:  需要恢复备份的数据库名称，例如：test_data，可以跟原来备份的数据库名称不一样

-directoryperdb: 备份数据所在位置，例如：/home/bak/test

-drop: 加上这个参数的时候，会在恢复数据之前删除当前数据；

//单个
mongorestore -d 表名 -c 集合名 --drop  备份数据路径/集合名.bson
