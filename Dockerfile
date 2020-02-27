#基础镜像
FROM alpine:3.10

#环境变量
ENV TZ "Asia/Shanghai"
#ENV FASTDFS_MODE=storage

# 添加配置文件
ADD conf/client.conf /etc/fdfs/
ADD conf/http.conf /etc/fdfs/
ADD conf/mime.types /etc/fdfs/
ADD conf/storage.conf /etc/fdfs/
ADD conf/tracker.conf /etc/fdfs/
ADD conf/nginx.conf /etc/fdfs/
ADD conf/mod_fastdfs.conf /etc/fdfs
ADD fastdfs.sh /home

RUN set -x \
    && echo "http://mirrors.aliyun.com/alpine/latest-stable/main/" > /etc/apk/repositories \
    && echo "http://mirrors.aliyun.com/alpine/latest-stable/community/" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache --virtual .build-deps alpine-sdk build-base perl-dev openssl-dev pcre-dev zlib-dev git \
    && mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && git clone https://github.com/happyfish100/libfastcommon.git --depth 1 \
    && git clone https://github.com/happyfish100/fastdfs.git --depth 1    \
    && git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1  \
    && wget http://nginx.org/download/nginx-1.16.1.tar.gz \
    && tar -zxvf nginx-1.16.1.tar.gz \
    && cd /usr/local/src/libfastcommon \
    && ./make.sh \
    && ./make.sh install \
    && cd /usr/local/src/fastdfs/ \
    && ./make.sh \
    && ./make.sh install \
    && cd /usr/local/src/nginx-1.16.1/ \
    && ./configure --add-module=/usr/local/src/fastdfs-nginx-module/src/ \
    && make && make install \
    && apk del .build-deps \
    && apk add --no-cache pcre-dev bash \
    && mkdir -p /home/dfs \
    && chmod +x /home/fastdfs.sh \
    && rm -rf /usr/local/src*
	
VOLUME /home/dfs

EXPOSE 22122 23000 8888 80

CMD ["/home/fastdfs.sh"]