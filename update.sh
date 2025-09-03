#!/bin/bash
# =============================================================================
# Dotfiles アップデートスクリプト
# =============================================================================
# 説明: GitHubから取得したモジュールとツールの更新
# 使用方法: ./update.sh [--all] [--tools] [--plugins]
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
UPDATE_ALL=false
UPDATE_TOOLS=false
UPDATE_PLUGINS=false

# コマンドライン引数の解析
if [ $# -eq 0 ]; then
    UPDATE_ALL=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --all)
            UPDATE_ALL=true
            shift
            ;;
        --tools)
            UPDATE_TOOLS=true
            shift
            ;;
        --plugins)
            UPDATE_PLUGINS=true
            shift
            ;;
        -h|--help)
            echo "使用方法: $0 [オプション]"
            echo "オプション:"
            echo "  --all       すべてを更新（デフォルト）"
            echo "  --tools     開発ツールのみ更新"
            echo "  --plugins   Zshプラグインのみ更新"
            echo "  -h, --help  このヘルプを表示"
            exit 0
            ;;
        *)
            log_error "不明なオプション: $1"
            exit 1
            ;;
    esac
done

# すべて更新モードの場合
if [ "$UPDATE_ALL" = true ]; then
    UPDATE_TOOLS=true
    UPDATE_PLUGINS=true
fi

# GitHubから最新リリースバージョンを取得
get_latest_release() {
    local repo="$1"
    curl -s "https://api.github.com/repos/$repo/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'
}

# 現在インストールされているバージョンを取得
get_installed_version() {
    local tool="$1"
    case $tool in
        lsd)
            lsd --version 2>/dev/null | head -1 | cut -d' ' -f2
            ;;
        bat)
            batcat --version 2>/dev/null | head -1 | cut -d' ' -f2
            ;;
        rg)
            rg --version 2>/dev/null | head -1 | cut -d' ' -f2
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Zshプラグインの更新
update_plugins() {
    log_info "Zshプラグインを更新中..."
    
    # Zplug自体の更新
    if [ -d "$HOME/.zplug" ]; then
        log_info "Zplugを更新中..."
        cd "$HOME/.zplug"
        git pull origin main
        log_success "Zplug更新完了"
    fi
    
    # FZFの更新
    if [ -d "$HOME/.fzf" ]; then
        log_info "FZFを更新中..."
        cd "$HOME/.fzf"
        git pull origin main
        ./install --bin
        log_success "FZF更新完了"
    fi
    
    # Zplugでインストールされたプラグインの更新
    if command -v zplug &> /dev/null; then
        log_info "Zplugプラグインを更新中..."
        zsh -c "source ~/.zplug/init.zsh && zplug update"
        log_success "Zplugプラグイン更新完了"
    fi
}

# 開発ツールの更新
update_dev_tools() {
    log_info "開発ツールを更新中..."
    
    # pyenv
    if [ -d "$HOME/.pyenv" ]; then
        log_info "pyenvを更新中..."
        cd "$HOME/.pyenv"
        git pull origin main
        log_success "pyenv更新完了"
    fi
    
    # nvm
    if [ -d "$HOME/.nvm" ]; then
        log_info "nvmを更新中..."
        cd "$HOME/.nvm"
        git fetch --tags origin
        local latest_tag=$(git describe --abbrev=0 --tags)
        git checkout "$latest_tag"
        log_success "nvm更新完了 ($latest_tag)"
    fi
    
    # rbenv
    if [ -d "$HOME/.rbenv" ]; then
        log_info "rbenvを更新中..."
        cd "$HOME/.rbenv"
        git pull origin main
        
        # ruby-build
        if [ -d "$HOME/.rbenv/plugins/ruby-build" ]; then
            cd "$HOME/.rbenv/plugins/ruby-build"
            git pull origin main
        fi
        log_success "rbenv更新完了"
    fi
}

# モダンツールの更新
update_modern_tools() {
    log_info "モダンツールの更新確認中..."
    
    # lsd
    if command -v lsd &> /dev/null; then
        local installed_version=$(get_installed_version lsd)
        local latest_version=$(get_latest_release "lsd-rs/lsd")
        
        if [ "$installed_version" != "$latest_version" ]; then
            log_info "lsdを更新中 ($installed_version → $latest_version)..."
            local arch="x86_64-unknown-linux-gnu"
            local lsd_url="https://github.com/lsd-rs/lsd/releases/download/$latest_version/lsd-$latest_version-$arch.tar.gz"
            
            wget -O /tmp/lsd.tar.gz "$lsd_url"
            tar -xzf /tmp/lsd.tar.gz -C /tmp
            sudo cp "/tmp/lsd-$latest_version-$arch/lsd" /usr/local/bin/
            rm -rf /tmp/lsd.tar.gz "/tmp/lsd-$latest_version-$arch"
            log_success "lsd更新完了"
        else
            log_info "lsdは最新版です ($installed_version)"
        fi
    fi
    
    # bat
    if command -v batcat &> /dev/null; then
        local installed_version=$(get_installed_version bat)
        local latest_version=$(get_latest_release "sharkdp/bat")
        
        if [ "$installed_version" != "${latest_version#v}" ]; then
            log_info "batを更新中 ($installed_version → $latest_version)..."
            local bat_url="https://github.com/sharkdp/bat/releases/download/$latest_version/bat_${latest_version#v}_amd64.deb"
            
            wget -O /tmp/bat.deb "$bat_url"
            sudo dpkg -i /tmp/bat.deb || sudo apt-get install -f -y
            rm /tmp/bat.deb
            log_success "bat更新完了"
        else
            log_info "batは最新版です ($installed_version)"
        fi
    fi
    
    # ripgrep
    if command -v rg &> /dev/null; then
        local installed_version=$(get_installed_version rg)
        local latest_version=$(get_latest_release "BurntSushi/ripgrep")
        
        if [ "$installed_version" != "${latest_version#v}" ]; then
            log_info "ripgrepを更新中 ($installed_version → $latest_version)..."
            local rg_url="https://github.com/BurntSushi/ripgrep/releases/download/$latest_version/ripgrep_${latest_version#v}_amd64.deb"
            
            wget -O /tmp/ripgrep.deb "$rg_url"
            sudo dpkg -i /tmp/ripgrep.deb || sudo apt-get install -f -y
            rm /tmp/ripgrep.deb
            log_success "ripgrep更新完了"
        else
            log_info "ripgrepは最新版です ($installed_version)"
        fi
    fi
    
    # zoxide
    if command -v zoxide &> /dev/null; then
        log_info "zoxideを更新中..."
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        log_success "zoxide更新完了"
    fi
}

# メイン実行
main() {
    log_info "🚀 Dotfiles アップデートを開始します"
    
    # Dotfilesリポジトリ自体の更新
    log_info "Dotfilesリポジトリを更新中..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"
    git pull origin main
    log_success "Dotfilesリポジトリ更新完了"
    
    if [ "$UPDATE_PLUGINS" = true ]; then
        update_plugins
    fi
    
    if [ "$UPDATE_TOOLS" = true ]; then
        update_dev_tools
        update_modern_tools
    fi
    
    log_success "🎉 アップデートが完了しました！"
    log_info "変更を反映するには以下を実行してください:"
    log_info "source ~/.zshrc"
}

# スクリプト実行
main "$@"