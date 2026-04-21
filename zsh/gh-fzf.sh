#!/usr/bin/env bash
# gh-fzf.sh - Interactive GitHub repo search and clone

# Launch fzf with empty start, live GitHub search, and preview
repo=$(fzf <<<"" \
      --prompt="Search GitHub: " \
      --bind 'change:reload:sleep 0.2; gh search repos {q} --limit 20 --json fullName --jq ".[].fullName" 2> /dev/null || true' \
      --preview 'gh repo view {} --json description,languages \
      --jq ". | \"Description:\n\(.description // \"No description\")\nLanguages: \(.languages | map(.node.name) | join(\", \"))\"" \
      | fold -s -w 80' \
      --ansi \
      --reverse)

# If a repo was selected, clone it as a bare repo for worktrees
if [ -n "$repo" ]; then
      # Extract repo name from owner/repo format
      repo_name="${repo##*/}"

      # Clone as bare repository
      git clone --bare "git@github.com:$repo.git" "${repo_name}"

      echo "Bare repository cloned to: ${repo_name}"

      # Determine the default branch by looking at HEAD
      default_branch=$(git -C "${repo_name}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "main")

      # Create a main worktree inside the bare repo
      git -C "${repo_name}" worktree add "$default_branch" "$default_branch"

      echo "Main worktree created at: ${repo_name}/${default_branch}"
      echo "Create additional worktrees with: git -C ${repo_name} worktree add <branch-name> <branch>"
fi
