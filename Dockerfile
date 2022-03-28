ARG VSCODE_HOME=/opt/microsoft/vscode
ARG FONT_HOME=/opt/system/font
ARG OHMYZSH_HOME=/opt/system/ohmyzsh



# 安装VSCode
FROM storezhang/ubuntu AS vscode


# 获取最新版本
ENV VERSION_URL https://api.github.com/repos/coder/code-server/releases/latest
ENV OUTPUT_FILE vscode.tar.gz
ENV OUTPUT_FOLDER code-server-linux-amd64
WORKDIR /opt


ARG VSCODE_HOME
RUN apt update -y
RUN apt install axel curl -y
RUN VERSION=$(curl -sX GET ${VERSION_URL} | awk '/tag_name/{print $4;exit}' FS='[""]' | sed 's|^v||') \
    && DOWNLOAD_URL=https://gh.wget.cool/https://github.com/coder/code-server/releases/download/v${VERSION}/code-server-${VERSION}-linux-amd64.tar.gz \
    && echo $DOWNLOAD_URL \
    && axel --insecure --num-connections=8 ${DOWNLOAD_URL} --output ${OUTPUT_FILE}
RUN mkdir -p ${VSCODE_HOME}
RUN tar xf ${OUTPUT_FILE} --directory ${VSCODE_HOME} --strip-components 1



# 安装字体
FROM storezhang/ubuntu AS font


WORKDIR /opt


# Jetbrains Mono字体版本
ENV NERD_FONTS_VERSION 2.1.0
ENV JETBRAINS_BIN_FILE jetbrans.zip


ARG FONT_HOME
RUN apt update -y
RUN apt install axel unzip -y
RUN mkdir -p ${FONT_HOME}

# Meslo Nerd字体
RUN axel --insecure --num-connections=8 https://gh.wget.cool/https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Regular.ttf --output "${FONT_HOME}/MesloLGS NF Regular.ttf"
RUN axel --insecure --num-connections=8 https://gh.wget.cool/https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold.ttf --output "${FONT_HOME}/MesloLGS NF Bold.ttf"
RUN axel --insecure --num-connections=8 https://gh.wget.cool/https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Italic.ttf --output "${FONT_HOME}/MesloLGS NF Italic.ttf"
RUN axel --insecure --num-connections=8 https://gh.wget.cool/https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/MesloLGS%20NF%20Bold%20Italic.ttf --output "${FONT_HOME}/MesloLGS NF Bold Italic.ttf"
# Jetbrains Mono字体
RUN axel --insecure --num-connections=8 https://gh.wget.cool/https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONTS_VERSION}/JetBrainsMono.zip --output ${JETBRAINS_BIN_FILE}
RUN unzip ${JETBRAINS_BIN_FILE} -d ${FONT_HOME}



# 安装Ohmyzsh
FROM storezhang/ubuntu AS ohmyzsh


WORKDIR /opt


ARG OHMYZSH_HOME
ENV OHMYZSH_PLUGINS ${OHMYZSH_HOME}/plugins
ENV OHMYZSH_THEMES ${OHMYZSH_HOME}/themes


RUN apt update -y
RUN apt install git libcurl4-openssl-dev -y
RUN git clone --depth=1 https://ghproxy.com/https://github.com/ohmyzsh/ohmyzsh.git ${OHMYZSH_HOME}
RUN git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-autosuggestions.git ${OHMYZSH_PLUGINS}/zsh-autosuggestions
RUN git clone --depth=1 https://ghproxy.com/https://github.com/zsh-users/zsh-syntax-highlighting.git ${OHMYZSH_PLUGINS}/zsh-syntax-highlighting
RUN git clone --depth=1 https://ghproxy.com/https://github.com/romkatv/powerlevel10k.git ${OHMYZSH_THEMES}/powerlevel10k





# 打包真正的镜像
# 之所以使用Ubuntu镜像而不是Alpine镜像，是因为在VSCode的使用过程中，会用到系统相关功能，而Ubuntu显然比Alpine在易用性上要好得多
FROM storezhang/ubuntu


LABEL author="storezhang<华寅>"
LABEL email="storezhang@gmail.com"
LABEL qq="160290688"
LABEL wechat="storezhang"
LABEL description="VSCode网页版本，在原来的功能上增加：1、中文支持；2、编译工具支持；3、解决权限问题；4、增加Z Shell并美化终端；5、Github加速；6、内置Docker功能"


# 用户密码
ENV USER_PASSWORD storezhang
# 访问密码
ENV PASSWORD storezhang

# 字体目录
ENV FONT_DIR /usr/local/share/fonts



# 复制文件
ARG VSCODE_HOME
ARG FONT_HOME
ARG OHMYZSH_HOME
# 复制VSCode
COPY --from=vscode ${VSCODE_HOME} ${VSCODE_HOME}
# 复制字体
COPY --from=font ${FONT_HOME} ${FONT_DIR}
# 复制Ohmyzsh
COPY --from=ohmyzsh ${OHMYZSH_HOME} ${OHMYZSH_HOME}
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
    \
    \
    # 安装其它开发必要组件
    # 安装基本编辑器，方便在控制台里面编辑文件
    && apt install nano -y \
    # 安装Docker
    && apt install docker.io -y \
    \
    \
    \
    # 安装ZSH并美化控制台
    && apt install zsh -y \
    # 安装辅助程序
    && apt install curl -y \
    # 修改用户终端
    && usermod --shell /bin/zsh ${USERNAME} \
    \
    \
    \
    # 增加执行权限
    && chmod +x /etc/s6/vscode/* \
    && chmod +x /usr/bin/vscode \
    && chmod +x /usr/bin/restart \
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

# Ohmyzsh安装目录
ENV OHMYZSH_HOME ${OHMYZSH_HOME}

# 配置环境变量
# 配置Golang开发环境变量
ENV GOPROXY https://goproxy.cn,https://mirrors.aliyun.com/goproxy,https://proxy.golang.com.cn,direct
ENV GO111MODULE on
