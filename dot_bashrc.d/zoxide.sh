# zoxide replaces cd with a smarter version (cd foo, cdi for the fzf picker)
# _ZO_ECHO prints the directory after a jump, so `cd chezmo` shows where you landed
# Skipped in Claude Code shells (CLAUDECODE set): they copy the cd function but
# not the prompt hook, so zoxide warns on every cd, and agents want a plain cd
if command -v zoxide >/dev/null 2>&1 && [[ -z ${CLAUDECODE:-} ]]; then
    export _ZO_ECHO=1
    eval "$(zoxide init bash --cmd cd)"
fi
