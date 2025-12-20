# Setup fzf
# ---------
if [[ ! "$PATH" == */home/peter/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/peter/.fzf/bin"
fi

eval "$(fzf --bash)"
