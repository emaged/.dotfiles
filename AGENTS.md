# Dotfiles repository

## Layout and scope

- Application directories mirror home-directory paths, such as
  `codex/.codex/` and `nvim/.config/`.
- Live configuration files may be symlinks into this checkout. Resolve the
  target before proposing changes and preserve the existing link structure.
- `bootstrap/omarchy/`, `bootstrap/ubuntu/`, and `bootstrap/windows/` contain
  platform-specific installers. Keep changes scoped to the requested platform.
- `bin/.local/scripts/` contains user scripts; consult its README when relevant.
- `nvim/.config/nvim` is a Git submodule with its own `AGENTS.md`.
  Read that file before proposing Neovim changes.
- Several Neovim configurations coexist. Confirm the target configuration
  before editing; do not assume every variant is active.

## Verification

- Propose checks appropriate to the changed files and target platform.
- Bootstrap scripts perform installations and system changes. Do not use them
  as verification commands without explicit approval for those effects.
- Treat submodule changes separately from changes in the parent repository.
  Do not update the recorded submodule revision unless requested.
