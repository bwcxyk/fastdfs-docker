# debian
FROM debian:bullseye-slim

#环境变量
ENV TZ "Asia/Shanghai"

# conf
COPY conf/* /opt/
COPY fastdfs.sh /home/

# run
# install packages
RUN set -x \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        build-essential \
        libpcre3 \
        libpcre3-dev \
        zlib1g \
        zlib1g-dev \
        libssl-dev \
        wget \
        vim \
    && rm -rf /var/lib/apt/lists/*

# git clone libfastcommon / libserverframe / fastdfs / fastdfs-nginx-module
RUN set -x \
    && cd /usr/local/src \
    && git clone -b V1.0.68 https://github.com/happyfish100/libfastcommon.git --depth 1 \
    && git clone -b V1.1.28 https://github.com/happyfish100/libserverframe.git --depth 1 \
    && git clone -b V6.09 https://github.com/happyfish100/fastdfs.git --depth 1 \
    && git clone -b V1.23 https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1 \
    && wget https://nginx.org/download/nginx-1.26.2.tar.gz
# build libfastcommon / libserverframe / fastdfs
RUN set -x \
    && mkdir /home/dfs \
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
