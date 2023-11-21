# centos 7
FROM centos:7

#环境变量
ENV TZ "Asia/Shanghai"

# conf
COPY conf/* /opt/
COPY fastdfs.sh /home/

# run
# install packages
RUN yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel wget vim -y
# git clone libfastcommon / libserverframe / fastdfs / fastdfs-nginx-module
RUN cd /usr/local/src \
    && git clone https://github.com/happyfish100/libfastcommon.git --depth 1 \
    && ls libfastcommon \
    && git clone https://github.com/happyfish100/libserverframe.git --depth 1 \
    && ls libserverframe \
    && git clone -b V6.09 https://github.com/happyfish100/fastdfs.git --depth 1    \
    && ls fastdfs \
    && git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1  \
    && ls fastdfs-nginx-module \
    && wget http://nginx.org/download/nginx-1.22.1.tar.gz
# build libfastcommon / libserverframe / fastdfs
RUN mkdir /home/dfs \
    && cd /usr/local/src  \
    && cd /usr/local/src/libfastcommon \
    && ./make.sh && ./make.sh install \
    && cd /usr/local/src/libserverframe \
    && ./make.sh && ./make.sh install \
    && cd /usr/local/src/fastdfs \
    && ./make.sh && ./make.sh install \
    && cd /usr/local/src \
    && tar -zxvf nginx-1.22.1.tar.gz \
    && cd /usr/local/src/nginx-1.22.1 \
    && ./configure --add-module=/usr/local/src/fastdfs-nginx-module/src \
    && make && make install \
    && chmod +x /home/fastdfs.sh
  
RUN cp /usr/local/src/fastdfs/init.d/fdfs_trackerd /etc/init.d/fdfs_trackerd \
    && cp /usr/local/src/fastdfs/init.d/fdfs_storaged /etc/init.d/fdfs_storaged \
    && rm -rf /usr/local/src*

VOLUME /home/dfs

EXPOSE 22122 23000 80
ENTRYPOINT ["/home/fastdfs.sh"]