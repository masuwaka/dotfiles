#!/usr/bin/env zsh
# =============================================================================
# Zsh 設定ファイル
# =============================================================================
# 説明: 生産性向上のためのモダンツールを含むZsh設定
# リポジトリ: https://github.com/YOUR_USERNAME/dotfiles
# =============================================================================

# =============================================================================
# プラグインマネージャー (Zplug)
# =============================================================================
# Zplug - 次世代のZshプラグインマネージャー
source ~/.zplug/init.zsh

# -----------------------------------------------------------------------------
# 必須プラグイン
# -----------------------------------------------------------------------------
# 補完機能の強化
zplug "zsh-users/zsh-completions"              # 追加の補完定義
zplug "zsh-users/zsh-autosuggestions"          # Fish風の自動提案
zplug "zsh-users/zsh-syntax-highlighting", defer:2  # Fish風のシンタックスハイライト

# Zplugの自己管理
zplug "zplug/zplug", hook-build:'zplug --self-manage'

# -----------------------------------------------------------------------------
# 生産性向上プラグイン
# -----------------------------------------------------------------------------
# コマンド補助とヒント
zplug "MichaelAquilina/zsh-you-should-use"     # 利用可能なエイリアスを提案
zplug "zsh-users/zsh-history-substring-search" # 部分文字列による履歴検索
zplug "djui/alias-tips"                        # エイリアスのヒントを表示

# -----------------------------------------------------------------------------
# プラグインインストール確認
# -----------------------------------------------------------------------------
# 初回実行時に不足プラグインを自動インストール
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# 全プラグインの読み込み
zplug load

# =============================================================================
# 基本シェルオプション
# =============================================================================
setopt auto_list          # 曖昧な補完で自動的に選択肢を表示
setopt print_eight_bit    # 補完リストで8ビット文字をリテラル表示

# =============================================================================
# ディレクトリナビゲーション
# =============================================================================
# ディレクトリスタックを使った強化されたナビゲーション
setopt AUTO_PUSHD         # 自動的にディレクトリをスタックにプッシュ
setopt PUSHD_IGNORE_DUPS  # 重複するディレクトリをプッシュしない
setopt PUSHD_SILENT       # pushd/popdの後にスタックを表示しない
DIRSTACKSIZE=20          # ディレクトリスタックの最大サイズ

# ディレクトリナビゲーション用エイリアス
alias cd-='cd -'         # 前のディレクトリに戻る
alias dirs='dirs -v'     # 番号付きでディレクトリスタックを表示

# =============================================================================
# 履歴設定
# =============================================================================
# 履歴ファイルとサイズ設定
HISTFILE=$HOME/.zsh-history
HISTSIZE=100000          # メモリに保持するコマンド数
SAVEHIST=100000          # ファイルに保存するコマンド数

# 履歴の動作オプション
setopt EXTENDED_HISTORY        # コマンドのタイムスタンプを記録
setopt HIST_IGNORE_ALL_DUPS    # 新しいエントリが重複の場合、古いものを削除
setopt HIST_IGNORE_SPACE       # スペースで始まるコマンドを記録しない
setopt HIST_REDUCE_BLANKS      # 各コマンドから余分な空白を削除
setopt HIST_SAVE_NO_DUPS       # 重複エントリを履歴ファイルに書き込まない
setopt INC_APPEND_HISTORY      # コマンドを即座に追加（シェル終了時ではなく）
setopt SHARE_HISTORY           # 全セッション間で履歴を共有

# =============================================================================
# 補完システム
# =============================================================================
# 補完システムの初期化
autoload -Uz compinit
compinit

# 補完のスタイル設定
zstyle ':completion:*' menu select                           # 補完でメニュー選択
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'         # 大文字小文字を無視
zstyle ':completion:*' use-cache true                       # 補完キャッシュを使用
zstyle ':completion:*' cache-path ~/.zsh/cache              # キャッシュディレクトリ

# =============================================================================
# カラー設定
# =============================================================================
# BSD/macOS ls カラー
export LSCOLORS=cxfxcxdxbxegedabagacad
# GNU/Linux ls カラー
export LS_COLORS='di=1;36:ln=1;35:ex=1;32'

# =============================================================================
# エイリアス
# =============================================================================
# -----------------------------------------------------------------------------
# 基本コマンド
# -----------------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -la'
alias la='ls -a'
alias l='ls -CF'
alias grep='grep --color=auto'

# -----------------------------------------------------------------------------
# モダンツールの代替（利用可能な場合）
# -----------------------------------------------------------------------------
# lsd - アイコン付きのモダンなls
if command -v lsd &> /dev/null; then
    alias ls='lsd --icon-theme=unicode'
    alias ll='lsd -la --icon-theme=unicode'
    alias tree='lsd --tree --icon-theme=unico'
fi

# bat - シンタックスハイライト付きcat
if command -v batcat &> /dev/null; then
    alias cat='batcat --style=plain'
    alias ccat='batcat'
fi

# ripgrep - 高速なgrep
if command -v rg &> /dev/null; then
    alias grep='rg'
