# dotfiles

Bash・WezTerm・Starship・Neovim・Codex の設定を管理します。
セットアップスクリプトで開発ツールのインストールと設定ファイルのリンクを行います。

## 管理する設定

| ファイル                                         | 設定内容                                                                                                                                                       |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`.bashrc`](.bashrc)                             | Bash の履歴・補完・エイリアス、nvm・Rust の環境読み込み、Herdr の PATH、Starship の初期化を設定します。`pbcopy` はWSLで `clip.exe`、それ以外で `xsel --clipboard --input` を呼び出します。 |
| [`.wezterm.lua`](.wezterm.lua)                   | 配色に Tokyo Night、フォントに JetBrains Mono と Noto Sans Mono CJK JP を指定します。タブバーを非表示にします。                                                |
| [`.config/starship.toml`](.config/starship.toml) | プロンプトにユーザー名・ディレクトリ・Git のブランチと状態・言語のバージョン・時刻・コマンド実行時間を表示します。ユーザー名は常に表示します。                 |
| [`.config/nvim/`](.config/nvim/)                 | lazy.nvim でプラグインを管理します。Tokyo Night、ファイルツリー、ファイル検索、補完、保存時整形、LaTeX の編集を設定します。                                    |
| [`.codex/AGENTS.md`](.codex/AGENTS.md)           | Codex の回答言語・文章表現・コーディング・コミットのルールを指定します。                                                                                       |

Neovim のフォーマッタは Mason で管理します。StyLua・shfmt・Taplo を自動インストールし
Conform から Lua・Shell・TOML を保存時に整形します。
キー操作と LaTeX の設定は [Neovim の README](.config/nvim/README.md) に記載しています。

## セットアップスクリプト

リポジトリのルートで必要なスクリプトを `bash scripts/スクリプト名.sh` で実行します。
パッケージをインストールするスクリプトはネットワーク接続と sudo 権限を使用します。
`dev-install.sh` と `wezterm-setup.sh` は通常ユーザーで実行してください。

| スクリプト                                             | 処理内容                                                                                                                                                                                            |
| ------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`scripts/init-setup.sh`](scripts/init-setup.sh)       | Ubuntu 用の基本パッケージをインストールします。Git・ビルドツール・端末ツール・Python・Neovim・latexmk を含みます。Desktop モードでは日本語フォント・入力環境なども追加します。                      |
| [`scripts/dev-install.sh`](scripts/dev-install.sh)     | uv・Rust（rustup）・StyLua・lazygit・nvm・Node.js LTS・Codex CLI・Herdr をインストールします。Bash に nvm と Herdr の設定を追加します。StyLua は現在このスクリプトでも `cargo install` しています。 |
| [`scripts/wezterm-setup.sh`](scripts/wezterm-setup.sh) | WSL以外ではWezTerm の apt リポジトリを登録して nightly 版をインストールします。各環境でStarship もインストールしリポジトリの `.bashrc` に初期化処理がなければ追加します。                                              |
| [`scripts/font-install.sh`](scripts/font-install.sh)   | 入力した ZIP ファイル名を使い `~/Downloads` から `~/.fonts/ZIPファイル名（拡張子なし）` にフォントを展開します。`unzip` が必要です。                                                                |
| [`scripts/link.sh`](scripts/link.sh)                   | `.config` 内の各ファイルと `.bashrc`・`.wezterm.lua`・`.codex/AGENTS.md` のシンボリックリンクをホームディレクトリに作成します。既存ファイルは `~/.dotfiles-backup.XXXXXXXX` に退避します。          |

### 基本パッケージのインストール

`init-setup.sh` は Ubuntu 向けです。モード未指定時は WSL・Desktop・CLI を自動判定します。
`dev-install.sh` と `wezterm-setup.sh` は Ubuntu と Debian に対応しています。

```sh
bash scripts/init-setup.sh --dry-run
bash scripts/init-setup.sh
bash scripts/dev-install.sh
bash scripts/wezterm-setup.sh
```

