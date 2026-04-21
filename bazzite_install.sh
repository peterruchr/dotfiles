#!/bin/bash

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure Homebrew is available
if ! command -v brew &>/dev/null; then
  echo "ERROR: Homebrew not found. Please install it first: https://brew.sh"
  exit 1
fi

echo "==> Updating Homebrew"
brew update

echo "==> Installing packages from Brewfile"
brew bundle --file="$DOTFILES_DIR/Brewfile"

echo "==> Setting up git defaults"
git config --global core.editor nvim

# Install oh my zsh
echo "==> Installing oh my zsh"
if [ ! -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc --unattended
fi

# Do Stow commands
echo "==> Stowing dotfiles"
STOW_TARGETS="zsh nvim git starship tmux fzf"
# First we adopt anything that is already there, that means we create symlinks.
stow -v -t ~ --adopt -d "$DOTFILES_DIR" $STOW_TARGETS
# Now we run for everything that was not adopted
stow -v -R -t ~ -d "$DOTFILES_DIR" $STOW_TARGETS
# Now we reset the git repo, symlinks have been created and we now have our old dotfiles back.
git -C "$DOTFILES_DIR" reset --hard

# Change shell
# Since bazzite is an immutable system and zsh is installed via brew. Its not really part of the system. Thus a manual change is better where a custom command is set for the terminal. That way if zsh is uninstalled the entire computer will not break, but still use bash to login.
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

echo "Bootstrap complete."
echo "Restart your terminal or run: exec zsh"
echo "Note: Install OpenCode manually from https://opencode.ai"
