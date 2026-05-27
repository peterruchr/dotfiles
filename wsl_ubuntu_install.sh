#!/bin/bash

set -eu

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
  wslu

# Install Node.js (LTS via NodeSource)
echo "==> Installing Node.js LTS"
if ! command -v node &>/dev/null; then
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
  sudo apt install -y nodejs
fi

# Install zoxide
if ! command -v zoxide &>/dev/null; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# Install fzf
if [ ! -d "$HOME/.fzf" ]; then
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all --no-bash --no-fish
fi

echo "==> Installing git extras"
if ! command -v gh &>/dev/null; then
  sudo mkdir -p -m 755 /etc/apt/keyrings
  out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
  sudo apt update
  sudo apt install -y gh
fi

echo "==> Setting up git defaults"
git config --global core.editor nvim

echo "==> Setup Fd find"
# Ubuntu has some weirdness here.
mkdir -p ~/.local/bin
if [ ! -e ~/.local/bin/fd ]; then
  ln -s "$(which fdfind)" ~/.local/bin/fd
fi

echo "==> Setup bat"
if [ ! -e ~/.local/bin/bat ]; then
  ln -s /usr/bin/batcat ~/.local/bin/bat
fi

# Install Neovim
echo "==> Installing Neovim"
if [ ! -f /usr/local/bin/nvim-linux-x86_64.appimage ]; then
  sudo curl -LO --output-dir /usr/local/bin https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
  sudo chmod +x /usr/local/bin/nvim-linux-x86_64.appimage
fi
sudo ln -sf /usr/local/bin/nvim-linux-x86_64.appimage /usr/local/bin/nvim

# Install tree-sitter CLI
echo "==> Installing tree-sitter CLI"
if ! command -v tree-sitter &>/dev/null; then
  sudo npm install -g tree-sitter-cli
fi

# Install oh my zsh
echo "==> Installing oh my zsh"
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc --unattended
fi

# Install starship
echo "==> Installing Starship"
if ! command -v starship &>/dev/null; then
  curl -sS https://starship.rs/install.sh | sh -s -- --yes
fi

# Do Stow commands
echo "==> Stowing dotfiles"
DOTFILES_DIR="$(cd "$(dirname "$(realpath "$0")")" && pwd)"
cd "$DOTFILES_DIR"
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
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
  git clone https://github.com/zsh-users/zsh-completions "$ZSH_CUSTOM/plugins/zsh-completions"
fi

# tmux plugin manager
echo "==> Installing TPM"
if [ ! -d ~/.tmux/plugins/tpm ]; then
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Still missing a hell of a lot of stuff.
echo "✅ Bootstrap complete."
echo "➡ Restart your terminal or run: exec zsh"
