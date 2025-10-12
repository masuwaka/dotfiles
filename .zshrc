#!/usr/bin/env zsh
# =============================================================================
# Zsh 設定ファイル
# =============================================================================
# リポジトリ: https://github.com/masuwaka/dotfiles
# =============================================================================

# =============================================================================
# プラグインマネージャー (Zplug)
# =============================================================================
source ~/.zplug/init.zsh

# 必須プラグイン
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zplug/zplug", hook-build:'zplug --self-manage'
zplug "MichaelAquilina/zsh-you-should-use"
zplug "djui/alias-tips"
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
# 表示
setopt auto_menu             # タブで補完候補を表示
setopt auto_list             # 補完候補が複数の場合に一覧表示 
setopt list_packed            # 補完候補をできるだけ詰める
setopt print_eight_bit       # バイト文字をリテラル表示

# プッシュ
setopt auto_pushd            # ディレクトリ異動したらディレクトリスタックにプッシュ
setopt pushd_ignore_dups     # ディレクトリスタックに重複があれば古い方を削除

# 履歴
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history      # 実行時間も保存
setopt hist_ignore_all_dups  # コマンドを重複して保存しない
setopt hist_reduce_blanks    # 余計な空白は詰めて保存
setopt hist_ignore_dups      # 直前と同じコマンドは保存しない
setopt hist_save_no_dups     # 直前と同じコマンドは古い方を削除
setopt inc_append_history    # インクリメンタルに保存
setopt share_history         # 他のシェルと履歴をリアルタイム共有

# その他
setopt no_beep              # ビープ音を鳴らさない
setopt nolistbeep            # 補完候補表示時にもビープ音を鳴らさない

# =============================================================================
# 補完システム
# =============================================================================
autoload -Uz compinit && compinit -u

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
alias grep='grep --color=auto'

alias ls='lsd --icon-theme=unicode'
alias la='lsd -lah --icon-theme=unicode'

alias cat='bat'

# =============================================================================
# プロンプト設定
# =============================================================================
setopt prompt_subst
autoload -Uz colors && colors

YELLOW='%F{3}'
CYAN='%F{50}'
GREEN='%F{82}'
PINK='%F{213}'
PURPLE='%F{54}'
RESET='%f'
NL=$'\n'

precmd_python_venv(){
    PYTHON_VERSION_STRING=$(python -V | cut -f2 -d " ")
    if [[ -n $VIRTUAL_ENV ]]; then
        VENV=`basename $VIRTUAL_ENV`
        PROMPT="${NL}${YELLOW}[%~]${NL}${RESET}(${CYAN}$PYTHON_VERSION_STRING${RESET}:${CYAN}$VENV${RESET})${GREEN}%n${RESET}@${PINK}%m ${PURPLE}~>${RESET} "
    else
      PROMPT="${NL}${YELLOW}[%~]${NL}${RESET}(${CYAN}$PYTHON_VERSION_STRING${RESET})${GREEN}%n${RESET}@${PINK}%m ${PURPLE}~>${RESET} "
    fi
}

precmd(){
  precmd_python_venv
}

# =============================================================================
# peco
# =============================================================================
function peco-select-history() {
  BUFFER=$(\history -n -r 1 | peco --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history


# =============================================================================
# キーバインド (Emacs)
# =============================================================================
bindkey -e

# =============================================================================
# 開発環境
# =============================================================================
# CUDA
if [ -d "/usr/local/cuda" ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
fi

# =============================================================================
# 追加ツール
# =============================================================================
# mise
eval "$($HOME/.local/bin/mise activate zsh)"

# zoxide
eval "$(zoxide init zsh)"

# =============================================================================
# カスタム設定の読み込み（階層構造）
# =============================================================================
# 1. 組織・チーム共通設定（GitLab等で管理可能）
if [ -f "$HOME/.zshrc.custom" ]; then
    source "$HOME/.zshrc.custom"
fi

# 2. マシン固有設定（git管理対象外）
if [ -f "$HOME/.zshrc.local" ]; then
    source "$HOME/.zshrc.local"
fi
