# Dotfiles

個人用のシェル設定ファイルです。

## 📁 ファイル一覧

### `.zshrc`
生産性向上のためのZsh設定ファイル

**主な機能:**
- 🔌 **プラグイン管理** - Zplugによるモダンなプラグイン管理
- 🎨 **シンタックスハイライト** - コマンドの色付けと自動提案
- 📚 **履歴管理** - 高度な履歴検索と共有機能
- 🗂️ **ディレクトリナビゲーション** - スマートなディレクトリ移動
- ⌨️ **キーバインド** - Emacs風の便利なキーバインド
- 🎯 **FZF統合** - ファジーファインダーによる高速検索
- 🛠️ **開発環境** - Python(pyenv)、Node.js(nvm)、Ruby(rbenv)の自動設定

**含まれるプラグイン:**
- `zsh-users/zsh-completions` - 補完機能の拡張
- `zsh-users/zsh-autosuggestions` - Fish風の自動提案
- `zsh-users/zsh-syntax-highlighting` - シンタックスハイライト
- `zsh-users/zsh-history-substring-search` - 履歴の部分文字列検索
- `MichaelAquilina/zsh-you-should-use` - エイリアス使用の提案
- `djui/alias-tips` - エイリアスのヒント表示

## 🚀 セットアップ

### 前提条件
- Zsh
- Git
- [Zplug](https://github.com/zplug/zplug) (プラグイン管理)
- [FZF](https://github.com/junegunn/fzf) (ファジーファインダー)

### インストール

1. このリポジトリをクローン:
```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
```

2. 既存の設定ファイルをバックアップ:
```bash
cp ~/.zshrc ~/.zshrc.backup
```

3. 設定ファイルをシンボリックリンク:
```bash
ln -sf ~/.dotfiles/.zshrc ~/.zshrc
```

4. Zshを再起動してプラグインをインストール:
```bash
source ~/.zshrc
```

## ✨ 特徴

### 自動Node.js LTS使用
NVMが自動的にNode.jsの最新LTSバージョンを使用します。

### モダンツール対応
以下のツールが利用可能な場合、自動的に代替エイリアスを設定:
- `lsd` - アイコン付きls
- `bat`/`batcat` - シンタックスハイライト付きcat
- `ripgrep` - 高速grep
- `zoxide` - スマートcd

### 豊富なキーバインド
Emacs風のキーバインドで効率的なコマンドライン操作が可能:
- `Ctrl+R` - FZF履歴検索
- `Ctrl+T` - FZFファイル検索
- `Alt+C` - FZFディレクトリ検索

## 🔧 カスタマイズ

設定ファイルは明確にセクション分けされているため、必要な部分だけを編集できます:

- **プラグイン設定** - 使用するプラグインの追加・削除
- **エイリアス** - 個人的なコマンドエイリアス
- **プロンプト** - プロンプトの見た目とスタイル
- **キーバインド** - キーバインドのカスタマイズ

## 📝 ライセンス

MIT License

## 🤝 貢献

Issue や Pull Request をお待ちしています！