#!/usr/bin/env bash
# Initial package setup for Ubuntu Desktop and Ubuntu on WSL.
# Usage: bash setup-ubuntu.sh [--desktop|--wsl|--cli] [--upgrade] [--dry-run]
set -Eeuo pipefail

MODE="auto"
UPGRADE=false
DRY_RUN=false

usage() {
  cat <<'USAGE'
Usage: bash setup-ubuntu.sh [OPTIONS]

Options:
  --desktop   Install common packages and Ubuntu Desktop extras.
  --wsl       Install common packages only (for WSL).
  --cli       Install common packages only (for servers/headless Ubuntu).
  --upgrade   Also upgrade already-installed APT packages.
  --dry-run   Show commands without changing the system.
  -h, --help  Show this help.

With no mode specified, WSL is detected first, then a graphical desktop.
USAGE
}

fail() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

while (($#)); do
  case "$1" in
    --desktop) MODE="desktop" ;;
    --wsl) MODE="wsl" ;;
    --cli) MODE="cli" ;;
    --upgrade) UPGRADE=true ;;
    --dry-run) DRY_RUN=true ;;
    -h | --help)
      usage
      exit 0
      ;;
    *) fail "Unknown option: $1" ;;
  esac
  shift
done

[[ -r /etc/os-release ]] || fail '/etc/os-release not found.'
# shellcheck source=/dev/null
source /etc/os-release
[[ "${ID:-}" == "ubuntu" ]] || fail 'This script is intended for Ubuntu (including Ubuntu on WSL).'
command -v apt-get >/dev/null || fail 'apt-get not found.'

is_wsl() {
  [[ -n "${WSL_DISTRO_NAME:-}" || -n "${WSL_INTEROP:-}" ]] ||
    grep -qEi 'microsoft|wsl' /proc/sys/kernel/osrelease /proc/version 2>/dev/null
}

has_desktop() {
  [[ -n "${XDG_CURRENT_DESKTOP:-}" || -n "${DESKTOP_SESSION:-}" ]] ||
    dpkg-query -W -f='${Status}' gnome-shell 2>/dev/null | grep -q 'install ok installed'
}

if [[ "$MODE" == "auto" ]]; then
  if is_wsl; then
    MODE="wsl"
  elif has_desktop; then
    MODE="desktop"
  else
    MODE="cli"
  fi
fi

if ((EUID == 0)); then
  ROOT=()
else
  command -v sudo >/dev/null || fail 'sudo is required for non-root users.'
  ROOT=(sudo)
fi

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
  if [[ "$DRY_RUN" == false ]]; then
    "$@"
  fi
}

# Installing an already-installed package is safe. Check availability so an
# optional package absent from an Ubuntu release does not abort all installs.
install_packages() {
  local pkg
  local -a available=()
  if [[ "$DRY_RUN" == true ]]; then
    run "${ROOT[@]}" apt-get install -y "$@"
    return
  fi
  for pkg in "$@"; do
    if apt-cache show "$pkg" >/dev/null 2>&1; then
      available+=("$pkg")
    else
      printf 'Warning: package unavailable (skipping): %s\n' "$pkg" >&2
    fi
  done
  if ((${#available[@]})); then
    run "${ROOT[@]}" apt-get install -y "${available[@]}"
  fi
}

COMMON_PACKAGES=(
  # Network, Git, SSH, archives
  ca-certificates curl wget git git-lfs openssh-client rsync unzip zip
  # Compilers and build tools
  build-essential pkg-config cmake ninja-build
  # Terminal utilities
  bash-completion less htop tree ripgrep fd-find fzf jq tmux shellcheck
  # Python development
  python3 python3-pip python3-venv python3-dev pipx
  # Libraries useful when building Python with pyenv
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev
  libffi-dev liblzma-dev libncurses-dev
  # Editor
  neovim
  latexmk
)

DESKTOP_PACKAGES=(
  # Japanese fonts and input; GNOME desktop preferences
  fonts-noto-cjk fonts-noto-color-emoji language-pack-ja ibus-mozc
  gnome-tweaks gnome-shell-extension-manager
  # Media and backup tools
  vlc deja-dup
)

printf 'Ubuntu: %s\nMode: %s\n' "${PRETTY_NAME:-${VERSION_ID:-unknown}}" "$MODE"
run "${ROOT[@]}" apt-get update
if [[ "$UPGRADE" == true ]]; then
  run "${ROOT[@]}" apt-get upgrade -y
fi
install_packages "${COMMON_PACKAGES[@]}"
if [[ "$MODE" == "desktop" ]]; then
  install_packages "${DESKTOP_PACKAGES[@]}"
else
  printf 'Skipping desktop-only packages (mode: %s).\n' "$MODE"
fi
printf 'Finished. No shell settings, repositories, or dotfiles were changed.\n'
