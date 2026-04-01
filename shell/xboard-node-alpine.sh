cat << 'EOF' > /etc/init.d/xboard-node
#!/sbin/openrc-run

name="xboard-node"
description="XBoard Node Service"
command="/usr/local/bin/xboard-node"
command_args="-c /etc/xboard-node/config.yml"
pidfile="/run/${RC_SVCNAME}.pid"
command_background="yes"

output_log="/var/log/xboard-node.log"
error_log="/var/log/xboard-node.err"

depend() {
    need net
    after firewall
}

start_pre() {
    checkpath -f -m 0644 "$output_log"
    checkpath -f -m 0644 "$error_log"
}
EOF

# 授权并启动
chmod +x /etc/init.d/xboard-node
rc-update add xboard-node default
rc-service xboard-node start
