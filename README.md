# dotfiles

Managed with [chezmoi](https://www.chezmoi.io). Target: Fedora 44 Workstation (GNOME).

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-user>

Answer `yes` to "Is this a personal machine" to enable the install/system scripts.

## What is restored
- Shell, git, Emacs, mise tools, systemd user units, Bitwarden SSH agent, cliamp
- Packages (`.chezmoidata/packages.yaml`), removed bloat (`debloat.yaml`), NTFS data mount
- GNOME: keybindings, dock favorites, app grid layout/folders, wallpaper, night light, power, Ptyxis, GnuCash prefs (`.chezmoitemplates/gnome-dconf.ini`, loaded with `dconf load` when it changes)
- Firefox: `user.js` prefs and force-installed extensions (uBlock Origin, JShelter, Bitwarden) via policy
- System: hostname, timezone, locale, keymap, RTC mode (`.chezmoidata/system.yaml`)
- Calibre, cliamp, GTK bookmarks, mime associations (`create_` files: written once, never overwritten)

## What is deliberately not stored (public repo)
Bookmarks, history, cookies, saved logins, Firefox profile databases, GnuCash books and anything under `/media/data`, online accounts, SSH/GPG keys. Sync Firefox through Firefox Sync, and keep the data partition separately.
