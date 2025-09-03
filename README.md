# Dotfiles

Zsh設定ファイルと自動セットアップスクリプト

## 📁 構成

- `.zshrc` - Zsh設定ファイル（NFS環境自動検出・自動更新機能付き）
- `.zshrc.custom.example` - 組織・チーム共通設定のテンプレート
- `.zshrc.local.example` - マシン固有設定のテンプレート
- `setup.sh` - 自動セットアップスクリプト（Ubuntu 24.04+）
- `update.sh` - 内部更新スクリプト（自動実行）
- `.gitignore` - 設定ファイルの管理方針

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

### セットアップ手順

どの環境でも同じ手順で実行:

```bash
# 初回セットアップ
./setup.sh

# 各マシンで初回のみ実行
pyenv install 3.11.0 && pyenv global 3.11.0
nvm install --lts
rbenv install 3.2.0 && rbenv global 3.2.0
```

## ✨ 特徴

### 統一されたポータブル設計
- 開発ツールを全てdotfilesリポジトリ内に配置
- HOMEディレクトリにはシンボリックリンクを作成
- NFS環境を自動検出して最適化（キャッシュ・履歴のローカル配置）
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

### 設定の階層化

3段階の設定階層で柔軟な管理が可能：

#### 1. 組織・チーム共通設定（GitLab等で管理）
```bash
cp ~/.dotfiles/.zshrc.custom.example ~/.zshrc.custom
vim ~/.zshrc.custom  # プロキシ、内部ツール等
```

#### 2. マシン固有設定（git管理対象外）
```bash
cp ~/.dotfiles/.zshrc.local.example ~/.zshrc.local
vim ~/.zshrc.local  # マシンごとの個別設定
```

#### 読み込み順序
1. `.zshrc`（基本設定）
2. `.zshrc.custom`（組織共通、GitLab管理可能）
3. `.zshrc.local`（マシン固有、git除外）

#### Git設定の管理
設定階層でGit設定も管理可能：

**組織共通（.zshrc.custom）**:
```bash
# 組織用のGit設定
git config --global user.name "Work Name"
git config --global user.email "work@company.com"
git config --global http.proxy "http://proxy:8080"
```

**マシン固有（.zshrc.local）**:
```bash
# 個人用Git設定（自宅マシンなど）
git config --global user.name "Personal Name"  
git config --global user.email "personal@gmail.com"
```

### クローンして組織リポジトリで管理する場合

```bash
# 1. GitLab等でクローン後、originを変更
git clone https://github.com/masuwaka/dotfiles.git
cd dotfiles
git remote set-url origin https://gitlab.internal/yourorg/dotfiles.git

# 2. 元のリポジトリをupstreamとして追加
git remote add upstream https://github.com/masuwaka/dotfiles.git

# 3. .zshrc.custom を組織用に設定
cp .zshrc.custom.example .zshrc.custom
# 組織共通設定を記述

# 4. .gitignore を調整（.zshrc.custom をgit管理対象に）
vim .gitignore  # .zshrc.customの行をコメントアウト

# 5. コミットしてpush
git add .zshrc.custom .gitignore
git commit -m "Add organization-specific settings"
git push origin main

# 6. upstream更新の取り込み
git fetch upstream
git merge upstream/main
git push origin main
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