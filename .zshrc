#!/usr/bin/env zsh
# =============================================================================
# Zsh 設定ファイル
# =============================================================================
# リポジトリ: https://github.com/masuwaka/dotfiles
# =============================================================================

# =============================================================================
# 環境検出とNFS対応
# =============================================================================
DOTFILES_ON_NFS=false
if [ -n "$HOME" ] && command -v stat &> /dev/null; then
    if stat -f -c %T "$HOME" 2>/dev/null | grep -q nfs || \
       df -T "$HOME" 2>/dev/null | grep -q nfs; then
        DOTFILES_ON_NFS=true
    fi
fi

# NFS環境での最適化設定
if [ "$DOTFILES_ON_NFS" = true ]; then
    LOCAL_CACHE_BASE=""
    
    # 安全なローカルディレクトリの選択
    if [ -n "$XDG_RUNTIME_DIR" ] && [ -d "$XDG_RUNTIME_DIR" ] && [ -w "$XDG_RUNTIME_DIR" ]; then
        LOCAL_CACHE_BASE="$XDG_RUNTIME_DIR"
    elif [ -d "/tmp" ] && [ -w "/tmp" ]; then
        LOCAL_CACHE_BASE="/tmp/$USER-zsh"
        mkdir -p "$LOCAL_CACHE_BASE" && chmod 700 "$LOCAL_CACHE_BASE" 2>/dev/null
    elif [ -d "/var/tmp" ] && [ -w "/var/tmp" ]; then
        LOCAL_CACHE_BASE="/var/tmp/$USER-zsh"
        mkdir -p "$LOCAL_CACHE_BASE" && chmod 700 "$LOCAL_CACHE_BASE" 2>/dev/null
    else
        LOCAL_CACHE_BASE="$HOME/.zsh-local-cache"
        mkdir -p "$LOCAL_CACHE_BASE" && chmod 700 "$LOCAL_CACHE_BASE" 2>/dev/null
    fi
    
    export ZSH_CACHE_DIR="$LOCAL_CACHE_BASE/cache"
    mkdir -p "$ZSH_CACHE_DIR" && chmod 700 "$ZSH_CACHE_DIR" 2>/dev/null
    export HISTFILE="$LOCAL_CACHE_BASE/history-$$"
    setopt NO_HIST_FCNTL_LOCK
    export DOTFILES_LIGHTWEIGHT_MODE=true
else
    export ZSH_CACHE_DIR="$HOME/.zsh/cache"
    mkdir -p "$ZSH_CACHE_DIR"
    export HISTFILE="$HOME/.zsh-history"
    export DOTFILES_LIGHTWEIGHT_MODE=false
fi

# =============================================================================
# プラグインマネージャー (Zplug)
# =============================================================================
source ~/.zplug/init.zsh

# 必須プラグイン
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zplug/zplug", hook-build:'zplug --self-manage'

# 生産性向上プラグイン（NFS環境では軽量化）
if [ "$DOTFILES_LIGHTWEIGHT_MODE" != "true" ]; then
    zplug "MichaelAquilina/zsh-you-should-use"
    zplug "djui/alias-tips"
fi
zplug "zsh-users/zsh-history-substring-search"

# プラグインインストール確認
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

# =============================================================================
# 基本設定
# =============================================================================
setopt auto_list          # 曖昧な補完で自動的に選択肢を表示
setopt print_eight_bit    # 8ビット文字をリテラル表示

# ディレクトリナビゲーション
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
DIRSTACKSIZE=20

alias cd-='cd -'
alias dirs='dirs -v'

# 履歴設定
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# =============================================================================
# 補完システム
# =============================================================================
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache true
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"

# =============================================================================
# カラー設定
# =============================================================================
export LSCOLORS=cxfxcxdxbxegedabagacad
export LS_COLORS='di=1;36:ln=1;35:ex=1;32'

# =============================================================================
# エイリアス
# =============================================================================
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -a'
alias l='ls -CF'
alias grep='grep --color=auto'

# モダンツール（存在すれば）
if command -v lsd &> /dev/null; then
    alias ls='lsd --icon-theme=unicode'
    alias ll='lsd -la --icon-theme=unicode'
    alias tree='lsd --tree --icon-theme=unicode'
fi

if command -v batcat &> /dev/null; then
    alias cat='batcat --style=plain'
    alias ccat='batcat'
fi

if command -v rg &> /dev/null; then
    alias grep='rg'
fi


# =============================================================================
# プロンプト設定
# =============================================================================
setopt prompt_subst
autoload -Uz colors && colors

precmd_python_venv(){
  if command -v pyenv &> /dev/null; then
    PYTHON_VERSION_STRING=$(pyenv version-name)
    if [[ -n $VIRTUAL_ENV ]]; then
      VENV=`basename $VIRTUAL_ENV`
      PROMPT="%F{226}[%~]%f"$'\n'"(%F{123}$PYTHON_VERSION_STRING:$VENV%f)%F{002}%n%f@%F{207}%m%f %F{047}~>%f "
    else
      PROMPT="%F{226}[%~]%f"$'\n'"(%F{123}$PYTHON_VERSION_STRING%f)%F{002}%n%f@%F{207}%m%f %F{047}~>%f "
    fi
  else
    PROMPT="%F{226}[%~]%f"$'\n'"%F{002}%n%f@%F{207}%m%f %F{047}~>%f "
  fi
}

precmd(){
  precmd_python_venv
}

# =============================================================================
# FZF統合
# =============================================================================
function fzf-select-history() {
  BUFFER=$(\history -n -r 1 | fzf --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

# =============================================================================
# キーバインド
# =============================================================================
# 履歴検索
if zplug check "zsh-users/zsh-history-substring-search"; then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^P' history-substring-search-up
    bindkey '^N' history-substring-search-down
fi

# Emacsキーバインド
bindkey -e
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^F' forward-char
bindkey '^B' backward-char
bindkey '^D' delete-char
bindkey '^H' backward-delete-char
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word
bindkey '\ed' kill-word
bindkey '^Y' yank
bindkey '\ey' yank-pop
bindkey '\ef' forward-word
bindkey '\eb' backward-word
bindkey '^L' clear-screen
bindkey '^G' send-break
bindkey '\e.' insert-last-word

autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# =============================================================================
# 開発環境
# =============================================================================
# CUDA
if [ -d "/usr/local/cuda" ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
fi

# pyenv
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# nvm
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    nvm use --lts --silent 2>/dev/null || nvm use --lts
fi

# rbenv
if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# =============================================================================
# 追加ツール
# =============================================================================
# zoxide
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias j='z'
fi

# Claude CLI
if [ -f "$HOME/.claude/local/claude" ]; then
    alias claude="$HOME/.claude/local/claude"
fi

# PATH追加
export PATH="$PATH:$HOME/.local/bin"

# =============================================================================
# デバッグ情報（必要時のみ）
# =============================================================================
if [ "$DOTFILES_ON_NFS" = true ] && [ -n "$DOTFILES_DEBUG" ]; then
    echo "🔧 NFS環境で動作中 - 軽量化モード有効"
    echo "   履歴ファイル: $HISTFILE"
    echo "   キャッシュディレクトリ: $ZSH_CACHE_DIR"
    echo "   ローカルキャッシュベース: $LOCAL_CACHE_BASE"
    echo "   セッションPID: $$"
fi