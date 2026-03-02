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

      # Clone as bare repository using SSH
      git clone --bare "$1:$repo.git" "${repo_name}"

      # Fix remote-tracking refs (bare clone uses wrong refspec by default)
      git -C "${repo_name}" config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
      git -C "${repo_name}" fetch origin
      git -C "${repo_name}" remote set-head origin --auto

      echo "Bare repository cloned to: ${repo_name}"

      # Get default branch from origin/HEAD
      default_branch=$(git -C "${repo_name}" symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')

      # Create a worktree from the remote branch
      git -C "${repo_name}" worktree add -b "$default_branch" \
            "${repo_name}/${default_branch}" \
            "origin/$default_branch"

      echo "Main worktree created at: ${repo_name}/${default_branch}"
      echo "Create additional worktrees with: git -C ${repo_name} worktree add <branch-name> <branch>"
fi
