# fzf key bindings (Ctrl-T, Ctrl-R, Alt-C) and completion
if command -v fzf >/dev/null 2>&1; then
    eval "$(fzf --bash)"
fi
