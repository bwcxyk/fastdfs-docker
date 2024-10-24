#!/bin/bash

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
sed -i -e "s|###TRACKER###|${TRACKER_SERVER}|g" /etc/fdfs/client.conf
sed -i -e "s|###TRACKER###|${TRACKER_SERVER}|g" /etc/fdfs/storage.conf
sed -i -e "s|###TRACKER###|${TRACKER_SERVER}|g" /etc/fdfs/mod_fastdfs.conf
sed -i -e "s|###RESERVED_STORAGE_SPACE###|${RESERVED_STORAGE_SPACE}|g" /etc/fdfs/tracker.conf

echo "${FASTDFS_MODE}"

if [ "${FASTDFS_MODE}" = "tracker" ] ;
    then
    echo "start trackerd"
    # Start the tracker
    /usr/local/bin/fdfs_trackerd start
    # Wait for the log file to be generated
    while [ ! -f /home/dfs/logs/trackerd.log ]; do
        sleep 1
    done
    tail -f /home/dfs/logs/trackerd.log
elif [ "${FASTDFS_MODE}" = "storage" ];
    then
    echo "start storage and nginx"
    # Start the storage and nginx
    /usr/local/bin/fdfs_storaged start && /usr/local/nginx/sbin/nginx
    # Wait for the log file to be generated
    while [ ! -f /home/dfs/logs/storaged.log ]; do
        sleep 1
    done
    tail -f /home/dfs/logs/storaged.log
else
    echo 'You need to choose the "FASTDFS_MODE"'
fi

# Keep the container running
# tail -f /dev/null
