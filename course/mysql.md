1.创建用户:`create user 'name'@'host' identified by 'password';`   
2.查看权限:`show grants for 'name'@'host';`   
3.授权某张表给某用户:`grant all privileges on dbname.* to 'name'@'host';`   
4.查看当前用户数据库:`show databases;`   
5.切换用户:`mysql -u username -p`   
6.建库:`create database 库名;`   
7.删库:`drop database 库名;`   
8.使用库:`use 库名;`   
8.建表:`create table 表名 (字段设定列表);`(需要使用库后创建)   
9.删表:`drop table 表名;`(需要使用库后删除)
