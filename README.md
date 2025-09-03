# Dotfiles

Zsh設定ファイルと自動セットアップスクリプト

## 📁 構成

- `.zshrc` - Zsh設定ファイル（NFS環境自動検出・自動更新機能付き）
- `.zshrc.local.example` - 環境固有設定のテンプレート
- `setup.sh` - 自動セットアップスクリプト（Ubuntu 24.04+）
- `update.sh` - 内部更新スクリプト（自動実行）
- `.gitignore` - ローカル設定ファイルを除外

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
- **Python**: pyenv（git管理）
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

## 🔄 自動更新

シェル起動時に1日1回自動で更新をチェックし、利用可能な場合は確認プロンプトを表示します。

手動で更新する場合：
```bash
cd ~/.dotfiles
git pull
./update.sh --all
```

## 🔧 カスタマイズ

### 環境固有設定
環境固有の設定（プロキシ、内部ツール、認証情報など）は `.zshrc.local` に記述：

```bash
cp ~/.dotfiles/.zshrc.local.example ~/.zshrc.local
vim ~/.zshrc.local  # 必要な設定を追加
```

`.zshrc.local` は git で管理されないため、機密情報も安全に記述できます。

### フォークして独自リポジトリで管理する場合

```bash
# 1. GitLab等でフォーク後、originを変更
git remote set-url origin https://gitlab.example.com/yourname/dotfiles.git

# 2. 元のリポジトリをupstreamとして追加
git remote add upstream https://github.com/masuwaka/dotfiles.git

# 3. 元のリポジトリの更新を取り込む
git fetch upstream
git merge upstream/master  # または rebase
git push origin master
```

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