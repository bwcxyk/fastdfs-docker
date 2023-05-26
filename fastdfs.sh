#!/bin/bash

#
cp /home/http.conf /etc/fdfs/http.conf
cp /home/mime.types /etc/fdfs/mime.types
cp /home/nginx.conf /usr/local/nginx/conf/nginx.conf
cp /home/tracker.conf /etc/fdfs/tracker.conf
#
cp /home/storage.conf /etc/fdfs/storage.conf
cp /home/client.conf /etc/fdfs/client.conf
cp /home/mod_fastdfs.conf /etc/fdfs/mod_fastdfs.conf

sed -i -e "s|###TRACKER###|$TRACKER_SERVER|g" /etc/fdfs/client.conf
sed -i -e "s|###TRACKER###|$TRACKER_SERVER|g" /etc/fdfs/storage.conf
sed -i -e "s|###TRACKER###|$TRACKER_SERVER|g" /etc/fdfs/mod_fastdfs.conf

echo ${FASTDFS_MODE}

if [ "${FASTDFS_MODE}" = "tracker" ] ;
    then
    echo "start trackerd"
    /etc/init.d/fdfs_trackerd start
    tail -f /dev/null
    elif [ "${FASTDFS_MODE}" = "storage" ];
    then
    echo "start storage"
    /etc/init.d/fdfs_storaged start
    echo "start nginx"
    /usr/local/nginx/sbin/nginx 
    tail -f /dev/null
    else
    echo 'You need to choose the "FASTDFS_MODE"'
fi