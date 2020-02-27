# centos 7
FROM centos:7

#环境变量
ENV TZ "Asia/Shanghai"

# conf
COPY conf/* /etc/fdfs/
COPY fastdfs.sh /home/

# run
RUN yum install git gcc gcc-c++ make automake autoconf libtool pcre pcre-devel zlib zlib-devel openssl-devel wget vim -y \
  &&    cd /usr/local/src \
  &&    git clone https://github.com/happyfish100/libfastcommon.git --depth 1 \
  &&    git clone https://github.com/happyfish100/fastdfs.git --depth 1 \
  &&    git clone https://github.com/happyfish100/fastdfs-nginx-module.git --depth 1 \
  &&    wget http://nginx.org/download/nginx-1.16.1.tar.gz \
  &&    tar -zxvf nginx-1.16.1.tar.gz \
  &&    mkdir /home/dfs \
  &&    cd /usr/local/src/libfastcommon \
  &&    ./make.sh \
  &&    ./make.sh install \
  &&    cd /usr/local/src/fastdfs/ \
  &&    ./make.sh \
  &&    ./make.sh install \
  &&    cd /usr/local/src/nginx-1.16.1/ \
  &&    ./configure --add-module=/usr/local/src/fastdfs-nginx-module/src/ \
  &&    make && make install \
  &&    chmod +x /home/fastdfs.sh \
  &&    rm -rf /usr/local/src/*

VOLUME /home/dfs

EXPOSE 22122 23000 80
ENTRYPOINT ["/home/fastdfs.sh"]