#!/bin/bash
# =============================================================================
# Dotfiles セットアップスクリプト (Ubuntu専用)
# =============================================================================
# 説明: 必要なツールを自動でリポジトリ内にインストール・シンボリックリンク作成
# 使用方法: ./setup.sh [オプション]
# =============================================================================

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 変数初期化
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/tools"
INSTALL_ZPLUG=true
INSTALL_FZF=true
INSTALL_DEV_TOOLS=true

# Ubuntu 24.04以降のみサポート
if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
    log_error "このスクリプトはUbuntu専用です"
    exit 1
fi

UBUNTU_VERSION=$(lsb_release -rs 2>/dev/null)
if [ "$(echo "$UBUNTU_VERSION < 24.04" | bc)" -eq 1 ] 2>/dev/null; then
    log_warning "Ubuntu 24.04以降を推奨します (現在: $UBUNTU_VERSION)"
fi

# コマンドライン引数の解析
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-zplug)
            INSTALL_ZPLUG=false
            shift
            ;;
        --skip-fzf)
            INSTALL_FZF=false
            shift
            ;;
        --skip-dev-tools)
            INSTALL_DEV_TOOLS=false
            shift
            ;;
        -h|--help)
            echo "使用方法: $0 [オプション]"
            echo "オプション:"
            echo "  --skip-zplug            Zplugのインストールをスキップ"
            echo "  --skip-fzf              FZFのインストールをスキップ"
            echo "  --skip-dev-tools        開発ツールのインストール/リンクをスキップ"
            echo "  -h, --help              このヘルプを表示"
            exit 0
            ;;
        *)
            log_error "不明なオプション: $1"
            exit 1
            ;;
    esac
done

