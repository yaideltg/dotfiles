# Emacs clients for the daemon; --alternate-editor= starts one if none is running
alias e="emacsclient --tty --alternate-editor=''"
alias eg="emacsclient --create-frame --no-wait --alternate-editor=''"

# Programs that open an editor (git commit, crontab -e, sudoedit...) use the daemon too
export EDITOR="emacsclient --tty --alternate-editor="
export VISUAL="$EDITOR"