`init-setup.sh` は `--desktop`・`--wsl`・`--cli` でモードを指定できます。
`--upgrade` を付けるとインストール済みの apt パッケージも更新します。

### WSL2でのセットアップ

Windows側でWezTermを実行し、Bash・Starship・Neovim・開発ツールはWSLのUbuntu側に配置します。

WSLが未導入の場合は管理者のPowerShellで次を実行してWindowsを再起動します。
Ubuntuの初回起動時にLinuxユーザーを作成してください。
既存のWSL環境では `wsl --list --verbose` のVERSIONが `2` であることを確認します。
VERSIONが `1` の場合は `wsl --set-version Ubuntu 2` で変換します。
`Ubuntu` は一覧に表示されたディストリビューション名に置き換えてください。
[Microsoftのインストール手順](https://learn.microsoft.com/en-us/windows/wsl/install)を参照してください。

```powershell
wsl --install -d Ubuntu
```

Windows側のPowerShellでWezTermをインストールします。
[WezTerm公式のWindows向け手順](https://wezterm.org/install/windows.html)に従います。
JetBrains MonoとNoto Sans Mono CJK JPもWindows側にインストールしてください。
`scripts/font-install.sh` はLinux側へのインストール用です。

```powershell
winget install --id wez.wezterm --exact
```

以降はWSLのUbuntu内で通常ユーザーとして実行します。
リポジトリと開発ファイルは `~/dotfiles` などLinux側に配置します。
MicrosoftもLinuxツールで扱うファイルは[Linuxファイルシステムへの配置](https://learn.microsoft.com/en-us/windows/wsl/filesystems)を推奨しています。

```sh
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/guto4331/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash scripts/init-setup.sh --wsl --dry-run
bash scripts/init-setup.sh --wsl
bash scripts/dev-install.sh
bash scripts/wezterm-setup.sh
bash scripts/link.sh
```

すでにクローン済みなら `git clone` を省略してください。
`wezterm-setup.sh` はWSLではLinux版WezTermのインストールを省略してStarshipをインストールします。

WSL内で次を実行してWindowsのエクスプローラーからリポジトリを開きます。

```sh
explorer.exe .
```

`.wezterm.lua` をWindows側の `%USERPROFILE%\.wezterm.lua` にコピーします。
既存の設定がある場合はコピー前に退避してください。
`link.sh` が作るWSLホーム内のリンクだけではWindows版WezTermには適用されません。
設定を更新した場合はWindows側にも再コピーしてください。

Windows版WezTermは `wsl.exe --cd ~` で既定のディストリビューションを起動します。
複数のディストリビューションがある場合はPowerShellで `wsl --set-default Ubuntu` を実行します。
配色・フォント・スクロール設定はUbuntuと共用します。
起動コマンドにはWezTermの [`default_prog`](https://wezterm.org/config/lua/config/default_prog.html) を使用します。

新しいWezTermを開いて `node --version`、`starship --version`、`nvim --version` を確認します。
`printf 'test' | pbcopy` を実行するとWindowsのクリップボードへコピーできます。
WSLのWindows実行ファイル連携とWindows PATHの引き継ぎを有効にしておく必要があります。
[`clip.exe` による連携](https://learn.microsoft.com/en-us/windows/wsl/filesystems)はMicrosoftの手順に従います。

### 設定ファイルの適用

リポジトリは `~/dotfiles` などホームディレクトリとは別のディレクトリに配置します。

```sh
bash scripts/link.sh
```

適用後は新しいターミナルを開いてください。Neovim の初回起動時にはプラグインと
Mason で管理するフォーマッタをダウンロードします。
WezTerm で指定するフォントは別途インストールしてください。
`.bashrc` は Starship と Rust の環境ファイルを読み込むため先に対応するツールをインストールします。
ネイティブUbuntuで `pbcopy` を使用する場合は `xsel` も必要です。
