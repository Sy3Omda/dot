#!/usr/bin/env bash
# Run as your regular user: bash install.sh
# Keep this script, file.zshrc, and file.tmux.conf.local in the same directory.

set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
ZSHRC_SOURCE="$SCRIPT_DIR/file.zshrc"
TMUX_LOCAL_SOURCE="$SCRIPT_DIR/file.tmux.conf.local"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
BANNER_SOURCE="$SCRIPT_DIR/file.login-banner.sh"

require_file() {
  [[ -f "$1" ]] || { printf 'Required file not found: %s\n' "$1" >&2; exit 1; }
}

clone_if_missing() {
  local repository="$1" destination="$2"
  shift 2
  if [[ -e "$destination" && ! -d "$destination/.git" ]]; then
    printf 'Refusing to replace non-Git path: %s\n' "$destination" >&2
    exit 1
  fi
  if [[ ! -d "$destination/.git" ]]; then
    mkdir -p "$(dirname -- "$destination")"
    git clone "$@" "$repository" "$destination"
  fi
}

require_file "$ZSHRC_SOURCE"
require_file "$TMUX_LOCAL_SOURCE"
require_file "$BANNER_SOURCE"

sudo apt-get update
sudo apt-get install -y zsh git curl tmux fonts-powerline bat fzf fd-find tree net-tools

# eza is available in current Ubuntu/Debian repositories. Do not fail on older
# releases where it is not packaged.
if apt-cache show eza >/dev/null 2>&1; then
  sudo apt-get install -y eza
else
  printf 'Warning: package "eza" is unavailable in this APT release. Install eza separately; ~/.zshrc uses it.\n' >&2
fi

# Ubuntu/Debian package binaries can be named batcat and fdfind, but the
# supplied zshrc calls bat and fd. These user-local symlinks avoid editing it.
mkdir -p "$HOME/.local/bin"
if command -v batcat >/dev/null 2>&1; then
  ln -sfn "$(command -v batcat)" "$HOME/.local/bin/bat"
fi
if command -v fdfind >/dev/null 2>&1; then
  ln -sfn "$(command -v fdfind)" "$HOME/.local/bin/fd"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended
fi

clone_if_missing https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM_DIR/plugins/zsh-completions"
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM_DIR/themes/powerlevel10k" --depth=1
clone_if_missing https://github.com/gpakosz/.tmux.git "$HOME/.tmux" --single-branch

ln -sfn "$HOME/.tmux/.tmux.conf" "$HOME/.tmux.conf"

# Explicitly overwrite only the two requested dotfiles. No source dotfile is edited.
install -m 0644 "$ZSHRC_SOURCE" "$HOME/.zshrc"
install -m 0644 "$TMUX_LOCAL_SOURCE" "$HOME/.tmux.conf.local"

ZSH_PATH="$(command -v zsh)"
if ! grep -qxF "$ZSH_PATH" /etc/shells; then
  printf '%s\n' "$ZSH_PATH is not listed in /etc/shells; default shell was not changed." >&2
else
  chsh -s "$ZSH_PATH"
fi

sudo install -m 0644 "$BANNER_SOURCE" /etc/profile.d/00_lxc-details.sh

sudo mkdir -p /etc/zsh

ZSH_BANNER='[[ -r /etc/profile.d/00_lxc-details.sh ]] && source /etc/profile.d/00_lxc-details.sh'

sudo grep -qxF "$ZSH_BANNER" /etc/zsh/zprofile 2>/dev/null || \
    echo "$ZSH_BANNER" | sudo tee -a /etc/zsh/zprofile >/dev/null

printf '\nSetup complete. Restart the terminal or run: exec zsh\n'
