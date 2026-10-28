# fzf key bindings (Ctrl-T, Ctrl-R, Alt-C); Fedora already enables its completion system-wide
if command -v fzf >/dev/null 2>&1; then
    if [ -f /usr/share/fzf/shell/key-bindings.bash ]; then
        . /usr/share/fzf/shell/key-bindings.bash
    fi

    # List files with fd (respects .gitignore) instead of find
    if command -v fd >/dev/null 2>&1; then
        export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    fi

    # ff: find a file in the current directory with a preview; eff: open it in the editor
    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
    alias eff='$EDITOR "$(ff)"'
fi
