ARG VSCODE_HOME=/opt/microsoft/vscode



FROM storezhang/ubuntu AS vscode


# VSCode版本
ENV VERSION 4.2.0
ENV OUTPUT_FILE vscode.tar.gz
ENV OUTPUT_FOLDER code-server-${VERSION}-linux-amd64
WORKDIR /opt


ARG VSCODE_HOME
RUN apt update -y
RUN apt install axel -y
RUN axel --insecure --num-connections=64 https://ghproxy.com/https://github.com/coder/code-server/releases/download/v${VERSION}/code-server-${VERSION}-linux-amd64.tar.gz --output ${OUTPUT_FILE}
RUN tar xf ${OUTPUT_FILE}
RUN mkdir -p ${VSCODE_HOME}
RUN mv ${OUTPUT_FOLDER} ${VSCODE_HOME}



# 打包真正的镜像
# 之所以使用Ubuntu镜像而不是Alpine镜像，是因为在VSCode的使用过程中，会用到系统相关功能，而Ubuntu显然比Alpine在易用性上要好得多
FROM storezhang/ubuntu


LABEL author="storezhang<华寅>"
LABEL email="storezhang@gmail.com"
LABEL qq="160290688"
LABEL wechat="storezhang"
LABEL description="VSCode网页版本，在原来的功能上增加：1、中文支持；2、编译工具支持；3、解决权限问题"


# 超级用户密码
ENV SUDO_PASSWORD storezhang
# 访问密码
ENV PASSWORD storezhang
# Z Shell主目录
ENV OHMYZSH_HOME /opt/system/ohmyzsh


# 复制文件
ARG VSCODE_HOME
COPY --from=vscode ${VSCODE_HOME} ${VSCODE_HOME}
COPY docker /


RUN set -ex \
    \
    \
    \
    && apt update -y \
    && apt upgrade -y \
    # 将用户可以使用最高权限
    && apt install sudo -y \
    # 给用户设置密码
    && echo ${USERNAME}:${SUDO_PASSWORD} | chpasswd \
    # 将用户加入超级用户组
    && adduser ${USERNAME} sudo \
    \
    \
    \
    # 安装Gcc，因为在后续过程中需要此工具来编译各种扩展
    && apt install build-essential git-core -y \
    \
    # 安装Z Shell并美化控制台
    && apt install zsh -y \
    && git clone https://ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git ${OHMYZSH_HOME} \
    && usermod --shell /bin/zsh ${USERNAME} \
    \
    \
    \
    # 增加执行权限
    && chmod +x /etc/s6/vscode/* \
    && chmod +x /usr/bin/vscode \
    \
    \
    \
    # 清理镜像，减少无用包
    && rm -rf /var/lib/apt/lists/* \
    && apt autoclean


# 域名
ENV DOMAIN vscode.storezhang.tech

# 监听地址
ENV HOST 0.0.0.0
# 监听端口
ENV PORT 8443

# 工作区
ENV WORKSPACE ${USER_HOME}/workspace
# 数据目录
ENV DATA_DIR ${USER_HOME}/data
# 插件目录
ENV EXTENSION_DIR ${USER_HOME}/extension

# 设置主目录权限
ENV SET_PERMISSIONS true

# 配置环境变量
# 配置Golang开发环境变量
ENV GOPROXY https://goproxy.io,https://goproxy.cn,https://mirrors.aliyun.com/goproxy,direct
