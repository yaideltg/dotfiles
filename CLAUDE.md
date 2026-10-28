# dotfiles

Managed with [chezmoi](https://www.chezmoi.io). Target: Fedora 44 Workstation (GNOME).

    sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-user>

## Rules to follow

- Don't add a "Co-Authored-By: Claude" line (or any other Claude attribution) when working with git. Work like it's only me doing the work.
- Prefer user-local configuration over system-wide. Go system-wide only when common sense, good design, security or persistence of the change makes it the better choice.
- The config files are the source of truth. Don't duplicate package lists or settings in this file; read the files.

## Where things live
- `.chezmoidata/`: data for templates and scripts (packages, debloat list, system settings). Add packages and settings here.
- `.chezmoitemplates/`: shared template content (Firefox policy and prefs, GNOME dconf).
- `dot_bashrc.d/`: one small shell file per tool, guarded with `command -v` so a missing tool never breaks the shell. `dot_bashrc` only sources this directory.
- `dot_config/`, `dot_local/`: user config files. Tools that are fast-moving or user-level go in the mise config; system packages go in `packages.yaml`.
- `run_*` scripts: setup steps for things that can't be plain files. `run_onchange_` scripts embed a hash of their input so they rerun when it changes.
- `create_` files are written once and never overwritten (apps that rewrite their own config). Everything else is overwritten on apply.

## What is deliberately not stored (public repo)
Bookmarks, history, cookies, saved logins, browser profile databases, app data and books, anything under `/media/data`, online accounts, SSH/GPG keys, secrets. Sync Firefox through Firefox Sync and keep the data partition separately. Never commit anything sensitive; a gitleaks pre-commit hook runs (`.githooks/`).

## Script order
chezmoi runs `before` scripts, then writes files, then `after` scripts, each group alphabetically, so scripts carry a numeric prefix. Check the existing filenames for the current sequence and pick a number that keeps dependencies in order.

Anything that configures an app goes after the step that installs it.

## Working here
- Edit the chezmoi source (this repo), never the target files in `$HOME` directly.
- Check changes with `chezmoi diff` before `chezmoi apply`.
- Only commit or push when asked.
