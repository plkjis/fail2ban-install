#!/bin/bash

# 显示菜单
echo "请选择操作："
echo "1) 导出镜像 (docker save)"
echo "2) 导入镜像 (docker load)"
read -p "请输入数字选择: " choice

# 导出镜像
if [ "$choice" == "1" ]; then
    echo "当前镜像列表："
    docker images --format "{{.Repository}}:{{.Tag}}  {{.ID}}  {{.Size}}"

    read -p "请输入要导出的镜像名（例如 nginx:latest）: " img
    if [ -z "$img" ]; then
        echo "镜像名不能为空"
        exit 1
    fi

    # 自动生成文件名
    filename=$(echo "$img" | sed 's/:/_/').tar

    # 防止覆盖
    if [ -f "$filename" ]; then
        echo "文件 $filename 已存在，已自动加时间戳避免覆盖"
        filename="${filename%.tar}_$(date +%Y%m%d%H%M%S).tar"
    fi

    echo "正在导出镜像到 $filename ..."
    docker save -o "$filename" "$img"

    echo "导出完成：$filename"
    exit 0
fi

# 导入镜像
if [ "$choice" == "2" ]; then
    read -p "请输入要导入的镜像文件路径（例如 nginx.tar）: " file
    if [ ! -f "$file" ]; then
        echo "文件不存在：$file"
        exit 1
    fi

    echo "正在导入镜像..."
    docker load -i "$file"

    echo "导入完成"
    exit 0
fi

echo "无效选择"
exit 1
