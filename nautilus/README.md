# Nautilus: Open in Terminal

Adds **Open in Terminal** to the context menu for a single local folder and
the background of the current local folder in GNOME Files (Nautilus).

The extension uses Omarchy's `setsid uwsm-app -- xdg-terminal-exec` launch
pattern and passes the folder as the terminal's working directory. It follows
the terminal preference in `~/.config/xdg-terminals.list`.

## Requirements

- An Omarchy desktop session with `uwsm-app`, `xdg-terminal-exec`, and `setsid`.
- Nautilus with the `nautilus-python` package and Nautilus 4.1 GI bindings.
- A configured terminal emulator and GNU Stow.

## Install

From a checkout at `~/.dotfiles`, preview and then install the package:

```sh
stow --simulate --verbose --no-folding \
  --dir="$HOME/.dotfiles" --target="$HOME" nautilus
stow --verbose --no-folding \
  --dir="$HOME/.dotfiles" --target="$HOME" nautilus
```

`--no-folding` creates individual file links, leaving the extension directory
available for other extensions and locally generated Python caches. Stow
ignores this README and `.gitignore` by default.

If `open_terminal.py` is already installed as a regular file, first confirm
that its contents match the repository copy:

```sh
cmp "$HOME/.local/share/nautilus-python/extensions/open_terminal.py" \
  "$HOME/.dotfiles/nautilus/.local/share/nautilus-python/extensions/open_terminal.py"
```

Only after `cmp` succeeds, preview and perform this one-time migration:

```sh
stow --simulate --verbose --no-folding --adopt \
  --dir="$HOME/.dotfiles" --target="$HOME" nautilus
stow --verbose --no-folding --adopt \
  --dir="$HOME/.dotfiles" --target="$HOME" nautilus
```

`--adopt` moves the installed file into the package and replaces it with a
symlink. If the files differ, compare and reconcile them before adopting.
Use the ordinary install commands for subsequent runs.

Fully quit Nautilus and reopen Files after first installing or editing the
extension. Opening another window while Nautilus is running does not reload
extensions. Right-click a local folder or empty space inside one to use the
new menu item.
