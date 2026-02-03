#!/bin/bash

TRACKER_ADDR="${TRACKER_SERVER:-fdfs-tracker:22122}"
RESERVED_STORAGE_SPACE="${RESERVED_STORAGE_SPACE:-10%}"

# 复制配置文件
cp /home/http.conf /etc/fdfs/http.conf
cp /home/mime.types /etc/fdfs/mime.types
cp /home/nginx.conf /usr/local/nginx/conf/nginx.conf
cp /home/tracker.conf /etc/fdfs/tracker.conf
# 需要替换 tracker address
cp /home/storage.conf /etc/fdfs/storage.conf
cp /home/client.conf /etc/fdfs/client.conf
cp /home/mod_fastdfs.conf /etc/fdfs/mod_fastdfs.conf
# 替换 tracker address
sed -i -e "s|###TRACKER###|${TRACKER_ADDR}|g" /etc/fdfs/client.conf
sed -i -e "s|###TRACKER###|${TRACKER_ADDR}|g" /etc/fdfs/storage.conf
sed -i -e "s|###TRACKER###|${TRACKER_ADDR}|g" /etc/fdfs/mod_fastdfs.conf
sed -i -e "s|###RESERVED_STORAGE_SPACE###|${RESERVED_STORAGE_SPACE}|g" /etc/fdfs/tracker.conf

# 启动服务
case "${FASTDFS_MODE}" in
    "tracker")
        echo "Starting FastDFS Tracker..."
        # 启动 tracker
        /usr/local/bin/fdfs_trackerd start
        # 等待日志文件生成
        while [ ! -f /opt/fastdfs/logs/trackerd.log ]; do sleep 1; done
        # 保持容器运行：持续监控日志流
        exec tail -f /opt/fastdfs/logs/trackerd.log
        ;;

    "storage")
        echo "Starting FastDFS Storage and Nginx..."
        # Nginx 日志重定向到容器标准输出流
        mkdir -p /usr/local/nginx/logs
        ln -sf /dev/stdout /usr/local/nginx/logs/access.log
        ln -sf /dev/stderr /usr/local/nginx/logs/error.log
        # 启动 storage
        /usr/local/bin/fdfs_storaged start
        # 等待日志文件生成
        while [ ! -f /opt/fastdfs/logs/storaged.log ]; do sleep 1; done
        # 持续输出 storage 日志
        tail -f /opt/fastdfs/logs/storaged.log &
        # Nginx 以前台模式运行，作为容器的守护进程
        exec /usr/local/nginx/sbin/nginx -g 'daemon off;'
        ;;

    *)
        echo "Error: FASTDFS_MODE must be 'tracker' or 'storage'"
        exit 1
        ;;
esac
