# FastDFS

### 版本说明

|   FastDFS   | libfastcommon | libserverframe | fastdfs-nginx-module |
| :---------: | :-----------: | :------------: | :------------------: |
| **v6.12.2** |    v1.0.75    |     v1.2.5     |        v1.24         |
| **v6.11.0** |    v1.0.71    |     v1.2.1     |        v1.24         |
| **v6.10.0** |    v1.0.70    |    v1.1.28     |        v1.22         |
|  **v6.09**  |    v1.0.68    |    v1.1.28     |        v1.23         |
|  **v5.05**  |    v1.0.7     |   **不需要**   |        v1.20         |

FastDFS v6.x 开始必须依赖 `libserverframe`（网络框架库），v5.x 及以下版本无需。

## 目录介绍

### conf
Dockerfile 所需要的一些配置文件
当然你也可以对这些文件进行一些修改  比如`storage.conf`里面的`bast_path`等相关

## 使用方法
需要注意的是你需要在运行容器的时候指定启动模式，用参数`FASTDFS_MODE`来指定

启动tracker

```bash
docker run -d -e FASTDFS_MODE=tracker -e RESERVED_STORAGE_SPACE=10G -p 22122:22122 --name tracker yaokun/fastdfs:V6.09
```

> `RESERVED_STORAGE_SPACE`可以是具体的GB、MB、KB、B
>
> 也可以是百分百，如：10%

启动storage

需要注意的是storage模式需要指定tracker服务地址，用参数`TRACKER_SERVER`来指定
> 兼容docker及k8s中服务名称的写法，比如`fdfs-tracker:22122`

```bash
docker run -d -e FASTDFS_MODE=storage -e TRACKER_SERVER=192.168.1.2:22122 -p 80:80 -p 23000:23000 --name storage yaokun/fastdfs:V6.12.2
```

## 环境变量

以下变量均可在 `docker run -e` 或 compose 的 `environment` 中指定，未指定时使用默认值。

|            变量            |                 默认值                 |      作用范围       | 说明                                                                            |
| :------------------------: | :-------------------------------------: | :-----------------: | :------------------------------------------------------------------------------ |
|       `FASTDFS_MODE`       |                   无                    | tracker / storage   | **必填**，启动模式                                                              |
|      `TRACKER_SERVER`      |           `fdfs-tracker:22122`          |       storage       | 该 storage 连接的 tracker 地址，格式 `HOST:PORT`                                  |
| `RESERVED_STORAGE_SPACE`   |                  `10%`                  |       tracker       | 预留空间，可写 `10G`/`500M`/`10%`                                               |
|  `ANTI_STEAL_CHECK_TOKEN`  |                `false`                  |       storage       | 是否开启防盗链（token 校验）                                                    |
|   `ANTI_STEAL_SECRET_KEY`  |         `FastDFS1234567890`             |       storage       | 防盗链密钥；开启防盗链后**必须修改**，不要使用特殊符号                         |

> 注意：配置文件中的 `###XXX###` 为占位符，由启动脚本 `entrypoint.sh` 在容器启动时用上述环境变量替换，
> 直接修改镜像内的 `/etc/fdfs/*.conf` 不会生效（每次启动都会被覆盖），请通过环境变量设置。

### 开启防盗链

```bash
docker run -d -e FASTDFS_MODE=storage -e TRACKER_SERVER=192.168.1.2:22122 \
  -e ANTI_STEAL_CHECK_TOKEN=true -e ANTI_STEAL_SECRET_KEY=your-secret-key \
  -p 80:80 -p 23000:23000 --name storage yaokun/fastdfs:V6.12.2
```

开启后访问 URL 必须携带 token，即 `?ts=<时间戳>&token=<md5>`，由 FastDFS 客户端（如 `fastdfs-client-java`）用同一密钥生成，否则返回 404。


### 状态检查
```bash
fdfs_monitor /etc/fdfs/client.conf
```

### 测试上传
进入docker
```bash
docker exec -it fastdfs /bin/bash
```

创建文件
```bash
echo "Hello FastDFS">test.txt
```

fastdfs自带命令上传
```bash
fdfs_test /etc/fdfs/client.conf upload test.txt
```
