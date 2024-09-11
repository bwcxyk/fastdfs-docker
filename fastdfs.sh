#!/bin/bash

RESERVED_STORAGE_SPACE="${RESERVED_STORAGE_SPACE:-10%}"

# 复制配置文件
cp /opt/http.conf /etc/fdfs/http.conf
cp /opt/mime.types /etc/fdfs/mime.types
cp /opt/nginx.conf /usr/local/nginx/conf/nginx.conf
cp /opt/tracker.conf /etc/fdfs/tracker.conf
# 需要替换tracker address
cp /opt/storage.conf /etc/fdfs/storage.conf
cp /opt/client.conf /etc/fdfs/client.conf
cp /opt/mod_fastdfs.conf /etc/fdfs/mod_fastdfs.conf

sed -i -e "s|###TRACKER###|$TRACKER_SERVER|g" /etc/fdfs/client.conf
sed -i -e "s|###TRACKER###|$TRACKER_SERVER|g" /etc/fdfs/storage.conf
sed -i -e "s|###TRACKER###|$TRACKER_SERVER|g" /etc/fdfs/mod_fastdfs.conf
sed -i -e "s|###RESERVED_STORAGE_SPACE###|$RESERVED_STORAGE_SPACE|g" /etc/fdfs/tracker.conf

echo ${FASTDFS_MODE}

if [ "${FASTDFS_MODE}" = "tracker" ] ;
    then
    echo "start trackerd"
    /etc/init.d/fdfs_trackerd start
    tail -f /home/dfs/logs/trackerd.log
    elif [ "${FASTDFS_MODE}" = "storage" ];
    then
    echo "start storage and nginx"
    /etc/init.d/fdfs_storaged start && /usr/local/nginx/sbin/nginx
    tail -f /home/dfs/logs/storaged.log
    else
    echo 'You need to choose the "FASTDFS_MODE"'
fi

# Keep the container running
# tail -f /dev/null
