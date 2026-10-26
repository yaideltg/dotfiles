# uv and uvx shell completion
if command -v uv >/dev/null 2>&1; then
    eval "$(uv generate-shell-completion bash)"
fi
if command -v uvx >/dev/null 2>&1; then
    eval "$(uvx --generate-shell-completion bash)"
fi
