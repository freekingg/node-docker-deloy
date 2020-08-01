# Dockerfile

FROM node:12.16.3-alpine

LABEL maintainer="king"

# 定位到容器的工作目录
WORKDIR /usr/src/koaApp/

RUN npm config set registry "https://registry.npm.taobao.org/" \
  && npm install -g pm2

# RUN/COPY 是分层的，package.json 提前，只要没修改，就不会重新安装包
COPY ./package*.json /usr/src/koaApp/

#安装依赖
RUN npm install

# 把当前目录下的所有文件拷贝到 Image 的 /usr/src/testApp/ 目录下
COPY . /usr/src/koaApp/

#暴露端口
EXPOSE 3006

#容器启动后执行的命令
# CMD node app.js 
CMD pm2 start app.js --no-daemon