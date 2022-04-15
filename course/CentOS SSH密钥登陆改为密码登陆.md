1.`vim /etc/ssh/sshd_config`   
   
2.设置为密码登陆方式   

a.查找`PermitRootLogin yes`删除前面的#注释   

b.查找`PasswordAuthentication no`改为`PasswordAuthentication yes`   
   
3.重启ssh服务或重启服务器`service sshd restart`


切换为root密码登录：
1.切换到root：`sudo -i`   
2.修改密码&登录方式
```
echo root:passwd|sudo chpasswd root
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
```
3.重启：`sudo service sshd restart`
