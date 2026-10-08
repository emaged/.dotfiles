# Omarchy theme hooks

The `starship` and `zsh` packages contain the saved Starship palettes and fzf
shell configuration. This package supplies their `theme-set.d` hooks:

- `starship.sh` selects the saved palette for the active theme. For a new theme,
  it generates a palette from Omarchy's colors and saves it in `starship.toml`.
- `fzf.sh` writes `~/.config/fzf/theme.opts`. It uses the official Catppuccin role
  mapping, saved theme accents from Starship, and Omarchy's active surfaces and
  text colors. fzf reads the options file on each invocation.

The fzf options file is generated locally; it does not belong in Git.

## Install with GNU Stow

From a checkout at `~/.dotfiles`, first link the shell and Starship packages:

```sh
stow --dir="$HOME/.dotfiles" --target="$HOME" starship zsh
```

Stow just the theme hooks using their directory as a package. This avoids
unrelated legacy configuration and sample files elsewhere in the Omarchy
package. The resulting links are the same as a full `stow omarchy` would make.

```sh
mkdir -p "$HOME/.config/omarchy/hooks/theme-set.d"
stow --simulate --verbose \
  --dir="$HOME/.dotfiles/omarchy/.config/omarchy/hooks" \
  --target="$HOME/.config/omarchy/hooks/theme-set.d" theme-set.d
stow --verbose \
  --dir="$HOME/.dotfiles/omarchy/.config/omarchy/hooks" \
  --target="$HOME/.config/omarchy/hooks/theme-set.d" theme-set.d
```

If Stow reports existing regular copies of `starship.sh` or `fzf.sh`, compare
them with the repository files first. Back up those copies outside the hook
directory, then rerun Stow. A backup inside `theme-set.d` would also be executed
as a hook. Repeated Stow runs leave existing correct links in place.

Initialize both integrations for the current theme before opening a new shell:

```sh
bash "$HOME/.config/omarchy/hooks/theme-set.d/starship.sh"
bash "$HOME/.config/omarchy/hooks/theme-set.d/fzf.sh"
```

This requires an installed Omarchy session with an active theme, Python 3.11 or
newer, and fzf with `FZF_DEFAULT_OPTS_FILE` support. Future theme switches run
the hooks automatically. Existing shells need a one-time `.zshrc` reload or
restart to adopt the fzf options file; an already-open fzf interface retains
its current colors.
