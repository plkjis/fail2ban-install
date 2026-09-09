#!/bin/bash

BACKUP_DIR="./docker_images_backup"

mkdir -p "$BACKUP_DIR"

echo "请选择操作："
echo "1) 自动导出所有镜像"
echo "2) 自动导入所有镜像"
read -p "请输入数字选择: " choice

if [ "$choice" == "1" ]; then
    echo "正在获取镜像列表..."

    IMAGES=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")

    if [ -z "$IMAGES" ]; then
        echo "没有可导出的镜像"
        exit 1
    fi

    echo "开始导出所有镜像到目录: $BACKUP_DIR"

    for IMG in $IMAGES; do
        SAFE_NAME=$(echo "$IMG" | sed 's|[^a-zA-Z0-9._-]|_|g')
        FILE="$BACKUP_DIR/${SAFE_NAME}.tar"

        echo "导出镜像: $IMG → $FILE"

        if docker save -o "$FILE" "$IMG"; then
            echo "导出成功: $FILE"
        else
            echo "导出失败: $IMG"
        fi
    done

    echo "所有镜像已导出完成"
    exit 0
fi

if [ "$choice" == "2" ]; then
    echo "从目录 $BACKUP_DIR 导入所有镜像..."

    shopt -s nullglob
    FILES=("$BACKUP_DIR"/*.tar)

    if [ ${#FILES[@]} -eq 0 ]; then
        echo "没有找到镜像备份文件"
        exit 1
    fi

    for FILE in "${FILES[@]}"; do
        echo "导入镜像文件: $FILE"
        docker load -i "$FILE"
    done

    echo "所有镜像已导入完成"
    exit 0
fi

echo "无效选择"
exit 1
