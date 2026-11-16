# Bootstrap installers

Four independent installers are maintained here. Each has its own entry point,
modules and package lists; none imports another platform's installer. Linux
helpers are deliberately duplicated within each directory so a platform can be
maintained independently. Tests check the common package lists for unintended drift.

| Directory | Target | Default scope |
| --- | --- | --- |
| [`omarchy/`](omarchy/) | Existing Omarchy installation | Personal development tools and desktop apps; retains Omarchy-managed tools |
| [`ubuntu/`](ubuntu/) | Ubuntu 24.04 or 26.04 LTS desktop | Development tools, desktop apps and Wayland utilities |
| [`wsl/`](wsl/) | Ubuntu 24.04 or 26.04 LTS inside WSL | Linux development tools; GUI apps and Neovide belong to the Windows installer |
| [`windows/`](windows/) | Windows 11 x64 | Native development tools, PowerShell, Windows Terminal and desktop apps |

The primary target is x86-64. ARM installations and complete fresh installs of
these environments have not been verified. These scripts install packages and
some shell integrations; they do not deploy the entire dotfiles tree or alter
the Neovim submodule. The Windows `profile` module requires the full dotfiles
checkout because it sources `windows/powershell/Microsoft.PowerShell_profile.ps1`.

## Running an installer

Run from this directory as your normal user. Linux modules request `sudo` when
needed; do not start the whole installer as root. Use a non-elevated Windows
PowerShell session because Scoop installs into the user account. A full Windows
run requires Visual Studio C++ Build Tools with the **Desktop development with
C++** workload and a Windows SDK already installed; the script checks this
before Cargo builds. It does not install that large workload automatically.

Preview before installing:

```sh
bash omarchy/install.sh --dry-run
bash ubuntu/install.sh --dry-run
bash wsl/install.sh --dry-run
```

```powershell
.\windows\install.ps1 -DryRun
```

Omit the preview flag to install the default modules. Previews list the module
order and dependencies only: they do not execute modules, contact registries,
check installed packages, download anything, or predict package versions. They
work on other hosts too. Real runs reject the wrong platform; Ubuntu desktop
does not silently switch to WSL mode.

Select modules through the entry point so prerequisites are included:

```sh
bash ubuntu/install.sh --list
bash ubuntu/install.sh --dry-run node yazi
bash ubuntu/install.sh node yazi
bash wsl/install.sh neovim
bash omarchy/install.sh npm
```

```powershell
.\windows\install.ps1 -List
.\windows\install.ps1 -DryRun -Modules node,yazi
.\windows\install.ps1 -Modules node,yazi
```

Module names are validated before any installation. Dependencies run once, and
an error stops the run with the failing module and exit status. Fix the error
and rerun the selected module. Invoke `--help` or `-Help` for the options.
Calling a module directly bypasses platform checks and dependency preparation.

## Package comparison

This compares installer declarations and the installed Omarchy defaults audited
on 2026-11-16, not a live inventory of Ubuntu or Windows machines. Package
versions differ between distributions; these installers align tool availability.

