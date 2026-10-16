#!/usr/bin/env bash
(
  set -Eeuo pipefail

  read -r -p 'Downloads直下のZIPファイル名を入力してください: ' filename
  if [[ -z "$filename" || "$filename" == */* || "$filename" != *.[zZ][iI][pP] ]]; then
    echo '拡張子.zipを含むファイル名を入力してください。パスは指定できません。' >&2
    exit 1
  fi

  archive_path="$HOME/Downloads/$filename"
  if [[ ! -f "$archive_path" ]]; then
    printf 'ファイルが見つかりません: %s\n' "$archive_path" >&2
    exit 1
  fi

  destination_directory="$HOME/.fonts/${filename%.*}"
  mkdir -p -- "$destination_directory"
  unzip "$archive_path" -d "$destination_directory"
)
