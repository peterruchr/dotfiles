#!/bin/bash

set -e

echo "==> Updating system"
sudo dnf upgrade -y

echo "==> Enabling RPM Fusion"
if ! rpm -q rpmfusion-free-release &>/dev/null; then
  sudo dnf install -y \
    "https://rpmfusion.org(rpm -E %fedora).noarch.rpm" \
    "https://rpmfusion.org(rpm -E %fedora).noarch.rpm"
fi

echo "==> Enabling Flathub repository"
flatpak remote-add --if-not-exists flathub https://flathub.org

echo "==> Installing core packages"
sudo dnf install -y \
  gcc \
  gcc-c++ \
  make \
  curl \
  wget \
  git \
  unzip \
  zip \
  ca-certificates \
  xclip \
  stow \
  tldr \
  tmux \
  zsh \
  ripgrep \
  fd-find \
  bat \
  eza \
  jq \
  tree \
  nodejs \
  npm \
  gh

echo "==> Installing codecs"
sudo dnf swap -y ffmpeg-free ffmpeg --allowerasing
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin

echo "==> Installing gaming packages (AMD Optimized)"
sudo dnf install -y \
  mesa-vulkan-drivers \
  mesa-vulkan-drivers.i686 \
  mesa-va-drivers \
  mesa-va-drivers.i686 \
  glibc.i686 \
  pipewire-alsa.i686

sudo dnf install -y \
  gamemode \
  gamescope \
  vulkan-tools

echo "==> Installing Apps via Flatpak"
flatpak install -y flathub \
  com.valvesoftware.Steam \
  com.heroicgameslauncher.hgl \
  net.lutris.Lutris \
  com.usebottles.bottles \
  com.github.Matoking.protontricks \
  com.discordapp.Discord \
  com.spotify.Client

# Install zoxide
if ! command -v zoxide &>/dev/null; then
  curl -sSfL https://githubusercontent.com | sh
fi

# Install fzf
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com ~/.fzf
  ~/.fzf/install --all
fi

echo "==> Setting up git defaults"
git config --global core.editor nvim

echo "==> Setup local bin"
mkdir -p ~/.local/bin

# Install Neovim
echo "==> Installing Neovim"
sudo mkdir -p /usr/local/bin
if [ ! -f /usr/local/bin/nvim-linux-x86_64.appimage ]; then
  sudo curl -L https://github.com -o /usr/local/bin/nvim-linux-x86_64.appimage
  sudo chmod +x /usr/local/bin/nvim-linux-x86_64.appimage
fi
sudo ln -sf /usr/local/bin/nvim-linux-x86_64.appimage /usr/local/bin/nvim

# Install tree-sitter
if [ ! -f /usr/local/bin/tree-sitter-linux-x64 ]; then
  sudo curl -L https://github.com -o /usr/local/bin/tree-sitter-linux-x64.gz
  sudo gunzip -f /usr/local/bin/tree-sitter-linux-x64.gz
  sudo chmod +x /usr/local/bin/tree-sitter-linux-x64
fi
sudo ln -sf /usr/local/bin/tree-sitter-linux-x64 /usr/local/bin/tree-sitter

# Install oh my zsh
echo "==> Installing oh my zsh"
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://githubusercontent.com)" "" --keep-zshrc --unattended
fi

# Install starship
echo "==> Installing Starship"
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs | sh -s -- -y
fi

# Do Stow commands
echo "==> Stowing dotfiles"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_TARGETS="zsh nvim git starship tmux fzf"
stow -v -t ~ --adopt -d "$DOTFILES_DIR" $STOW_TARGETS
stow -v -R -t ~ -d "$Dynamic_DIR" $STOW_TARGETS
git -C "$DOTFILES_DIR" reset --hard

# Change shell
echo "==> Changing default shell to zsh"
if [ "$SHELL" != "$(which zsh)" ]; then
  sudo chsh -s "$(which zsh)" "$USER"
fi

# Install zsh plugins
echo "==> Installing zsh plugins"
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] &&
  git clone https://github.com "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] &&
  git clone https://github.com "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] &&
  git clone https://github.com "$ZSH_CUSTOM/plugins/zsh-completions"

# tmux plugin manager
echo "==> Installing TPM"
[ ! -d ~/.tmux/plugins/tpm ] &&
  git clone https://github.com ~/.tmux/plugins/tpm

echo "✅ Bootstrap complete."
echo "➡ Restart your terminal or run: exec zsh"
