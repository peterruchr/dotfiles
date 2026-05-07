#!/bin/bash
set -e

echo "==> Installerer værktøjer"
paru -S --needed --noconfirm \
  zsh stow tealdeer tmux ripgrep fd bat eza jq \
  nodejs npm github-cli neovim tree-sitter starship zoxide fzf

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

# Definer ZSH_CUSTOM korrekt
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
mkdir -p "$ZSH_CUSTOM/plugins"

echo "==> Opsætter Zsh plugins med KORREKTE stier"
# Rettede stier til zsh-users organisationen
[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] &&
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] &&
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "==> Opsætter Tmux Plugin Manager"
# Rettet sti til tmux-plugins organisationen
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  mkdir -p "$HOME/.tmux/plugins"
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo "==> Stowing dotfiles"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --target=$HOME (eller -t ~) sikrer, at stow linker til din home-mappe
# Sørg for at 'zsh', 'nvim' osv. er mapper direkte under $DOTFILES_DIR
stow -v -t "$HOME" --adopt -d "$DOTFILES_DIR" zsh nvim git starship tmux
git -C "$DOTFILES_DIR" reset --hard

echo "==> Skifter standard-shell"
if [[ "$SHELL" != *"zsh"* ]]; then
  sudo chsh -s "$(which zsh)" "$USER"
fi

echo "✅ Færdig!"
