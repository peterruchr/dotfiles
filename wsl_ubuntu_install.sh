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
  tldr \
  tmux \
  zsh \
  ripgrep \
  fd-find \
  bat \
  eza \
  jq \
  tree \

# Install zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# Install fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
sudo ~/.fzf/install

echo "==> Installing git extras"
sudo apt install -y gh

echo "==> Setting up git defaults"
git config --global core.editor nvim

echo "==> Setup Fd find"
# Ubuntu has some weirdness here.
mkdir -p ~/.local/bin
ln -s $(which fdfind) ~/.local/bin/fd

echo "==> Setup bat"
ln -s /usr/bin/batcat ~/.local/bin/bat

# Install Neovim
echo "==> Installing Neovim"

cd /usr/local/bin
sudo curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
sudo chmod +x nvim-linux-x86_64.appimage
sudo ln -sf /usr/local/bin/nvim-linux-x86_64.appimage /usr/local/bin/nvim

# Install tree-sitter
sudo curl -LO https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-x64.gz
sudo gunzip tree-sitter-linux-x64.gz
sudo chmod +x tree-sitter-linux-x64
sudo ln -sf /usr/local/bin/tree-sitter-linux-x64 /usr/local/bin/tree-sitter

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
STOW_TARGETS="zsh nvim git starship tmux fzf"
# Okay so this is kinda tricky, first we adopt anything that is already there, that means we create symlins.
stow -v -t ~ --adopt $STOW_TARGETS
# Now we run for everything that was not adopted
stow -v -R -t ~ $STOW_TARGETS
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

# tmux plugin manager
echo "==> Installing TPM"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Still missing a hell of a lot of stuff. 
echo "✅ Bootstrap complete."
echo "➡ Restart your terminal or run: exec zsh"
