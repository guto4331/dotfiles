#!/usr/bin/env bash
set -Eeuo pipefail

DOTFILES_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
HOME_DIR=$(cd -- "$HOME" && pwd)

if [[ "$DOTFILES_DIR" == "$HOME_DIR" ]]; then
  echo 'dotfilesはホームディレクトリとは別のディレクトリに配置してください。' >&2
  exit 1
fi

for required_file in .codex/AGENTS.md .bashrc .profile .wezterm.lua; do
  if [[ ! -f "$DOTFILES_DIR/$required_file" ]]; then
    printf 'リンク元がありません: %s\n' "$DOTFILES_DIR/$required_file" >&2
    exit 1
  fi
done
if [[ ! -d "$DOTFILES_DIR/.config" ]]; then
  printf 'リンク元がありません: %s/.config\n' "$DOTFILES_DIR" >&2
  exit 1
fi

mapfile -d '' -t CONFIG_FILES < <(find "$DOTFILES_DIR/.config" -type f -print0)
SOURCE_FILES=("${CONFIG_FILES[@]}" "$DOTFILES_DIR/.codex/AGENTS.md" "$DOTFILES_DIR/.bashrc" "$DOTFILES_DIR/.profile" "$DOTFILES_DIR/.wezterm.lua")
BACKUP_DIR=''

for source_file in "${SOURCE_FILES[@]}"; do
  relative_path=${source_file#"$DOTFILES_DIR/"}
  target_file="$HOME_DIR/$relative_path"

  if [[ "$source_file" -ef "$target_file" ]]; then
    continue
  fi

  if [[ -L "$target_file" ]] && [[ "$(readlink -- "$target_file")" == "$source_file" ]]; then
    continue
  fi

  if [[ -e "$target_file" || -L "$target_file" ]]; then
    if [[ -z "$BACKUP_DIR" ]]; then
      BACKUP_DIR=$(mktemp -d "$HOME_DIR/.dotfiles-backup.XXXXXXXX")
      printf '既存ファイルの保存先: %s\n' "$BACKUP_DIR"
    fi
    backup_file="$BACKUP_DIR/$relative_path"
    mkdir -p -- "$(dirname -- "$backup_file")"
    mv -- "$target_file" "$backup_file"
  fi

  mkdir -p -- "$(dirname -- "$target_file")"
  ln -s -- "$source_file" "$target_file"
  printf 'リンクを作成しました: %s -> %s\n' "$target_file" "$source_file"
done
