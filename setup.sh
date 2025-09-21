#!/bin/zsh
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
    echo -e "${BLUE}ℹ️ $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# カレントディレクトリ
PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# zplug のインストール
install_zplug() {
    if [[ ! -e "$PWD/.zplug" ]]
    then
        log_info "zplug インストール中..."
        git clone https://github.com/zplug/zplug "$PWD/.zplug"
        log_success "zplug インストール完了"
    else
        log_success "zplug インストール済"
    fi

    if [ ! -L "$HOME/.zplug" ]
    then
        log_info "既存の $HOME/.zplug/ 削除中..."
        rm -fr "$HOME/.zplug"
        log_success "$HOME/.zplug/ 削除完了"
    fi

    log_info "zplug のシンボリックリンク作成中..."
    ln -fns "$PWD/.zplug" "$HOME/.zplug"
    log_success "zplug のシンボリックリンク作成完了"
}

# mise のインストール
install_mise() {

    if [[ ! -e "$PWD/.local/bin/mise" ]] 
    then
        log_info "mise インストール中..."
        rm -fr $HOME/.local
        curl https://mise.run | sh
        log_success "mise インストール完了"

        log_info "mise のシンボリックリンク化..."
        mv "$HOME/.local" "$PWD/"
        ln -fns "$PWD/.local" "$HOME/.local"
        log_success "zplug のシンボリックリンク化完了"
    else
        log_success "mise インストール済"
    fi


    log_info "mise のパッケージインストール中..."
    eval "$($HOME/.local/bin/mise activate zsh)"
    mise trust
    mise use -g python@latest
    mise use -g node@lts
    mise use -g pipx@latest
    mise use -g rust@stable
    mise use -g lsd@latest
    mise use -g bat@latest
    mise use -g peco@latest
    mise use -g zoxide@latest
    mise use -g npm:@anthropic-ai/claude-code@latest
    mise use -g pipx:SuperClaude@latest
    mise use -g pipx:bpytop@latest
    mise use -g pipx:huggingface_hub
    log_success "mise のパッケージインストール完了..."
}

make_links() {
    log_info ".dotfiles にシンボリック中..."
    for df in $(ls -d $HOME/.*)
    do
        if [[ ! -L "$df" ]]
        then
            bn="$(basename $df)"
            if [ "$bn" != ".gitconfig" ] && [ "$bn" != ".ssh" ] && [ "$bn" != ".dotfiles" ]
            then
                mv "$df" "$PWD/$bn"
                ln -fns "$PWD/$bn" "$df"
            fi
        fi
    done
    
    rm -fr $HOME/.zshrc $HOME/.zshrc.custom $HOME/.zshrc.local
    ln -fns $PWD/.zshrc $HOME/.zshrc 

    cp $PWD/.zshrc.custom.example $PWD/.zshrc.custom
    ln -fns $PWD/.zshrc.custom $HOME/.zshrc.custom 

    cp $PWD/.zshrc.local.example $PWD/.zshrc.local
    ln -fns $PWD/.zshrc.local $HOME/.zshrc.local 

    log_success ".dotfiles にシンボリックリンク完了"
}


# メイン実行
main() {
    log_info "🚀 Dotfiles セットアップを開始します"
    
    install_zplug
    install_mise
    make_links
    
    log_success "🎉 セットアップが完了しました！"
    log_info "新しいシェルを開くか、以下のコマンドを実行してください:"
    log_info "exec zsh"
}

# スクリプト実行
main "$@"