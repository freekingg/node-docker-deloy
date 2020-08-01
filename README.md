# 用 Docker 搭建 nodejs 应用

### 创建koa项目
通过koa框架写一个hello-world项目
app.js
```
const Koa = require('koa');
const app = new Koa();

app.use(async ctx => {
  ctx.body = 'Hello World';
});

app.listen(3000);
```

### 创建 Dockerfile 文件
```
FROM node:12.16.3-alpine

LABEL maintainer="SvenDowideit@home.org.au"

# 在容器中创建一个目录
RUN mkdir -p /usr/src/testApp/

# 定位到容器的工作目录
WORKDIR /usr/src/testApp/

# RUN/COPY 是分层的，package.json 提前，只要没修改，就不会重新安装包
COPY ./package*.json /usr/src/testApp/

#安装依赖
RUN npm install

# 把当前目录下的所有文件拷贝到 Image 的 /usr/src/testApp/ 目录下
COPY . /usr/src/testApp/

#暴露端口
EXPOSE 3000

#容器启动后执行的命令
CMD node app.js 
```

### 制作镜像
有了 Dockerfile 以后，我们可以运行下面的命令构建前端镜像并命名为 my-koa-app：

```
docker build -t my-koa-app .
```

### 启动容器
最后，让我们从镜像启动容器：

```

docker run \
-p 3006:3000 \
-d --name koaApp \
my-koa-app

```

这样子我们就能从 3006 端口去访问我们的 node 应用。

###  应用运行优化

当然， Node 是公认的不稳定，经常会出现服务器内存溢出，而崩溃退出。

我们针对这一点，可以对 koa 启动命令做优化。引入 pm2 插件，通过 pm2 来启动 express 应用。

> 使用命令 `pm2 start app.js` 之后, pm2 默认在后台运行, 如果使用了 Docker 后,容器运行并立即退出,需要手动给“ pm2 ”指定参数 `--no-daemon`


```
FROM node:12.1.3-alpine

LABEL maintainer="SvenDowideit@home.org.au"

# 在容器中创建一个目录
RUN mkdir -p /usr/src/testApp/

# 定位到容器的工作目录
WORKDIR /usr/src/testApp/

RUN npm install -g pm2

# RUN/COPY 是分层的，package.json 提前，只要没修改，就不会重新安装包
COPY ./package*.json /usr/src/testApp/

#安装依赖
RUN npm install

# 把当前目录下的所有文件拷贝到 Image 的 /usr/src/testApp/ 目录下
COPY . /usr/src/testApp/

#暴露端口
EXPOSE 3000

#容器启动后执行的命令
CMD pm2 start app.js --no-daemon 

```