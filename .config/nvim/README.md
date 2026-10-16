# Neovim 設定

初回起動時に lazy.nvim と依存プラグインをダウンロードします。
`lazy-lock.json` にプラグインのバージョンを記録しています。

このリポジトリの設定を使用するには次を実行します。
既存の `~/.config/nvim` がある場合は事前に退避してください。

```sh
mkdir -p ~/.config
ln -s ~/dotfiles/.config/nvim ~/.config/nvim
nvim
```

リポジトリを別の場所に配置した場合はリンク元を変更してください。

| キー | 操作 |
| --- | --- |
| Space e | ファイルツリーを開閉 |
| Ctrl f | ファイルツリーを開閉 |
| Space ff | ファイルを検索 |
| Space fg | ファイルの内容を検索 |
| Space fb | バッファを検索 |
| Space fh | ヘルプを検索 |
| Space f | バッファまたは選択範囲を整形 |
| Ctrl Space | 補完候補を表示 |
| Ctrl n / Ctrl p | 補完候補を選択 |
| Ctrl y | 補完を確定 |

Lua は StyLua、Shell は shfmt で保存時にも整形します。
`nvim .` などでディレクトリを開くと neo-tree を自動表示します。
全文検索には通常の端末の PATH から使える ripgrep が必要です。
LSP server はこの設定には含めていません。未設定の状態でもバッファ内の単語やパスの補完を使用できます。

依存関係は `:checkhealth lazy`、`:checkhealth telescope`、`:ConformInfo` で確認できます。

設定は [lazy.nvim](https://lazy.folke.io/installation)、[blink.cmp](https://cmp.saghen.dev/installation)、[Conform](https://github.com/stevearc/conform.nvim#setup) の公式ドキュメントに沿っています。
