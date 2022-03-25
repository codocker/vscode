ARG VSCODE_HOME=/opt/microsoft/vscode
ARG FONT_HOME=/opt/system/font



# 安装VSCode
FROM storezhang/ubuntu AS vscode


# VSCode版本
ENV VERSION 4.2.0
ENV OUTPUT_FILE vscode.tar.gz
ENV OUTPUT_FOLDER code-server-${VERSION}-linux-amd64
WORKDIR /opt


ARG VSCODE_HOME
RUN apt update -y
RUN apt install axel -y
RUN axel --insecure --num-connections=8 https://ghproxy.com/https://github.com/coder/code-server/releases/download/v${VERSION}/code-server-${VERSION}-linux-amd64.tar.gz --output ${OUTPUT_FILE}
RUN mkdir -p ${VSCODE_HOME}
# 去掉压缩包里面的顶层目录
RUN tar xf ${OUTPUT_FILE} --directory ${VSCODE_HOME} --strip-components 1



# 安装字体
FROM storezhang/ubuntu AS font


WORKDIR /opt


RUN apt update -y
RUN apt install axel -y
RUN axel --insecure --num-connections=8 https://ghproxy.com/https://github.com/powerline/powerline/raw/develop/font/PowerlineSymbols.otf --output ${FONT_HOME}/PowerlineSymbols.otf
RUN axel --insecure --num-connections=8 https://ghproxy.com/https://github.com/powerline/powerline/raw/develop/font/10-powerline-symbols.conf --output ${FONT_HOME}/10-powerline-symbols.conf





# 打包真正的镜像
# 之所以使用Ubuntu镜像而不是Alpine镜像，是因为在VSCode的使用过程中，会用到系统相关功能，而Ubuntu显然比Alpine在易用性上要好得多
FROM storezhang/ubuntu


LABEL author="storezhang<华寅>"
LABEL email="storezhang@gmail.com"
LABEL qq="160290688"
LABEL wechat="storezhang"
LABEL description="VSCode网页版本，在原来的功能上增加：1、中文支持；2、编译工具支持；3、解决权限问题；4、增加Z Shell并美化终端；5、Github加速"


# 用户密码
ENV USER_PASSWORD storezhang
# 访问密码
ENV PASSWORD storezhang

# 字体目录
ENV FONT_DIR /usr/local/share/fonts

# ZSH主目录
ENV OHMYZSH_HOME /opt/system/ohmyzsh
# ZSH安装环境
ENV OHMYZSH_PLUGINS ${OHMYZSH_HOME}/plugins
ENV OHMYZSH_THEMES ${OHMYZSH_HOME}/themes


# 复制文件
ARG VSCODE_HOME
ARG FONT_HOME
COPY --from=vscode ${VSCODE_HOME} ${VSCODE_HOME}
# 复制字体
COPY --from=font ${FONT_HOME} ${FONT_DIR}
COPY docker /


RUN set -ex \
    \
    \
    \
    && apt update -y \
    && apt upgrade -y \
    # 将用户可以使用最高权限
    && apt install sudo -y \
    # 允许用户可以切换成超级用户
    && adduser ${USERNAME} sudo \
    \
    \
    \
    # 安装Gcc，因为在后续过程中需要此工具来编译各种扩展
    && apt install gcc -y \
    # 安装版本控制软件
    && apt install git -y \
    \
    # 安装Z Shell并美化控制台
    && apt install zsh -y \
    # 安装辅助程序
    && apt install curl -y \
    && git clone https://ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git ${OHMYZSH_HOME} \
    && git clone https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions.git ${OHMYZSH_PLUGINS}/zsh-autosuggestions \
    && git clone https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${OHMYZSH_PLUGINS}/zsh-syntax-highlighting \
    && git clone https://ghproxy.com/https://github.com/romkatv/powerlevel10k.git ${OHMYZSH_THEMES}/powerlevel10k \
    && usermod --shell /bin/zsh ${USERNAME} \
    \
    \
    \
    # 安装字体
    && cd ${FONT_DIR} \
    # 生成核心字体信息
    && mkfontscale \
    # 生成字体文件夹
    && mkfontdir \
    # 刷新系统字体缓存
    && fc-cache -vf
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
    && apt autoremove -y \
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

# 安装目录
ENV VSCODE_HOME ${VSCODE_HOME}

# 配置环境变量
# 配置Golang开发环境变量
ENV GOPROXY https://goproxy.cn,https://mirrors.aliyun.com/goproxy,https://proxy.golang.com.cn,direct
