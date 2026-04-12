#!/bin/bash

set -e

echo "==> Updating system"
sudo dnf upgrade -y

echo "==> Enabling RPM Fusion"
if ! rpm -q rpmfusion-free-release &>/dev/null; then
  sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"
fi

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
sudo dnf groupupdate -y multimedia

echo "==> Installing gaming packages"
sudo dnf install -y \
  steam \
  mesa-vulkan-drivers \
  mesa-vulkan-drivers.i686 \
  vulkan-tools \
  libva-mesa-driver \
  mesa-vdpau-drivers \
  gamemode \
  mangohud \
  lutris \
  gamescope \
  wine \
  winetricks \
  protontricks

# Install Heroic Games Launcher
echo "==> Installing Heroic Games Launcher"
HEROIC_VERSION=$(curl -s https://api.github.com/repos/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | tr -d 'v')
if ! rpm -q heroic-games-launcher-bin &>/dev/null; then
  sudo dnf install -y "https://github.com/Heroic-Games-Launcher/HeroicGamesLauncher/releases/latest/download/Heroic-${HEROIC_VERSION}-linux-x86_64.rpm"
fi

# Install Discord
echo "==> Installing Discord"
if ! rpm -q discord &>/dev/null; then
  sudo dnf install -y "https://discord.com/api/download?platform=linux&format=rpm"
fi

# Install Spotify
echo "==> Installing Spotify"
if ! rpm -q spotify-client &>/dev/null; then
  sudo dnf config-manager --add-repo https://negativo17.org/repos/fedora-spotify.repo
  sudo dnf install -y spotify-client
fi

# Install zoxide
if ! command -v zoxide &>/dev/null; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Install fzf
if [ ! -d ~/.fzf ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --all
fi

echo "==> Setting up git defaults"
git config --global core.editor nvim

echo "==> Setup local bin"
mkdir -p ~/.local/bin

# Install Neovim
echo "==> Installing Neovim"
if [ ! -f /usr/local/bin/nvim-linux-x86_64.appimage ]; then
  sudo curl -LO --output-dir /usr/local/bin https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
  sudo chmod +x /usr/local/bin/nvim-linux-x86_64.appimage
fi
sudo ln -sf /usr/local/bin/nvim-linux-x86_64.appimage /usr/local/bin/nvim

# Install tree-sitter
if [ ! -f /usr/local/bin/tree-sitter-linux-x64 ]; then
  sudo curl -LO --output-dir /usr/local/bin https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
  sudo gunzip /usr/local/bin/tree-sitter-linux-x64.gz
  sudo chmod +x /usr/local/bin/tree-sitter-linux-x64
fi
sudo ln -sf /usr/local/bin/tree-sitter-linux-x64 /usr/local/bin/tree-sitter

# Install oh my zsh
echo "==> Installing oh my zsh"
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc --unattended
fi

# Install starship
echo "==> Installing Starship"
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh
fi

# Do Stow commands
echo "==> Stowing dotfiles"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STOW_TARGETS="zsh nvim git starship tmux fzf"
# Okay so this is kinda tricky, first we adopt anything that is already there, that means we create symlinks.
stow -v -t ~ --adopt -d "$DOTFILES_DIR" $STOW_TARGETS
# Now we run for everything that was not adopted
stow -v -R -t ~ -d "$DOTFILES_DIR" $STOW_TARGETS
# Now we reset the git repo, symlinks has been created and we now have our old dotfiles back.
git -C "$DOTFILES_DIR" reset --hard

# Change shell
echo "==> Changing default shell to zsh"
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# Install zsh plugins
echo "==> Installing zsh plugins"
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# zsh-autosuggestions
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] &&
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] &&
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# zsh-completions
[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] &&
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"

# tmux plugin manager
echo "==> Installing TPM"
[ ! -d ~/.tmux/plugins/tpm ] &&
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "✅ Bootstrap complete."
echo "➡ Restart your terminal or run: exec zsh"
