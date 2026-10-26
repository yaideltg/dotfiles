# dotfiles

Managed with [chezmoi](https://www.chezmoi.io). Target: Fedora 44 Workstation (GNOME).

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-user>

## Rules to follow

- Don't state the "Co-Authored by Cluade" statement when working with git. Work like it's only me doing the work.

## What is restored
- Shell, git, Emacs, mise tools, systemd user units, Bitwarden SSH agent, cliamp
- Packages (`.chezmoidata/packages.yaml`), removed bloat (`debloat.yaml`), NTFS data mount
- GNOME: keybindings, dock favorites, app grid layout/folders, wallpaper, night light, power, Ptyxis, GnuCash prefs (`.chezmoitemplates/gnome-dconf.ini`, loaded with `dconf load` when it changes)
- Firefox: `user.js` prefs and force-installed extensions (uBlock Origin, JShelter, Bitwarden) via policy
- System: hostname, timezone, locale, keymap, RTC mode (`.chezmoidata/system.yaml`)
- Calibre, cliamp, GTK bookmarks, mime associations (`create_` files: written once, never overwritten)

## What is deliberately not stored (public repo)
Bookmarks, history, cookies, saved logins, Firefox profile databases, GnuCash books and anything under `/media/data`, online accounts, SSH/GPG keys. Sync Firefox through Firefox Sync, and keep the data partition separately.

## Script order
chezmoi runs `before` scripts, then writes files, then `after` scripts, each group alphabetically, so scripts carry a numeric prefix:
1. before: 10 debloat, 20 install packages (dnf, flatpak, mise), 30 NTFS mount, 40 system settings
2. files: configs, units, desktop entries, flatpak overrides
3. after: 10 mise tools, 20 mise timer, 30 Bitwarden agent, 40 Emacs daemon, 50 cliamp, 60 Firefox, 70 GNOME dconf, 80 repo remote

Anything that configures an app goes after the step that installs it.
