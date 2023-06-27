# 复制上传

rclone -v copy --transfers 32 --log-file 日志文件路径(如/root/rclone.log) 移动文件路径(如/data/file/FILENAME) alist:aliyun/software/

# 挂载

rclone -v mount alist:/ /data/alist --cache-dir /data_disk/tmp --allow-other --vfs-cache-mode writes --allow-non-empty --umask 000 --daemon --log-file /root/logs/rclone.log

# 取消挂载

fusermount -qzu 挂载路径

# alist 的 webdav url

http://127.0.0.1:5244/dav/
