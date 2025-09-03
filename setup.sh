#!/bin/bash
# =============================================================================
# Dotfiles セットアップスクリプト (Ubuntu専用)
# =============================================================================
# 説明: 必要なツールの自動インストールとNFS環境対応
# 使用方法: ./setup.sh [--nfs-shared-tools /path/to/shared]
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
NFS_SHARED_TOOLS=""
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
        --nfs-shared-tools)
            NFS_SHARED_TOOLS="$2"
            shift 2
            ;;
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
            echo "  --nfs-shared-tools PATH  NFS共有された開発ツールのパス"
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
    
    # NFS環境ではシンボリックリンク
    if [ -n "$NFS_SHARED_TOOLS" ] && [ -d "$NFS_SHARED_TOOLS/zplug" ]; then
        if [ -L "$HOME/.zplug" ]; then
            rm "$HOME/.zplug"
        elif [ -d "$HOME/.zplug" ]; then
            mv "$HOME/.zplug" "$HOME/.zplug.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$NFS_SHARED_TOOLS/zplug" "$HOME/.zplug"
        log_success "Zplug シンボリックリンク作成完了"
        return
    fi
    
    # ローカルインストール
    if [ -d "$HOME/.zplug" ]; then
        log_info "Zplugは既にインストール済み"
        return
    fi
    
    log_info "Zplugをインストール中..."
    if [ -n "$NFS_SHARED_TOOLS" ]; then
        # NFS環境では共有ディレクトリにインストール
        export ZPLUG_HOME="$NFS_SHARED_TOOLS/zplug"
        curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
        ln -sf "$NFS_SHARED_TOOLS/zplug" "$HOME/.zplug"
    else
        curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
    fi
    log_success "Zplugのインストール完了"
}

# FZFのインストール
install_fzf() {
    if [ "$INSTALL_FZF" = false ]; then
        log_info "FZFのインストールをスキップ"
        return
    fi
    
    # NFS環境ではシンボリックリンク
    if [ -n "$NFS_SHARED_TOOLS" ] && [ -d "$NFS_SHARED_TOOLS/fzf" ]; then
        if [ -L "$HOME/.fzf" ]; then
            rm "$HOME/.fzf"
        elif [ -d "$HOME/.fzf" ]; then
            mv "$HOME/.fzf" "$HOME/.fzf.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$NFS_SHARED_TOOLS/fzf" "$HOME/.fzf"
        log_success "FZF シンボリックリンク作成完了"
        return
    fi
    
    if command -v fzf &> /dev/null; then
        log_info "FZFは既にインストール済み"
        return
    fi
    
    log_info "FZFをインストール中..."
    local fzf_dir="$HOME/.fzf"
    if [ -n "$NFS_SHARED_TOOLS" ]; then
        fzf_dir="$NFS_SHARED_TOOLS/fzf"
    fi
    
    if [ -d "$fzf_dir" ]; then
        rm -rf "$fzf_dir"
    fi
    
    git clone --depth 1 https://github.com/junegunn/fzf.git "$fzf_dir"
    "$fzf_dir/install" --all --no-bash --no-fish
    
    if [ -n "$NFS_SHARED_TOOLS" ]; then
        ln -sf "$NFS_SHARED_TOOLS/fzf" "$HOME/.fzf"
    fi
    
    log_success "FZFのインストール完了"
}

# 開発ツールのセットアップ（NFS共有またはローカルインストール）
setup_dev_tools() {
    if [ "$INSTALL_DEV_TOOLS" = false ]; then
        log_info "開発ツールのセットアップをスキップ"
        return
    fi
    
    if [ -n "$NFS_SHARED_TOOLS" ]; then
        setup_nfs_shared_tools
    else
        install_local_dev_tools
    fi
}

