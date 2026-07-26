#!/bin/bash

BACKUP_DIR="./docker_images_backup"

mkdir -p "$BACKUP_DIR"

echo "请选择操作："
echo "1) 自动导出所有镜像"
echo "2) 自动导入所有镜像"
read -p "请输入数字选择: " choice

# 自动导出所有镜像
if [ "$choice" == "1" ]; then
    echo "正在获取所有镜像列表..."
    IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}")

    if [ -z "$IMAGES" ]; then
        echo "没有找到任何镜像"
        exit 1
    fi

    echo "开始导出所有镜像到目录: $BACKUP_DIR"

    for IMG in $IMAGES; do
        SAFE_NAME=$(echo "$IMG" | sed 's|/|_|g; s|:|_|g')
        FILE="$BACKUP_DIR/${SAFE_NAME}.tar"

        echo "导出镜像: $IMG → $FILE"
        docker save -o "$FILE" "$IMG"
    done

    echo "所有镜像已导出完成"
    exit 0
fi

# 自动导入所有镜像
if [ "$choice" == "2" ]; then
    echo "从目录 $BACKUP_DIR 导入所有镜像..."

    for FILE in $BACKUP_DIR/*.tar; do
        echo "导入镜像文件: $FILE"
        docker load -i "$FILE"
    done

    echo "所有镜像已导入完成"
    exit 0
fi

echo "无效选择"
exit 1
