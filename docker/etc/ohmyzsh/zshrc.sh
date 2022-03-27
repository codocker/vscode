# 程序路径
export ZSH=${OHMYZSH_HOME}

# 随机主题范围
# shellcheck disable=SC2034
POWERLEVEL9K_MODE='nerdfont-complete'
# shellcheck disable=SC2034
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

# 使用随机主题
# shellcheck disable=SC2034
ZSH_THEME_RANDOM_CANDIDATES=("robbyrussell" "agnoster" "jonathan" "powerlevel10k/powerlevel10k")
# shellcheck disable=SC2034
ZSH_THEME="random"

# 区分大小定
# shellcheck disable=SC2034
# CASE_SENSITIVE="true"

# 不区分连字符的补全，区分大小写的完成必须关闭
# shellcheck disable=SC2034
HYPHEN_INSENSITIVE="true"

# 启动错误命令自动更正
# shellcheck disable=SC2034
ENABLE_CORRECTION="true"

# 在命令执行的过程中，使用小红点进行提示
# shellcheck disable=SC2034
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# 日期格式
# shellcheck disable=SC2034
HIST_STAMPS="yyyy-mm-dd"

# 自定义路径
# shellcheck disable=SC2034
ZSH_CUSTOM=${USER_HOME}/custom

# 启用已安装的插件
# shellcheck disable=SC2034
plugins=(
  git extract zsh-autosuggestions zsh-syntax-highlighting
)

# 配置ZSH启动文件
# shellcheck source=/dev/null
source "${ZSH}"/oh-my-zsh.sh

# 语言环境
export LANG=zh_CN.UTF-8

# 强制使用终端色彩
export TERM="xterm-256color"

# 命令别名
alias zshconfig="mate ~/.zshrc"
alias ohmyzsh="mate ~/.oh-my-zsh"

# 在这里设置环境变量
# export GOROOT=path-to-go
