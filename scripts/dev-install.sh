#!/usr/bin/env bash
set -Eeuo pipefail

if ((EUID == 0)); then
  echo 'Run this script as your normal user, not with sudo.' >&2
  exit 1
fi

if [[ ! -f /etc/os-release ]]; then
  echo 'Unable to identify the Linux distribution.' >&2
  exit 1
fi
# shellcheck disable=SC1091
source /etc/os-release
case "${ID:-}" in
  ubuntu | debian) ;;
  *)
    echo "This script supports Ubuntu and Debian (detected: ${ID:-unknown})." >&2
    exit 1
    ;;
esac

printf '\n==> Installing prerequisites (including bubblewrap for Codex sandboxing)\n'
sudo apt-get update
sudo apt-get install -y ca-certificates curl git bubblewrap tar gzip

printf '\n==> rustupでRustをインストールします\n'
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# shellcheck disable=SC1091
source "${CARGO_HOME:-$HOME/.cargo}/env"

printf '\n==> StyLuaをインストールします\n'
cargo install stylua

printf '\n==> Installing or updating lazygit\n'
LAZYGIT_VERSION=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest |
  sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
if [[ -z "$LAZYGIT_VERSION" ]]; then
  echo 'Unable to determine the latest lazygit version.' >&2
  exit 1
fi
LAZYGIT_ARCH=$(uname -m)
case "$LAZYGIT_ARCH" in
  aarch64) LAZYGIT_ARCH=arm64 ;;
esac
LAZYGIT_TEMP_DIR=$(mktemp -d)
trap 'rm -rf -- "$LAZYGIT_TEMP_DIR"' EXIT
curl -fsSL \
  "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz" \
  -o "$LAZYGIT_TEMP_DIR/lazygit.tar.gz"
tar -xzf "$LAZYGIT_TEMP_DIR/lazygit.tar.gz" -C "$LAZYGIT_TEMP_DIR" lazygit
sudo install -m 0755 "$LAZYGIT_TEMP_DIR/lazygit" /usr/local/bin/lazygit

# Installing Node via nvm keeps global npm packages in the user's home directory.
# This avoids sudo npm installs and allows switching Node versions per project.
NVM_VERSION='v0.40.8'
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
  if [[ -e "$NVM_DIR" ]]; then
    echo "Cannot install nvm: $NVM_DIR already exists but nvm.sh was not found." >&2
    exit 1
  fi
  printf '\n==> Installing nvm %s\n' "$NVM_VERSION"
  git clone --depth 1 --branch "$NVM_VERSION" \
    https://github.com/nvm-sh/nvm.git "$NVM_DIR"
fi

# Register nvm for future interactive Bash sessions; don't duplicate the block.
BASHRC="$HOME/.bashrc"
touch "$BASHRC"
if ! grep -Fq '# BEGIN install-node-codex nvm' "$BASHRC"; then
  cat >>"$BASHRC" <<'NVM_BASHRC'

# BEGIN install-node-codex nvm
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
# END install-node-codex nvm
NVM_BASHRC
fi

# nvm is a shell function, so load it in this process as well.
# shellcheck disable=SC1090
source "$NVM_DIR/nvm.sh"

printf '\n==> Installing the latest Node.js LTS (npm is bundled)\n'
nvm install --lts
nvm alias default 'lts/*'
nvm use default

printf '\n==> Installing or updating Codex CLI\n'
npm install --global @openai/codex

printf '\n==> Installing or updating Herdr\n'
curl -fsSL https://herdr.dev/install.sh | sh

if ! grep -Fq '# BEGIN dev-install herdr' "$BASHRC"; then
  cat >>"$BASHRC" <<'HERDR_BASHRC'

# BEGIN dev-install herdr
export PATH="${HERDR_INSTALL_DIR:-$HOME/.local/bin}:$PATH"
# END dev-install herdr
HERDR_BASHRC
fi
export PATH="${HERDR_INSTALL_DIR:-$HOME/.local/bin}:$PATH"

printf '\n==> Installed versions\n'
node --version
npm --version
codex --version
herdr --version
lazygit --version
rustc --version
cargo --version

printf '\nDone. Open a new terminal, then run: codex, herdr or lazygit\n'
printf 'To update Codex later: npm install -g @openai/codex\n'
printf 'To update Herdr later: herdr update\n'
printf 'Rustの更新: rustup update\n'
