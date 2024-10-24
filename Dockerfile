# debian
FROM debian:bookworm-slim

ARG NGINX_VERSION=1.26.2

ENV TZ "Asia/Shanghai"

# conf
COPY conf/* /home/
COPY fastdfs.sh /usr/local/bin/

# run
# install packages
RUN set -x \
    # && sed -i 's|deb.debian.org|mirrors.tuna.tsinghua.edu.cn|g' /etc/apt/sources.list.d/debian.sources \
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
    && mkdir /opt/tmp \
    && cd /opt/tmp \
    && git clone -b V1.0.71 https://github.com/happyfish100/libfastcommon.git --depth 1 \
    && git clone -b V1.2.1 https://github.com/happyfish100/libserverframe.git --depth 1 \
    && git clone -b V6.11.0 https://github.com/happyfish100/fastdfs.git --depth 1 \
    && git clone -b V1.24 https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1 \
    && wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
# build libfastcommon / libserverframe / fastdfs
RUN set -x \
    && mkdir /opt/fastdfs \
    && cd /opt/tmp  \
    && cd /opt/tmp/libfastcommon \
    && ./make.sh && ./make.sh install \
    && cd /opt/tmp/libserverframe \
    && ./make.sh && ./make.sh install \
    && cd /opt/tmp/fastdfs \
    && ./make.sh && ./make.sh install \
    && cd /opt/tmp \
    && tar -zxvf nginx-$NGINX_VERSION.tar.gz \
    && cd /opt/tmp/nginx-$NGINX_VERSION \
    && ./configure --add-module=/opt/tmp/fastdfs-nginx-module/src \
    && make && make install \
    && chmod +x /usr/local/bin/fastdfs.sh
  
RUN cp /opt/tmp/fastdfs/init.d/fdfs_trackerd /usr/local/bin/fdfs_trackerd \
    && cp /opt/tmp/fastdfs/init.d/fdfs_storaged /usr/local/bin/fdfs_storaged \
    && rm -rf /opt/tmp

VOLUME /opt/fastdfs

EXPOSE 22122 23000 80
ENTRYPOINT ["fastdfs.sh"]
