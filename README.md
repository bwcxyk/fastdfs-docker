# FastDFS


## 目录介绍
### conf
Dockerfile 所需要的一些配置文件
当然你也可以对这些文件进行一些修改  比如`storage.conf`里面的`bast_path`等相关

## 使用方法
需要注意的是你需要在运行容器的时候指定启动模式，用参数`FASTDFS_MODE`来指定

启动tracker

```bash
docker run -d -e FASTDFS_MODE=tracker -e RESERVED_STORAGE_SPACE=10G -p 22122:22122--name tracker yaokun/fastdfs:V6.09
```

> `RESERVED_STORAGE_SPACE`可以是具体的GB、MB、KB、B
>
> 也可以是百分百，如：10%

启动storage

需要注意的是storage模式需要指定tracker服务地址，用参数`TRACKER_SERVER`来指定
> 兼容docker及k8s中服务名称的写法，比如`fdfs-tracker:22122`

```bash
docker run -d -e FASTDFS_MODE=storage -e TRACKER_SERVER=192.168.1.2:22122 -p 80:80 -p 23000:23000 --name tracker yaokun/fastdfs:V6.09
```


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
