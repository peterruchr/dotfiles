#!/usr/bin/env bash

SESSION_NAME="dev"

tmux has-session -t "$SESSION_NAME" 2>/dev/null

if [ $? -eq 1 ]; then
    tmux new -d -s "$SESSION_NAME"
    tmux rename-window -t "$SESSION_NAME:1" "nvim"
    tmux new-window -t "$SESSION_NAME:2" -n "cli"
    tmux select-window -t "$SESSION_NAME:1"
fi

tmux attach -t "$SESSION_NAME"
