# Dotfiles

Zsh設定ファイルと自動セットアップスクリプト

## 📁 構成

- `.zshrc` - Zsh設定ファイル（NFS環境自動検出対応）
- `setup.sh` - 自動セットアップスクリプト（Ubuntu 24.04+）

## 🚀 セットアップ

### 前提条件
- Ubuntu 24.04+
- sudo権限
- インターネット接続

### 自動セットアップ

```bash
git clone https://github.com/masuwaka/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

セットアップスクリプトが以下を自動実行:
- 必要なパッケージのインストール
- Zplug、FZF、開発ツール（pyenv、nvm、rbenv）のインストール
- モダンツール（lsd、bat、ripgrep、zoxide）の最新版インストール
- .zshrcのシンボリックリンク作成

### NFS共有環境での利用

開発ツールをNFSで共有する場合:

```bash
# 初回マシン（ツールをインストール）
./setup.sh --nfs-shared-tools ~/shared/devtools

# 他のマシン（既存ツールへリンク）
./setup.sh --nfs-shared-tools ~/shared/devtools

# 各マシンで初回のみ実行
pyenv install 3.11.0 && pyenv global 3.11.0
nvm install --lts
rbenv install 3.2.0 && rbenv global 3.2.0
```

## ✨ 特徴

### NFS環境対応
- 自動的にNFS環境を検出して最適化
- キャッシュと履歴をローカル配置（XDG_RUNTIME_DIR優先）
- 重いプラグインの自動無効化
- ファイルロック問題の回避

### 開発環境
- **Python**: pyenv + pyenv-update
- **Node.js**: nvm（LTS自動使用）
- **Ruby**: rbenv + ruby-build
- **CUDA**: 自動PATH設定

### モダンツール
- `lsd` - アイコン付きls
- `bat` - シンタックスハイライト付きcat
- `ripgrep` - 高速grep
- `zoxide` - スマートcd

### プラグイン
- zsh-completions - 補完強化
- zsh-autosuggestions - 自動提案
- zsh-syntax-highlighting - シンタックスハイライト
- zsh-history-substring-search - 部分文字列検索

## 🔧 カスタマイズ

### デバッグモード
```bash
export DOTFILES_DEBUG=1
source ~/.zshrc
```

### キーバインド
- `Ctrl+R` - FZF履歴検索
- `Ctrl+T` - FZFファイル検索
- `Alt+C` - FZFディレクトリ検索
- `Ctrl+X Ctrl+E` - エディタでコマンド編集

## 📝 ライセンス

MIT License