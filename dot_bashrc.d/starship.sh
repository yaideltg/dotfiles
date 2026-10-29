# starship provides the prompt (config in ~/.config/starship.toml); skipped in dumb terminals (Emacs M-x shell)
if command -v starship >/dev/null 2>&1 && [ "$TERM" != dumb ]; then
    eval "$(starship init bash)"
fi
