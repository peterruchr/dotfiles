#!/bin/bash

set -e

echo "==> Updating system"
sudo apt update
sudo apt upgrade -y

echo "==> Installing core packages"
sudo apt install -y \
  build-essential \
  curl \
  wget \
  git \
  unzip \
  zip \
  ca-certificates \
  software-properties-common \
  xclip \
  stow \
  tmux \
  zsh \
  fzf \
  ripgrep \
  fd-find \
  bat \
  eza \
  jq \
  tree \

echo "==> Installing git extras"
sudo apt install -y gh

echo "==> Setting up git defaults"
git config --global core.editor nvim

echo "==> Setup Fd find"
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd

echo "==> Installing Neovim"

cd /usr/local/bin
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
# TODO PRETTY SURE THIS IS WRONG!
chmod +x nvim-linux-x86_64.appimage
ln -sf /usr/local/bin/nvim-linux-x86_64.appimage /usr/local/bin/nvim

# --- CLI aliases ---
echo "==> Changing default shell to zsh"
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# Do Stow commands

# Still missing a hell of a lot of stuff. 
echo "✅ Bootstrap complete."
echo "➡ Restart your terminal or run: exec zsh"
