# dotfiles

Bash・WezTerm・Starship・Neovim・Codex の設定を管理します。
セットアップスクリプトで開発ツールのインストールと設定ファイルのリンクを行います。

## 管理する設定

| ファイル                                         | 設定内容                                                                                                                                                       |
| ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`.bashrc`](.bashrc)                             | Bash の履歴・補完・エイリアス、nvm・Rust の環境読み込み、Herdr の PATH、Starship の初期化を設定します。`pbcopy` は `xsel --clipboard --input` を呼び出します。 |
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
| [`scripts/wezterm-setup.sh`](scripts/wezterm-setup.sh) | WezTerm の apt リポジトリを登録して nightly 版をインストールします。Starship もインストールしリポジトリの `.bashrc` に初期化処理がなければ追加します。                                              |
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

### 設定ファイルの適用

リポジトリは `~/dotfiles` などホームディレクトリとは別のディレクトリに配置します。

```sh
bash scripts/link.sh
```

適用後は新しいターミナルを開いてください。Neovim の初回起動時にはプラグインと
Mason で管理するフォーマッタをダウンロードします。
WezTerm で指定するフォントは別途インストールしてください。
`.bashrc` は Starship と Rust の環境ファイルを読み込むため先に対応するツールをインストールします。
`pbcopy` を使用する場合は `xsel` も必要です。
