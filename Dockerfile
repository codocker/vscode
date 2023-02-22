FROM codercom/code-server:4.10.0 AS vscode
FROM storezhang/ohmyzsh:0.0.3 AS ohmyzsh
FROM storezhang/font:0.0.7 AS font





# 打包真正的镜像
# 之所以使用Ubuntu镜像而不是Alpine镜像，是因为在VSCode的使用过程中，会用到系统相关功能，而Ubuntu显然比Alpine在易用性上要好得多
FROM storezhang/ubuntu:23.04.17


LABEL author="storezhang<华寅>"
LABEL email="storezhang@gmail.com"
LABEL qq="160290688"
LABEL wechat="storezhang"
LABEL description="VSCode网页版本，在原来的功能上增加：1、中文支持；2、编译工具支持；3、解决权限问题；4、增加Z Shell并美化终端；5、Github加速；6、内置Docker功能"


# 用户密码
ENV USER_PASSWORD storezhang
# 访问密码
ENV PASSWORD storezhang

# 程序安装目录
ENV VSCODE_HOME /usr/lib/code-server
# 字体目录
ENV FONT_HOME /usr/lib/font
ENV FONT_DIR /usr/local/share/fonts
# Zsh目录
ENV OHMYZSH_HOME=/usr/lib/ohmyzsh


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
  && apt install git libcurl4-openssl-dev -y \
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
  && chmod +x /etc/ohmyzsh/* \
  \
  && chmod +x /usr/bin/vscode \
  && chmod +x /usr/bin/restart \
  && chmod +x /usr/bin/gmcc \
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
ENV GO111MODULE on
ENV GOPROXY https://goproxy.io,https://goproxy.cn,https://mirrors.aliyun.com/goproxy,direct

# 系统环境变量
ENV PATH ${PATH}:${VSCODE_HOME}/bin
