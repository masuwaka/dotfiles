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
- 🌐 **NFS対応** - NFSマウント環境での最適化とパフォーマンス向上

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

#### ローカル環境での使用

1. このリポジトリをクローン:
```bash
git clone https://github.com/masuwaka/dotfiles.git ~/.dotfiles
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

#### NFS共有環境での使用

NFSマウントされたホームディレクトリで使用する場合：

1. NFSマウントされた場所にリポジトリをクローン:
```bash
git clone https://github.com/masuwaka/dotfiles.git ~/shared/.dotfiles
```

2. 複数マシンでシンボリックリンクを作成:
```bash
ln -sf ~/shared/.dotfiles/.zshrc ~/.zshrc
```

3. NFS環境では自動的に軽量化モードが有効になり、以下が最適化されます:
   - 履歴ファイルが安全なローカル領域に配置（セッション識別子付き）
   - 補完キャッシュが適切な権限でローカルに配置
   - 重いプラグインが無効化
   - ファイルロック問題を回避

   **セキュリティ配慮**: 共用マシンでの安全性のため、以下の優先順位でローカル配置先を選択:
   1. `$XDG_RUNTIME_DIR` (systemd環境)
   2. `/tmp/$USER-zsh` (権限700で作成)
   3. `/var/tmp/$USER-zsh` (フォールバック)
   4. `$HOME/.zsh-local-cache` (最終フォールバック)

4. デバッグ情報を表示したい場合:
```bash
export DOTFILES_DEBUG=1
source ~/.zshrc
```

## ✨ 特徴

### 自動Node.js LTS使用
NVMが自動的にNode.jsの最新LTSバージョンを使用します。

### NFS環境対応
自動的にNFS環境を検出し、以下の最適化を実行:
- **安全なキャッシュ配置**: 適切な権限でローカル領域にキャッシュを配置
- **履歴ファイル最適化**: セッション識別子付きでI/O負荷軽減
- **プラグイン軽量化**: 重いプラグインを自動無効化
- **ロック回避**: NFSでのファイルロック問題を回避
- **共用マシン対応**: ユーザー専用ディレクトリで他ユーザーとの競合を回避

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