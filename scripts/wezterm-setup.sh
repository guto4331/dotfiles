#!/usr/bin/env bash
set -Eeuo pipefail

if ((EUID == 0)); then
  echo 'sudoを付けずに通常のユーザーで実行してください。' >&2
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo 'Linuxディストリビューションを判別できません。' >&2
  exit 1
fi
# shellcheck disable=SC1091
source /etc/os-release
case "${ID:-}" in
  ubuntu | debian) ;;
  *)
    echo "UbuntuとDebianに対応しています（検出: ${ID:-unknown}）。" >&2
    exit 1
    ;;
esac

printf '\n==> 依存パッケージをインストールします\n'
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

printf '\n==> WezTermのaptリポジトリを登録します\n'
sudo install -d -m 0755 /usr/share/keyrings
curl -fsSL https://apt.fury.io/wez/gpg.key |
  sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
sudo chmod 0644 /usr/share/keyrings/wezterm-fury.gpg
printf '%s\n' 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' |
  sudo tee /etc/apt/sources.list.d/wezterm.list >/dev/null
sudo chmod 0644 /etc/apt/sources.list.d/wezterm.list

printf '\n==> WezTerm nightlyをインストールまたは更新します\n'
sudo apt-get update
sudo apt-get install -y wezterm-nightly
wezterm --version
