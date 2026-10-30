# zoxide replaces cd with a smarter version (cd foo, cdi for the fzf picker)
# _ZO_ECHO prints the directory after a jump, so `cd chezmo` shows where you landed
if command -v zoxide >/dev/null 2>&1; then
    export _ZO_ECHO=1
    eval "$(zoxide init bash --cmd cd)"
fi
