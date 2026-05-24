FROM archlinux:latest

# 1. Opdater og installer alle dine værktøjer
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    zsh stow tealdeer tmux ripgrep fd bat eza jq \
    nodejs npm github-cli neovim tree-sitter-cli starship zoxide fzf git curl

# 2. Hent Oh My Zsh og plugins direkte ind i /etc/skel (0% interaktivt, ingen hængende scripts)
RUN git clone https://github.com/ohmyzsh/ohmyzsh /etc/skel/.oh-my-zsh && \
    git clone https://github.com/zsh-users/zsh-autosuggestions /etc/skel/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting /etc/skel/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# 3. Kopier din standardskabelon for .zshrc, som Oh My Zsh bruger
RUN cp /etc/skel/.oh-my-zsh/templates/zshrc.zsh-template /etc/skel/.zshrc

# 4. Konfigurer din .zshrc direkte i /etc/skel med dine plugins, starship og zoxide
RUN sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' /etc/skel/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> /etc/skel/.zshrc && \
    echo 'eval "$(zoxide init zsh)"' >> /etc/skel/.zshrc

# 5. Kopier dine egne personlige dotfiles-mapper ind (nvim, tmux osv.)
COPY zsh/     /etc/skel/.config/zsh/
COPY nvim/    /etc/skel/.config/nvim/
COPY git/     /etc/skel/.config/git/
COPY starship/ /etc/skel/.config/starship/
COPY tmux/    /etc/skel/.config/tmux/

# Sørg for at root ejer alt i skel, og nulstil rettighederne til sikre standarder
RUN chown -R root:root /etc/skel && \
    find /etc/skel -type d -exec chmod 755 {} + && \
    find /etc/skel -type f -exec chmod 644 {} +

# VIGTIGT: Fortæl Distrobox/Podman at containeren skal køre som root under opbygningen
USER root