# GitHubから最新リリースバージョンを取得
get_latest_release() {
    local repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# 必要なパッケージのインストール
install_system_packages() {
    log_info "システムパッケージをインストール中..."
    
    sudo apt-get update
    sudo apt-get install -y \
        curl \
        wget \
        git \
        zsh \
        build-essential \
        libssl-dev \
        zlib1g-dev \
        libbz2-dev \
        libreadline-dev \
        libsqlite3-dev \
        libncursesw5-dev \
        xz-utils \
        tk-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libffi-dev \
        liblzma-dev
    
    log_success "システムパッケージのインストール完了"
}

# Zplugのインストール
install_zplug() {
    if [ "$INSTALL_ZPLUG" = false ]; then
        log_info "Zplugのインストールをスキップ"
        return
    fi
    
    # リポジトリ内にインストールしてシンボリックリンク作成
    if [ ! -d "$TOOLS_DIR/zplug" ]; then
        log_info "Zplugをインストール中..."
        git clone https://github.com/zplug/zplug "$TOOLS_DIR/zplug"
        log_success "Zplugのインストール完了"
    fi
    
    # シンボリックリンクの作成
    if [ -L "$HOME/.zplug" ]; then
        rm "$HOME/.zplug"
    elif [ -d "$HOME/.zplug" ]; then
        log_warning "既存の ~/.zplug をバックアップ中..."
        mv "$HOME/.zplug" "$HOME/.zplug.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$TOOLS_DIR/zplug" "$HOME/.zplug"
    log_success "Zplug シンボリックリンク作成完了"
}

# FZFのインストール
install_fzf() {
    if [ "$INSTALL_FZF" = false ]; then
        log_info "FZFのインストールをスキップ"
        return
    fi
    
    # リポジトリ内にインストールしてシンボリックリンク作成
    if [ ! -d "$TOOLS_DIR/fzf" ]; then
        log_info "FZFをインストール中..."
        git clone --depth 1 https://github.com/junegunn/fzf.git "$TOOLS_DIR/fzf"
        "$TOOLS_DIR/fzf/install" --all --no-bash --no-fish
        log_success "FZFのインストール完了"
    fi
    
    # シンボリックリンクの作成
    if [ -L "$HOME/.fzf" ]; then
        rm "$HOME/.fzf"
    elif [ -d "$HOME/.fzf" ]; then
        log_warning "既存の ~/.fzf をバックアップ中..."
        mv "$HOME/.fzf" "$HOME/.fzf.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    ln -sf "$TOOLS_DIR/fzf" "$HOME/.fzf"
    log_success "FZF シンボリックリンク作成完了"
}

# 開発ツールのセットアップ（リポジトリ内に統一配置）
setup_dev_tools() {
    if [ "$INSTALL_DEV_TOOLS" = false ]; then
        log_info "開発ツールのセットアップをスキップ"
        return
    fi
    
    log_info "開発ツールをリポジトリ内にセットアップ中..."
    mkdir -p "$TOOLS_DIR"
    
    install_dev_tools_to_repo
}

# 開発ツールをリポジトリ内にインストールしてシンボリックリンクを作成
install_dev_tools_to_repo() {
    # 既存ツールの処理を統一する関数
    setup_tool_symlink() {
        local tool_name="$1"
        local target_dir="$TOOLS_DIR/$tool_name"
        local home_link="$HOME/.$tool_name"
        
        if [ -d "$target_dir" ]; then
            if [ -L "$home_link" ]; then
                rm "$home_link"
            elif [ -d "$home_link" ]; then
                log_warning "既存の ~/.$tool_name をバックアップ中..."
                mv "$home_link" "$home_link.backup.$(date +%Y%m%d_%H%M%S)"
            fi
            ln -sf "$target_dir" "$home_link"
            log_success "$tool_name シンボリックリンク作成完了"
        fi
    }
    
    # pyenv (git clone)
    if [ ! -d "$TOOLS_DIR/pyenv" ]; then
        log_info "pyenv をインストール中..."
        git clone https://github.com/pyenv/pyenv.git "$TOOLS_DIR/pyenv"
        (cd "$TOOLS_DIR/pyenv" && src/configure && make -C src)
        log_success "pyenv インストール完了"
    fi
    setup_tool_symlink "pyenv"
    
    # nvm
    if [ ! -d "$TOOLS_DIR/nvm" ]; then
        log_info "nvm をインストール中..."
        local nvm_version=$(get_latest_release "nvm-sh/nvm")
        if [ -z "$nvm_version" ]; then
            nvm_version="v0.39.3"  # フォールバック
        fi
        git clone https://github.com/nvm-sh/nvm.git "$TOOLS_DIR/nvm"
        (cd "$TOOLS_DIR/nvm" && git checkout "$nvm_version")
        log_success "nvm ($nvm_version) インストール完了"
    fi
    setup_tool_symlink "nvm"
    
    # rbenv
    if [ ! -d "$TOOLS_DIR/rbenv" ]; then
        log_info "rbenv をインストール中..."
        git clone https://github.com/rbenv/rbenv.git "$TOOLS_DIR/rbenv"
        mkdir -p "$TOOLS_DIR/rbenv/plugins"
        git clone https://github.com/rbenv/ruby-build.git "$TOOLS_DIR/rbenv/plugins/ruby-build"
        log_success "rbenv インストール完了"
    fi
    setup_tool_symlink "rbenv"
    
    log_success "開発ツールのセットアップ完了"
}

# モダンツールのインストール（最新バージョンを自動取得）
install_modern_tools() {
    log_info "モダンツールをインストール中..."
    
    # lsd
    if ! command -v lsd &> /dev/null; then
        log_info "lsdをインストール中..."
        local lsd_version=$(get_latest_release "lsd-rs/lsd")
        if [ -n "$lsd_version" ]; then
            local arch="x86_64-unknown-linux-gnu"
            local lsd_url="https://github.com/lsd-rs/lsd/releases/download/$lsd_version/lsd-$lsd_version-$arch.tar.gz"
            
            wget -O /tmp/lsd.tar.gz "$lsd_url"
            tar -xzf /tmp/lsd.tar.gz -C /tmp
            sudo cp "/tmp/lsd-$lsd_version-$arch/lsd" /usr/local/bin/
            rm -rf /tmp/lsd.tar.gz "/tmp/lsd-$lsd_version-$arch"
            log_success "lsd ($lsd_version) インストール完了"
        else
            log_warning "lsdの最新バージョン取得に失敗"
        fi
    fi
    
    # bat
    if ! command -v bat &> /dev/null && ! command -v batcat &> /dev/null; then
        log_info "batをインストール中..."
        local bat_version=$(get_latest_release "sharkdp/bat")
        if [ -n "$bat_version" ]; then
            local bat_url="https://github.com/sharkdp/bat/releases/download/$bat_version/bat_${bat_version#v}_amd64.deb"
            
            wget -O /tmp/bat.deb "$bat_url"
            sudo dpkg -i /tmp/bat.deb || sudo apt-get install -f -y
            rm /tmp/bat.deb
            log_success "bat ($bat_version) インストール完了"
        else
            log_warning "batの最新バージョン取得に失敗"
        fi
    fi
    
    # ripgrep
    if ! command -v rg &> /dev/null; then
        log_info "ripgrepをインストール中..."
        local rg_version=$(get_latest_release "BurntSushi/ripgrep")
        if [ -n "$rg_version" ]; then
            local rg_url="https://github.com/BurntSushi/ripgrep/releases/download/$rg_version/ripgrep_${rg_version#v}_amd64.deb"
            
            wget -O /tmp/ripgrep.deb "$rg_url"
            sudo dpkg -i /tmp/ripgrep.deb || sudo apt-get install -f -y
            rm /tmp/ripgrep.deb
            log_success "ripgrep ($rg_version) インストール完了"
        else
            log_warning "ripgrepの最新バージョン取得に失敗"
        fi
    fi
    
    # zoxide
    if ! command -v zoxide &> /dev/null; then
        log_info "zoxideをインストール中..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log_success "zoxide インストール完了"
    fi
    
    log_success "モダンツールのインストール完了"
}

# .zshrcの設定
setup_zshrc() {
    log_info ".zshrc をセットアップ中..."
    
    # 既存の.zshrcをバックアップ
    if [ -f "$HOME/.zshrc" ] && [ ! -L "$HOME/.zshrc" ]; then
        log_warning "既存の ~/.zshrc をバックアップ中..."
        cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # シンボリックリンクを作成
    ln -sf "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
    log_success ".zshrc セットアップ完了"
}

# デフォルトシェルをzshに変更
change_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        log_info "デフォルトシェルをzshに変更しますか？ [Y/n]"
        read -r response
        if [[ ! "$response" =~ ^[Nn]$ ]]; then
            chsh -s "$(which zsh)"
            log_success "デフォルトシェルをzshに変更しました"
        fi
    fi
}

