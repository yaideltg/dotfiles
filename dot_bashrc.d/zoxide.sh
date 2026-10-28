# zoxide replaces cd with a smarter version (cd foo, cdi for the fzf picker)
if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash --cmd cd)"
fi
