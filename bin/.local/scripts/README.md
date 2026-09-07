## tmux sessionizer
its a script that does everything awesome at all times

## Requirements
fzf and tmux

## Usage
```bash
tmux-sessionizer [<partial name of session>]
```

if you execute tmux-sessionizer without any parameters it will FZF set of default directories or ones specified in config file.

## Session Commands
Session commands are for you to write / navigate without using tmux navigation commands.
They are meant to be used with zsh/vim/tmux remaps.

The basic idea is that you want long running commands on a per session basis.
You can start them by calling tmux-sessionizer with the -s option.  This will
start the long running session starting at window 69.  This means if you open 6
windows, it wont interfere with your way of using tmux.

### Example
tmux-sessionizer config file
```bash
# file: ~/.config/tmux-sessionizer/tmux-sessionizer.conf
TS_SESSION_COMMANDS=(opencode .)
```

There is one command which means you can call `tmux-sessionizer -s 0` only (`-s 1` is out of bounds)
This will effectively call the following command:
```bash
tmux neww -t $SESSION_NAME:69 opencode .
```

### How i use it
Here are my vim remaps for tmux-sessionizer.  C-f will do the standard
sessionizer experience but Alt+h will mimic my harpoon navigation.  C-h is
first file harpoon.  M-h is first sessionizer command.

**vim**
```lua
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
vim.keymap.set("n", "<M-h>", "<cmd>silent !tmux neww tmux-sessionizer -s 0<CR>")
vim.keymap.set("n", "<M-t>", "<cmd>silent !tmux neww tmux-sessionizer -s 1<CR>")
vim.keymap.set("n", "<M-n>", "<cmd>silent !tmux neww tmux-sessionizer -s 2<CR>")
vim.keymap.set("n", "<M-s>", "<cmd>silent !tmux neww tmux-sessionizer -s 3<CR>")
```

**zsh**
```bash
bindkey -s ^f "tmux-sessionizer\n"
bindkey -s '\eh' "tmux-sessionizer -s 0\n"
bindkey -s '\et' "tmux-sessionizer -s 1\n"
bindkey -s '\en' "tmux-sessionizer -s 2\n"
bindkey -s '\es' "tmux-sessionizer -s 3\n"
```

**tmux**
```bash
bind-key -r f run-shell "tmux neww ~/.local/bin/tmux-sessionizer"
bind-key -r M-h run-shell "tmux neww tmux-sessionizer -s 0"
bind-key -r M-t run-shell "tmux neww tmux-sessionizer -s 1"
bind-key -r M-n run-shell "tmux neww tmux-sessionizer -s 2"
bind-key -r M-s run-shell "tmux neww tmux-sessionizer -s 3"
```

## Enable Logs
This is for debugging purposes.

```bash
# file: ~/.config/tmux-sessionizer/tmux-sessionizer.conf
TS_LOG=file | echo # echo will echo to stdout, file will write to TS_LOG_FILE
TS_LOG_FILE=<file> # will write logs to <file> Defaults to ~/.local/share/tmux-sessionizer/tmux-sessionizer.logs
```

# Development environment updates

Run `update-dev` as your normal user, primarily on Omarchy. It also supports
the user tools installed by the Ubuntu bootstrap.

```sh
update-dev --dry-run
update-dev
update-dev cargo pipx npm
```

The dry run prints commands and checks local tool availability/package ownership.
It does not contact registries, check available versions, or run updaters.

Supported components: `zinit`, `mise`, `rustup`, `cargo`, `pipx`, `uv`, `npm`,
`julia`, and `starship`. Missing tools are skipped. Steps run sequentially;
failures are reported at the end and produce a nonzero exit status. A failure
does not prevent independent components from updating.

- System-owned binaries use your normal OS update process. The script detects
  pacman and dpkg ownership and does not invoke sudo or install dependencies.
- mise runs from your home directory so the invoking project's configuration
  is not selected. It respects configured versions and keeps old runtimes:
  pipx environments and other tools may still reference their paths. A `latest`
  constraint can include major releases.
- Before mise updates, npm globals are recorded. If the global prefix changes,
  registry packages are installed at their previous versions in the new prefix.
  npm itself is supplied by the Node installation and is not migrated.
  Linked/local packages or a broken npm inventory stop the mise step for manual
  handling. Migration also happens when only the `mise` component is selected.
- The npm component runs `npm update -g` using the home-level mise Node when
  available. This follows npm's normal update rules, rather than reinstalling
  every package with an explicit `@latest` request.
- Python updates cover pipx tools (including injected packages) and uv tools.
  They do not update system Python packages or project virtual environments.
- Zinit is loaded directly without sourcing `.zshrc`. Set `ZINIT_HOME` to its
  parent directory if it is outside the usual locations (for example,
  `ZINIT_HOME="$HOME/.local/share/zinit"`).
- Cargo updates require the bootstrap's existing `cargo-update` installation.
  Compilation can take time. Rust toolchains are updated only if rustup exists.
- Standalone Starship is refreshed through its official installer only when its
  existing binary and directory are writable and it is in `~/.local/bin` or
  `/usr/local/bin`. System packages and other installation methods are skipped.
- Neovim/Mason/Treesitter and tmux plugins, pinned themes, and project dependency
  updates remain manual in this first version.

Open a new shell after runtime upgrades to refresh your active tool paths.
