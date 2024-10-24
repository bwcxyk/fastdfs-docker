# debian
FROM debian:bullseye-slim

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
    && apt-get install -y --no-install-recommends ca-certificates build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev wget git \
    # build fastdfs
    && mkdir /opt/tmp /opt/fastdfs \
    && ls /opt \
    && cd /opt/tmp \
    # git clone libfastcommon, libserverframe, fastdfs, fastdfs-nginx-module
    && git clone -b V1.0.68 https://github.com/happyfish100/libfastcommon.git --depth 1 \
    && git clone -b V1.1.28 https://github.com/happyfish100/libserverframe.git --depth 1 \
    && git clone -b V6.09 https://github.com/happyfish100/fastdfs.git --depth 1 \
    && git clone -b V1.23 https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1 \
    && wget https://nginx.org/download/nginx-$NGINX_VERSION.tar.gz \
    && tar -zxvf nginx-$NGINX_VERSION.tar.gz \
    # build libfastcommon, libserverframe, fastdfs
    && cd /opt/tmp/libfastcommon && ./make.sh && ./make.sh install \
    && cd /opt/tmp/libserverframe && ./make.sh && ./make.sh install \
    && cd /opt/tmp/fastdfs && ./make.sh && ./make.sh install \
    # build nginx and add fastdfs-nginx-module
    && cd /opt/tmp/nginx-$NGINX_VERSION \
    && ./configure --add-module=/opt/tmp/fastdfs-nginx-module/src \
    && make && make install \
    # cp script
    && cp /opt/tmp/fastdfs/init.d/fdfs_trackerd /usr/local/bin/fdfs_trackerd \
    && cp /opt/tmp/fastdfs/init.d/fdfs_storaged /usr/local/bin/fdfs_storaged \
    && chmod +x /usr/local/bin/fastdfs.sh /usr/local/bin/fdfs_trackerd /usr/local/bin/fdfs_storaged \
    # cleanup
    && apt-get purge -y build-essential libpcre3-dev zlib1g-dev libssl-dev \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /opt/tmp

VOLUME /opt/fastdfs

EXPOSE 22122 23000 80
CMD ["fastdfs.sh"]
