#!/usr/bin/env bash
# gh-fzf.sh - Interactive GitHub repo search and clone

# Launch fzf with empty start, live GitHub search, and preview
repo=$(fzf <<< "" \
    --prompt="Search GitHub: " \
    --bind 'change:reload:sleep 0.2; gh search repos {q} --limit 20 --json fullName --jq ".[].fullName" 2> /dev/null || true' \
    --preview 'gh repo view {} --json description,languages \
      --jq ". | \"Description:\n\(.description // \"No description\")\nLanguages: \(.languages | map(.node.name) | join(\", \"))\"" \
      | fold -s -w 80' \
    --ansi \
    --reverse)

# If a repo was selected, clone it
if [ -n "$repo" ]; then
    git clone "https://github.com/$repo.git"
fi