fi

# -----------------------------------------------------------------------------
# アプリケーションショートカット
# -----------------------------------------------------------------------------
# Claude CLI
alias claude="~/.claude/local/claude"

# =============================================================================
# プロンプト設定
# =============================================================================
# プロンプト置換とカラーを有効化
setopt prompt_subst
autoload -Uz colors && colors

# Python/仮想環境情報付きの動的プロンプト
precmd_conda(){
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

# プロンプト表示前に呼び出されるフック関数
precmd(){
  precmd_conda
}

# =============================================================================
# FZF - ファジーファインダー統合
# =============================================================================
# fzfを使ったカスタム履歴検索
function fzf-select-history() {
  BUFFER=$(\history -n -r 1 | fzf --query "$LBUFFER")
  CURSOR=$#BUFFER
  zle clear-screen
}
zle -N fzf-select-history
bindkey '^r' fzf-select-history

# fzfのキーバインドと補完を読み込み（Ctrl-T: ファイル、Alt-C: ディレクトリ）
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fzfの表示オプション
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --inline-info'

# =============================================================================
# キーバインド
# =============================================================================
# -----------------------------------------------------------------------------
# 履歴検索の強化
# -----------------------------------------------------------------------------
if zplug check "zsh-users/zsh-history-substring-search"; then
    bindkey '^[[A' history-substring-search-up    # 上矢印
    bindkey '^[[B' history-substring-search-down  # 下矢印
    bindkey '^P' history-substring-search-up      # Ctrl+P
    bindkey '^N' history-substring-search-down    # Ctrl+N
fi

# -----------------------------------------------------------------------------
# Emacsキーバインド
# -----------------------------------------------------------------------------
bindkey -e  # emacsキーバインドを使用

# 行内ナビゲーション
bindkey '^A' beginning-of-line    # Ctrl+A: 行の先頭に移動
bindkey '^E' end-of-line          # Ctrl+E: 行の末尾に移動
bindkey '^F' forward-char         # Ctrl+F: 一文字前進
bindkey '^B' backward-char        # Ctrl+B: 一文字後退

# 削除操作
bindkey '^D' delete-char          # Ctrl+D: カーソル下の文字を削除
bindkey '^H' backward-delete-char # Ctrl+H: カーソル前の文字を削除
bindkey '^K' kill-line            # Ctrl+K: カーソルから行末まで削除
bindkey '^U' backward-kill-line   # Ctrl+U: カーソルから行頭まで削除
bindkey '^W' backward-kill-word   # Ctrl+W: カーソル前の単語を削除
bindkey '\ed' kill-word           # Alt+D: カーソル後の単語を削除

# ヤンク（ペースト）操作
bindkey '^Y' yank                 # Ctrl+Y: 削除されたテキストをペースト
bindkey '\ey' yank-pop           # Alt+Y: キルリングを循環

# 単語単位ナビゲーション
bindkey '\ef' forward-word        # Alt+F: 一単語前進
bindkey '\eb' backward-word       # Alt+B: 一単語後退

# その他の操作
bindkey '^L' clear-screen         # Ctrl+L: 画面をクリア
bindkey '^G' send-break          # Ctrl+G: 現在のコマンドをキャンセル
bindkey '\e.' insert-last-word   # Alt+.: 前のコマンドの最後の単語を挿入

# コマンドライン編集
autoload -U edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line  # Ctrl+X Ctrl+E: $EDITORでコマンドを編集

# =============================================================================
# 開発環境セットアップ
# =============================================================================
# -----------------------------------------------------------------------------
# CUDAサポート
# -----------------------------------------------------------------------------
if [ -d "/usr/local/cuda" ]; then
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
fi

# -----------------------------------------------------------------------------
# Python環境 (pyenv)
# -----------------------------------------------------------------------------
if [ -d "$HOME/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# -----------------------------------------------------------------------------
# Node.js環境 (nvm)
# -----------------------------------------------------------------------------
# NVM - Node バージョンマネージャー
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    # 自動的にLTSバージョンのNode.jsを使用
    nvm use --lts --silent 2>/dev/null || nvm use --lts
fi

# -----------------------------------------------------------------------------
# Ruby環境 (rbenv)
# -----------------------------------------------------------------------------
if [ -d "$HOME/.rbenv" ]; then
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"
fi

# =============================================================================
# 追加ツール
# =============================================================================
# -----------------------------------------------------------------------------
# Zoxide - スマートなcdコマンド
# -----------------------------------------------------------------------------
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
    alias j='z'  # 高速ジャンプエイリアス
fi

# -----------------------------------------------------------------------------
# Claude CLI
# -----------------------------------------------------------------------------
if [ -f "$HOME/.claude/local/claude" ]; then
    alias claude="$HOME/.claude/local/claude"
fi

# =============================================================================
# PATH追加
# =============================================================================
# pipx バイナリ
export PATH="$PATH:$HOME/.local/bin"

# =============================================================================
# 設定終了
# =============================================================================