# メイン実行
main() {
    log_info "🚀 Dotfiles セットアップを開始します (Ubuntu専用)"
    log_info "スクリプトディレクトリ: $SCRIPT_DIR"
    log_info "開発ツール配置先: $TOOLS_DIR"
    
    # 既存インストールの確認と更新モード
    if [ -f "$HOME/.dotfiles-setup-completed" ]; then
        log_info "既存のセットアップを検出しました。更新を実行しますか？ [Y/n]"
        read -r response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            log_info "更新をキャンセルしました"
            exit 0
        fi
        log_info "更新モードで実行します..."
        # update.shを呼び出し
        if [ -f "$SCRIPT_DIR/update.sh" ]; then
            exec "$SCRIPT_DIR/update.sh" --all
        fi
    else
        # 実行前確認
        log_info "セットアップを開始しますか？ [Y/n]"
        read -r response
        if [[ "$response" =~ ^[Nn]$ ]]; then
            log_info "セットアップをキャンセルしました"
            exit 0
        fi
    fi
    
    install_system_packages
    install_zplug
    install_fzf
    setup_dev_tools
    install_modern_tools
    setup_zshrc
    change_default_shell
    
    # セットアップ完了マーカーファイルを作成
    touch "$HOME/.dotfiles-setup-completed"
    
    log_success "🎉 セットアップが完了しました！"
    log_info "新しいシェルを開くか、以下のコマンドを実行してください:"
    log_info "exec zsh"
    
    log_info ""
    log_info "📝 セットアップメモ:"
    log_info "  • 開発ツールはリポジトリ内 ($TOOLS_DIR) に配置されています"
    log_info "  • 他のマシンでも同じセットアップを実行してください: ./setup.sh"
    log_info "  • 初回のみ各ツールでバージョンをインストール:"
    log_info "    - pyenv install 3.11.0 && pyenv global 3.11.0"
    log_info "    - nvm install --lts"
    log_info "    - rbenv install 3.2.0 && rbenv global 3.2.0"
}

# スクリプト実行
main "$@"