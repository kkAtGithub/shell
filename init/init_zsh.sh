#!/usr/bin/env bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# 检查是否为 root
if [ "$EUID" -ne 0 ]; then
    log_error "请用 root 或在命令前加 sudo 运行"
    exit 1
fi

# 获取实际用户信息
if [ -n "$SUDO_USER" ]; then
    REAL_USER="$SUDO_USER"
    REAL_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
    REAL_UID=$(id -u "$SUDO_USER")
    REAL_GID=$(id -g "$SUDO_USER")
else
    log_error "未检测到 SUDO_USER，请使用 sudo 运行此脚本"
    exit 1
fi

log_info "配置用户: $REAL_USER"
log_info "用户家目录: $REAL_HOME"

# 检测包管理器
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        echo "apt"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v yum >/dev/null 2>&1; then
        echo "yum"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then
        echo "zypper"
    else
        return 1
    fi
}

PM=$(detect_package_manager)
if [ -z "$PM" ]; then
    log_error "未检测到支持的包管理器 (apt/dnf/yum/pacman/zypper)"
    log_info "请手动安装: zsh git curl"
    exit 1
fi

log_info "使用 $PM 安装 zsh..."
case "$PM" in
    apt)
        apt update && apt install -y zsh git curl
        ;;
    dnf)
        dnf install -y zsh git curl
        ;;
    yum)
        yum install -y zsh git curl
        ;;
    pacman)
        pacman -Sy --noconfirm zsh git curl
        ;;
    zypper)
        zypper install -y zsh git curl
        ;;
esac

# 验证安装
if ! command -v zsh >/dev/null 2>&1; then
    log_error "zsh 安装失败"
    exit 1
fi

# 切换到用户权限执行的函数
run_as_user() {
    sudo -u "$REAL_USER" -H "$@"
}

# 设置 zsh 为默认 shell
ZSHPATH=$(command -v zsh)
if ! grep -q "$ZSHPATH" /etc/shells; then
    echo "$ZSHPATH" >> /etc/shells
    log_success "已添加 zsh 到 /etc/shells"
fi

if [ "$(getent passwd "$REAL_USER" | cut -d: -f7)" != "$ZSHPATH" ]; then
    chsh -s "$ZSHPATH" "$REAL_USER"
    log_success "已设置 zsh 为 $REAL_USER 的默认 shell"
else
    log_success "$REAL_USER 已使用 zsh 作为默认 shell"
fi

# 安装 zinit
ZINIT_HOME="${REAL_HOME}/.zinit/bin"
if [ ! -d "$ZINIT_HOME" ]; then
    log_info "安装 zinit..."
    run_as_user mkdir -p "$(dirname "$ZINIT_HOME")"
    run_as_user git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    log_success "zinit 安装完成"
else
    log_success "已存在 zinit，跳过克隆"
    # 更新 zinit
    log_info "更新 zinit..."
    run_as_user git -C "$ZINIT_HOME" pull
fi

# 初始化配置
ZSHRC="${REAL_HOME}/.zshrc"
if ! grep -q "zinit" "$ZSHRC" 2>/dev/null; then
    # 创建备份
    if [ -f "$ZSHRC" ]; then
        cp "$ZSHRC" "${ZSHRC}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "已备份原 .zshrc"
    fi
    
    # 添加配置
    cat <<'EOF' >> "$ZSHRC"

### >>> zinit 配置 >>>
# 检查并加载 zinit
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# 基础插件
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions

# 主题
zinit ice depth=1; zinit light romkatv/powerlevel10k

# 实用工具
zinit light zdharma-continuum/fast-syntax-highlighting
### <<< zinit 配置 <<<
EOF
    
    # 设置正确的所有权
    chown "$REAL_UID:$REAL_GID" "$ZSHRC"
    log_success "已写入基本 zinit 配置到 $ZSHRC"
else
    log_success "$ZSHRC 中已存在 zinit 配置，跳过修改"
fi

# 设置正确的权限
chown -R "$REAL_UID:$REAL_GID" "${REAL_HOME}/.zinit"

log_success "安装完成！"
log_info "请重新登录或运行以下命令进入新 shell:"
log_info "  exec zsh"
log_warning "首次启动可能需要一些时间来安装插件"