| Tools | Omarchy | Ubuntu desktop | WSL | Windows |
| --- | --- | --- | --- | --- |
| Python CLI tools (8) | pipx | pipx | pipx | pipx with mise Python |
| npm tools (13) | npm, reusing existing mise owners for Codex/Copilot/Mermaid | npm | npm | npm |
| OpenCode | mise | npm | npm | npm |
| ast-grep, cargo-update, dust, selene, trashy | Cargo or an existing Arch package | Cargo | Cargo | Cargo |
| Neovide | Cargo or existing Arch package | Cargo | Native Windows installation | Cargo |
| Tree-sitter CLI | Existing Arch package or Cargo | Cargo | Cargo | Scoop |
| Neovim | AUR nightly | mise nightly for new setups | mise nightly for new setups | mise nightly for new setups |
| uv | mise, reusing Omarchy configuration | Official installer if absent | Official installer if absent | WinGet |
| Julia | Juliaup | Juliaup | Juliaup | Juliaup via Microsoft Store |
| Starship | Arch package | User installation if absent | User installation if absent | WinGet |
| tmux / TPM / PowerKit | Arch / user plugins / Omarchy theme hook | Recent mise tmux / user plugins | Recent mise tmux / user plugins | Use WSL |
| Yazi / fzf / resvg | Arch packages | mise; other dependencies from apt | mise; other dependencies from apt | WinGet / Scoop |
| TeX Live base | Not included | Included | Included | Not included |
| Tectonic | Arch package | apt or mise GitHub backend | apt or mise GitHub backend | Scoop |
| JDK 8, 11, 17, 21 | Arch packages, plus current JDK | Available apt packages | Available apt packages | WinGet |
| MongoDB client tools | AUR | Vendor repo on 24.04; explicit skip on 26.04 | Same as Ubuntu | WinGet |
| Firefox / Brave / VLC / Postman | Included | Included | Use native Windows apps | Included |
| Firefox Developer Edition / JetBrains Toolbox | Included | Not included | Use native apps if wanted | Not included |
| OpenJFX | Not included | Included | Not included | Not included |
| Wayland and hardware utilities | Wayland tools; brightness setup optional | Wayland tools; brightness setup optional | Clipboard tool only | Native Windows facilities |

Each platform's `packages/npm.txt`, `packages/pipx.txt` and
`packages/cargo.txt` owns its language-package selection. Native package names
remain in that platform's modules. Edit the platform-local list you intend to
change; adjust the parity test when a new difference is intentional.

The pipx set is `black`, `djlint`, `hererocks`, `ipython`, `poetry`, `pynvim`,
`pytest` and `ruff`. The npm set is Codex, Copilot, Mermaid CLI, `browser-sync`,
`eslint`, `eslint-config-prettier`, `eslint_d`, `htmlhint`, `http-server`,
`live-server`, `mcp-hub`, `neovim` and `prettier`. OpenCode has its own module.

## Installation behavior and remaining differences

- Prerequisites install before downloaded installers. Downloads use private
  temporary files, fail on HTTP errors, and are cleaned up on failure. They
  still require network access and rely on the upstream installation sources.
- mise uses the home configuration. Existing tool selections and installed
  runtimes are retained; absent selections use `latest`, except new Neovim
  selections use `nightly`. No interactive shell activation is needed during
  installation. Keep the dotfiles shell integration enabled for later sessions.
- Existing Omarchy mise owners for Codex, Copilot and Mermaid are reused.
  Existing Arch-owned Cargo tools are not rebuilt. Old duplicate installations
  are not automatically removed.
- npm requires a user-owned writable prefix on Linux and a prefix inside the
  user's home on Windows. The scripts do not solve permission problems by
  running npm as an administrator.
- pipx uses exact package names from JSON inventory. Upgrade errors are
  propagated. Rustup uses its stable toolchain without changing the default
  toolchain; system Cargo is retained when rustup is absent.
- Ubuntu/WSL expose `batcat` and `fdfind` as `bat` and `fd` when necessary,
  without replacing existing commands or links. Tools absent from the LTS
  archive, including lazygit, use explicit mise fallbacks. Tectonic has no
  mise registry shorthand and uses `github:tectonic-typesetting/tectonic`.
- Ubuntu 24.04's tmux is older than the 3.6 features used by these dotfiles.
  Ubuntu/WSL use a recent mise tmux; the apt package supplies runtime libraries.
  A pinned mise tmux below 3.6 produces an actionable error. The shared tmux
  **configuration outside bootstrap** still has an Omarchy-specific help-menu
  binding; that command is unavailable on Ubuntu/WSL. This patch does not edit it.
- Ubuntu 24.04 ships ImageMagick 6. Yazi prints a notice about reduced
  font/HEIC/JXL previews; full previews need ImageMagick 7.1.1 or newer. Existing
  mise pins for fzf/Yazi are retained, so older pins can still limit features.
