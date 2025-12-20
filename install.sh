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
  tree

echo "==> Installing git extras"
sudo apt install -y gh

echo "==> Setting up git defaults"
git config --global core.editor nvim

echo "==> Setup Fd find"
# Ubuntu has some weirdness here.
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd

# Install Neovim
echo "==> Installing Neovim"

cd /usr/local/bin
sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
sudo chmod +x nvim-linux-x86_64.appimage
sudo ln -sf /usr/local/bin/nvim-linux-x86_64.appimage /usr/local/bin/nvim

# Install oh my zsh
cd ~
echo "==> Installing oh my zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc --unattended

# Install starship
echo "==> Installing Starship"
curl -sS https://starship.rs/install.sh | sh

# Do Stow commands
echo "==> Stowing dotfiles"
cd dotfiles
# Okay so this is kinda tricky, first we adopt anything that is already there, that means we create symlins.
stow -v -t ~ --adopt zsh nvim git starship tmux 
# Now we run for everything that was not adopted
stow -v -R -t ~ zsh nvim git starship tmux
# Now we reset the git repo, symlinks has been created and we now have our old dotfiles back.
git reset --hard

# Change shell
echo "==> Changing default shell to zsh"
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

# Install zsh plugins
echo "==> Installing zsh plugings"
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# zsh-autosuggestions
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

# zsh-syntax-highlighting
[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# zsh-completions
[ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ] && \
git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"

# Still missing a hell of a lot of stuff. 
echo "✅ Bootstrap complete."
echo "➡ Restart your terminal or run: exec zsh"
