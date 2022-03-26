# vscode

基于Microsoft Code Server打包的Docker镜像，在原来的基础上增加了以下功能：
- 中文支持
- 基本编辑器
- 安装`Z Shell`并做了以下增加
    - 安装`Ohmyzsh`
    - 安装各种插件
        - 自动提示
        - 代码高亮
    - 安装`powerlevel10k`主题
    - 安装各种字体
        - `Jetbrains Mono`
        - `Powerline`字体

## 使用

使用方式非常简单，直接上代码

```shell
TAG="storezhang/vscode" && NAME="VSCode" && sudo docker pull ${TAG} && sudo docker stop ${NAME} ; sudo docker rm --force --volumes ${NAME} ; sudo docker run \
  --volume=你机器上数据目录:/config \
  --hostname=vscode \
  \
  \
  \
  --env=UID=1026 \
  --env=GID=100 \
  \
  \
  \
  --env=PASSWORD=你想设置的密码 \
  --env=USER_PASSWORD=在控制台切换超级用户时的密码 \
  --env=DOMAIN=你的域名 \
  --env=WORKSPACE=/config/workspace \
  \
  \
  \
  --publish=想暴露的端口:8443 \
  --restart=always \
  --detach=true \
  --name=${NAME} \
  ${TAG}
```