- MongoDB 8.0's repository is configured only for Ubuntu 24.04. On 26.04 the
  module exits with a designated skip status, and the final summary identifies
  it. No Noble repository is silently added to Resolute. Existing repository
  files from earlier runs are not automatically migrated or deleted; use
  vendor-supported standalone client tools when appropriate.
- JDK/source packages unavailable in an Ubuntu release are explicitly listed
  as optional omissions. Firefox Developer Edition and Toolbox remain
  Omarchy-only choices; other GUI package differences are shown above.
- Ubuntu desktop Postman uses Snap and requires systemd. WSL installs neither
  Snap GUI apps nor physical hardware setup. Windows Yazi discovers Git's
  `file.exe` and sets `YAZI_FILE_ONE` only when not already set.
- The scripts install plugins and providers but do not run Neovim/Mason or
  compile editor-managed grammars as verification. Newer tools and nightly
  Neovim may require corresponding configuration updates.

## Optional setup

These actions are excluded from the default module set:

```sh
bash omarchy/install.sh brightness_setup
bash omarchy/install.sh omarchy-plugins
bash ubuntu/install.sh brightness_setup
```

Omarchy plugins require an active desktop session. Legacy titlebar setup is
skipped if `omarchy-hyprland-titlebars` is installed. Existing legacy plugins
are left in place. The `hyprland` module remains available explicitly on
Omarchy/Ubuntu for installations already using `hyprpm`.

The auxiliary `ssh-setup.sh` scripts are also explicit actions. They use the
native OpenSSH socket where available, or install their own user service when
it is absent (including Ubuntu 24.04). They require a systemd user session,
refuse a conflicting agent configuration, preserve existing host settings and
do not select a private-key filename. WSL users must enable systemd separately
if they want this helper. No SSH helper runs as part of a normal bootstrap.

Plex remains an explicit `omarchy/plex-setup.sh` or `ubuntu/plex-setup.sh`
action. The Arch variant installs Plex through the AUR and both enable the
service. The WSL Dropbox symlink helper now takes the Windows path explicitly:

```sh
bash wsl/dropbox.sh /mnt/c/Users/your-user/Dropbox
```

It refuses to replace an existing directory or conflicting link. The old Ubuntu
helper only prints the new invocation.

## Verification

These checks do not install packages or start services:

```sh
python3 tests/test_bootstrap.py
git diff --check -- .
```

The Python suite uses the standard library. It checks Bash syntax, package-list
parity, previews, module dependencies, early failures, exact pipx matching,
mise selection preservation, npm ownership checks, download cleanup and SSH
fallback behavior using temporary homes and mocked commands. Tests that require
a non-root caller are explicitly skipped when run as root.

On a machine with PowerShell, also run:

```powershell
pwsh -NoProfile -File tests/test_windows.ps1
```

That script parses all Windows files and checks previews, Scoop objects, PATH
preservation and mise handling with mocks; it does not invoke real installers.
The Windows runtime checks, ShellCheck and full installations were not run
during this audit because the required runtime/tools/target hosts were absent.

Package and behavior references: [mise script usage](https://mise.jdx.dev/cli/exec.html),
[Yazi prerequisites](https://yazi-rs.github.io/docs/installation/),
[Ubuntu lazygit availability](https://packages.ubuntu.com/lazygit),
[MongoDB 8.0 supported Ubuntu releases](https://www.mongodb.com/docs/v8.0/tutorial/install-mongodb-on-ubuntu/),
[Rust Windows requirements](https://rust-lang.org/tools/install/),
[tmux changes](https://github.com/tmux/tmux/blob/master/CHANGES).

## Development environment updates

The existing global `update-dev` command lives in
[`bin/.local/scripts`](../bin/.local/scripts/README.md#development-environment-updates).
Use it for subsequent Linux tool updates instead of treating bootstrap as a
complete updater:

```sh
update-dev --dry-run
update-dev
```
