1.`vim /etc/ssh/sshd_config`   
   
2.设置为密码登陆方式   

a.查找`PermitRootLogin yes`删除前面的#注释   

b.查找`PasswordAuthentication no`改为`PasswordAuthentication yes`   
   
3.重启ssh服务或重启服务器`service sshd restart`
