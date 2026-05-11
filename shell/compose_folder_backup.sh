#!/bin/bash

# --- 1. 基础配置 ---
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
LOCAL_BACKUP_ROOT="/opt/backup"
TEMP_DIR="$LOCAL_BACKUP_ROOT/temp_$BACKUP_DATE"

# 远程服务器配置
REMOTE_USER="root"
REMOTE_IP="1.2.3.4"
REMOTE_PORT="2222"
REMOTE_DIR="/home/backup/docker_projects"

# --- 2. 待备份的项目目录列表 ---
# 在这里填入你所有 Docker Compose 项目的绝对路径
PROJECT_PATHS=(
    "/opt/docker_apps/nginx_web"
    "/opt/docker_apps/mysql_db"
    "/opt/docker_apps/redis_cache"
)

# --- 3. 每一个项目中需要备份的子目录或文件名称 ---
# 比如每个项目里都有 data 文件夹和 config 文件夹需要备份
FILES_TO_BACKUP=("data" "config" "database.db" "settings.conf")

# --- 4. 执行逻辑 ---
mkdir -p "$TEMP_DIR"

for PROJECT_PATH in "${PROJECT_PATHS[@]}"; do
    if [ ! -d "$PROJECT_PATH" ]; then
        echo "跳过：目录 $PROJECT_PATH 不存在"
        continue
    fi

    PROJECT_NAME=$(basename "$PROJECT_PATH")
    echo ">>> 正在处理项目: $PROJECT_NAME"
    
    # 进入项目目录
    cd "$PROJECT_PATH" || continue

    # A. 停止并移除容器 (确保文件不再被占用/写入)
    echo "停止并下线项目..."
    docker compose down

    # B. 创建该项目的独立备份子目录
    PROJECT_TEMP="$TEMP_DIR/$PROJECT_NAME"
    mkdir -p "$PROJECT_TEMP"

    # C. 复制指定的文件或文件夹
    for ITEM in "${FILES_TO_BACKUP[@]}"; do
        if [ -e "$ITEM" ]; then
            echo "正在复制 $ITEM ..."
            cp -ra "$ITEM" "$PROJECT_TEMP/"
        fi
    done

    # D. 重新上线项目
    echo "重新启动项目..."
    docker compose up -d
done

# --- 5. 统一压缩与传输 ---
FINAL_GZ="$LOCAL_BACKUP_ROOT/all_compose_backup_$BACKUP_DATE.tar.gz"

echo ">>> 正在统一打包压缩..."
tar -czf "$FINAL_GZ" -C "$TEMP_DIR" .

echo ">>> 正在通过端口 $REMOTE_PORT 传输至远程服务器..."
# 使用 rsync 配合 SSH 密钥实现免密传输
rsync -avz -e "ssh -p $REMOTE_PORT" "$FINAL_GZ" "$REMOTE_USER@$REMOTE_IP:$REMOTE_DIR"

# --- 6. 清理 ---
echo ">>> 清理临时文件..."
rm -rf "$TEMP_DIR"
# 保留本地最近 5 天的压缩包
find "$LOCAL_BACKUP_ROOT" -name "*.tar.gz" -mtime +5 -delete

echo ">>> 备份任务于 $(date) 全部完成！"