# NFS共有開発ツールのシンボリックリンクセットアップ
setup_nfs_shared_tools() {
    log_info "NFS共有開発ツールのシンボリックリンクをセットアップ中..."
    
    if [ ! -d "$NFS_SHARED_TOOLS" ]; then
        log_error "NFS共有ツールディレクトリが存在しません: $NFS_SHARED_TOOLS"
        return
    fi
    
    # pyenv
    if [ -d "$NFS_SHARED_TOOLS/pyenv" ]; then
        if [ -L "$HOME/.pyenv" ]; then
            rm "$HOME/.pyenv"
        elif [ -d "$HOME/.pyenv" ]; then
            log_warning "既存の ~/.pyenv をバックアップ中..."
            mv "$HOME/.pyenv" "$HOME/.pyenv.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$NFS_SHARED_TOOLS/pyenv" "$HOME/.pyenv"
        log_success "pyenv シンボリックリンク作成完了"
    else
        log_warning "$NFS_SHARED_TOOLS/pyenv が見つかりません"
    fi
    
    # nvm
    if [ -d "$NFS_SHARED_TOOLS/nvm" ]; then
        if [ -L "$HOME/.nvm" ]; then
            rm "$HOME/.nvm"
        elif [ -d "$HOME/.nvm" ]; then
            log_warning "既存の ~/.nvm をバックアップ中..."
            mv "$HOME/.nvm" "$HOME/.nvm.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$NFS_SHARED_TOOLS/nvm" "$HOME/.nvm"
        log_success "nvm シンボリックリンク作成完了"
    else
        log_warning "$NFS_SHARED_TOOLS/nvm が見つかりません"
    fi
    
    # rbenv
    if [ -d "$NFS_SHARED_TOOLS/rbenv" ]; then
        if [ -L "$HOME/.rbenv" ]; then
            rm "$HOME/.rbenv"
        elif [ -d "$HOME/.rbenv" ]; then
            log_warning "既存の ~/.rbenv をバックアップ中..."
            mv "$HOME/.rbenv" "$HOME/.rbenv.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$NFS_SHARED_TOOLS/rbenv" "$HOME/.rbenv"
        log_success "rbenv シンボリックリンク作成完了"
    else
        log_warning "$NFS_SHARED_TOOLS/rbenv が見つかりません"
    fi
    
    # Cargo/Rust
    if [ -d "$NFS_SHARED_TOOLS/cargo" ]; then
        if [ -L "$HOME/.cargo" ]; then
            rm "$HOME/.cargo"
        elif [ -d "$HOME/.cargo" ]; then
            log_warning "既存の ~/.cargo をバックアップ中..."
            mv "$HOME/.cargo" "$HOME/.cargo.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$NFS_SHARED_TOOLS/cargo" "$HOME/.cargo"
        log_success "cargo シンボリックリンク作成完了"
    else
        log_warning "$NFS_SHARED_TOOLS/cargo が見つかりません"
    fi
    
    # Rustup
    if [ -d "$NFS_SHARED_TOOLS/rustup" ]; then
        if [ -L "$HOME/.rustup" ]; then
            rm "$HOME/.rustup"
        elif [ -d "$HOME/.rustup" ]; then
            log_warning "既存の ~/.rustup をバックアップ中..."
            mv "$HOME/.rustup" "$HOME/.rustup.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        ln -sf "$NFS_SHARED_TOOLS/rustup" "$HOME/.rustup"
        log_success "rustup シンボリックリンク作成完了"
    fi
    
    log_success "NFS共有開発ツールのセットアップ完了"
}

# ローカル開発ツールのインストール
install_local_dev_tools() {
    log_info "ローカル開発ツールをインストール中..."
    
    # pyenv
    if [ ! -d "$HOME/.pyenv" ]; then
        log_info "pyenvをgit cloneでインストール中..."
        git clone https://github.com/pyenv/pyenv.git ~/.pyenv
        
        # pyenv-update plugin
        log_info "pyenv-updateプラグインをインストール中..."
        git clone https://github.com/pyenv/pyenv-update.git ~/.pyenv/plugins/pyenv-update
        
        log_success "pyenv インストール完了"
    else
        log_info "pyenvは既にインストール済み"
    fi
    
    # nvm
    if [ ! -d "$HOME/.nvm" ]; then
        log_info "nvmをインストール中..."
        local nvm_version=$(get_latest_release "nvm-sh/nvm")
        if [ -z "$nvm_version" ]; then
            nvm_version="v0.39.3"  # フォールバック
        fi
        curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$nvm_version/install.sh" | bash
        log_success "nvm ($nvm_version) インストール完了"
    else
        log_info "nvmは既にインストール済み"
    fi
    
    # rbenv
    if [ ! -d "$HOME/.rbenv" ]; then
        log_info "rbenvをgit cloneでインストール中..."
        git clone https://github.com/rbenv/rbenv.git ~/.rbenv
        git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
        log_success "rbenv インストール完了"
    else
        log_info "rbenvは既にインストール済み"
    fi
    
    log_success "ローカル開発ツールのインストール完了"
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
    
    if [ -n "$NFS_SHARED_TOOLS" ]; then
        log_info "NFS共有ツールパス: $NFS_SHARED_TOOLS"
    fi
    
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
    
    if [ -n "$NFS_SHARED_TOOLS" ]; then
        log_info ""
        log_info "📝 NFS共有環境のメモ:"
        log_info "  • 開発ツールは $NFS_SHARED_TOOLS からシンボリックリンクされています"
        log_info "  • 各マシンで同じセットアップスクリプトを実行してください"
        log_info "  • 初回は各ツールでバージョンのインストールが必要です:"
        log_info "    - pyenv install 3.11.0  # 例"
        log_info "    - nvm install --lts"
        log_info "    - rbenv install 3.2.0    # 例"
    fi
}

# スクリプト実行
main "$@"