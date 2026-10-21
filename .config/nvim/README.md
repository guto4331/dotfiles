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

| キー            | 操作                         |
| --------------- | ---------------------------- |
| Space e         | ファイルツリーを開閉         |
| Ctrl f          | ファイルツリーを開閉         |
| Space ff        | ファイルを検索               |
| Space fg        | ファイルの内容を検索         |
| Space fb        | バッファを検索               |
| Space fh        | ヘルプを検索                 |
| Space f         | バッファまたは選択範囲を整形 |
| Ctrl Space      | 補完候補を表示               |
| Ctrl n / Ctrl p | 補完候補を選択               |
| Ctrl y          | 補完を確定                   |

Lua は StyLua、Shell は shfmt、TOML は Taplo で保存時にも整形します。
フォーマッタは Mason で管理します。初回起動時に `stylua`・`shfmt`・`taplo` を自動インストールします。
`:Mason` でインストール状態を確認できます。
今後フォーマッタを追加する場合は `lua/plugins/editor.lua` の `ensure_installed` と
Conform の `formatters_by_ft` に追加してください。
Mason の実行ファイルは Neovim 内の PATH に追加されます。
端末から直接実行する場合は `~/.local/share/nvim/mason/bin/taplo` などのパスを指定してください。
`nvim .` などでディレクトリを開くと neo-tree を自動表示します。
全文検索には通常の端末の PATH から使える ripgrep が必要です。
LSP server はこの設定には含めていません。未設定の状態でもバッファ内の単語やパスの補完を使用できます。

依存関係は `:checkhealth lazy`、`:checkhealth telescope`、`:ConformInfo` で確認できます。

設定は [lazy.nvim](https://lazy.folke.io/installation)、[blink.cmp](https://cmp.saghen.dev/installation)、[Conform](https://github.com/stevearc/conform.nvim#setup)、[Mason](https://github.com/mason-org/mason.nvim)、[mason-tool-installer](https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim) の公式ドキュメントに沿っています。

## Markdown

Markdown ファイルでは render-markdown.nvim が見出し・表・コードブロックなどを装飾します。
`:RenderMarkdown toggle` で装飾の表示を切り替えます。
必要な Tree-sitter parser は `markdown` と `markdown_inline` です。
この設定を確認した Neovim 0.12.6 には両方が含まれています。

[render-markdown.nvim の公式ドキュメント](https://github.com/MeanderingProgrammer/render-markdown.nvim) を参照しています。

## LaTeX

`.tex` ファイルでは VimTeX と英語のスペルチェックが有効になります。
日本語などの CJK 文字はスペルチェックの対象から除外します。
latexmk は `scripts/init-setup.sh` のインストール対象です。

保存すると latexmk の継続ビルドを開始し、成功後にシステムの既定の PDF viewer で PDF を開きます。
以降の保存では同じプロセスが再コンパイルします。
`:VimtexStop` で停止できますが、次の保存で再開します。

| キー        | 操作                             |
| ----------- | -------------------------------- |
| `\ll`       | latexmk の継続ビルドを開始・停止 |
| `\le`       | ビルドエラーを表示               |
| `\lv`       | PDF を開く                       |
| `\lt`       | 目次を表示                       |
| `]s` / `[s` | 次・前のスペル誤りへ移動         |
| `z=`        | 修正候補を表示                   |
| `zg`        | 単語を個人辞書に登録             |
| `zw`        | 単語を誤りとして登録             |

ビルドには TeX Live などの TeX 環境も必要です。
英文は既定の pdfLaTeX を使います。和文はメインファイルの先頭に LuaLaTeX の指定を書き、
`ltjsarticle` などの日本語対応クラスを使ってください。本文の言語による自動判定は行いません。

```tex
% !TeX program = lualatex
\documentclass{ltjsarticle}
\begin{document}
日本語の文書です。
\end{document}
```

コンパイラの指定を変更した場合は `:VimtexReload` で設定を読み直してから保存してください。
日本語のコンパイルには TeX Live の LuaLaTeX・LuaTeX-ja・日本語フォントも必要です。
PDF viewer を閉じた後にもう一度開く場合は `\lv` を使います。
`:VimtexInfo` でコンパイラと viewer の設定を確認できます。
スペルチェックは `:setlocal nospell` で無効にできます。

[VimTeX の公式ドキュメント](https://github.com/lervag/vimtex) と [Neovim のスペルチェック](https://neovim.io/doc/user/spell/) を参照しています。
