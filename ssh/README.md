# 1Password between desktop and laptop

`omarchy` is the laptop and `devtop` is the desktop. Both use Tailscale SSH.
New local Zsh shells use local 1Password. Ordinary incoming SSH shells keep
their own forwarded `SSH_AUTH_SOCK`. Forwarding is enabled only for these two
computers' short names, MagicDNS names, and Tailscale IPv4/IPv6 addresses.

For a persistent Herdr terminal, choose where to approve requests:

```zsh
agent-use desktop  # approve on devtop
agent-use laptop   # approve on omarchy
agent-use local    # approve on the computer running this shell
agent-use          # show this terminal's selection
agent-status       # show which forwarded sources are currently available
```

Existing terminals first need `source ~/.zshenv`. New terminals load it
automatically. The choice belongs to the terminal and is inherited by its
child processes. It does not change other terminals or already-running GUI applications.
Selecting the computer running the shell is equivalent to `local`.

Keep a Herdr/SSH connection open **from the approving computer to the computer
running the command**. The routing service does not create network connections
or keep the approving computer awake. For example, approving laptop commands
on the desktop requires a desktop-to-laptop connection with agent forwarding.
Both saved Herdr connections provide this while connected.

## How it works

The shell hook records the socket supplied by incoming SSH, with its source
Tailscale address and socket inode. OpenSSH uses `.ssh/rc`; Tailscale SSH needs
the `.zshenv` hook. Unknown sources, local-agent sockets, relay sockets, and
unsafe socket permissions are rejected. Repeated shell startup does not
replace or reorder the record for an existing connection.

The user service listens on private Unix sockets under
`$XDG_RUNTIME_DIR/ssh-agent-routing/`. A selected terminal keeps one stable
socket path. Each new client connection is relayed to an available forwarded
socket from that specific source. A short SSH session cannot strand another
connection, and reconnecting Herdr supplies a new backend automatically.
An operation already in progress may fail during a disconnect; retry it after
the connection returns. No requests are replayed, and there is no fallback to
another source or local 1Password.

The relay copies agent-protocol bytes without interpreting or logging keys or
signing requests. It writes only connection metadata, with private directory
and file permissions. Normal SSH agent-forwarding trust still applies: other
processes running as your user on the receiving computer can use a forwarded
agent, subject to 1Password's authorization policy.

SSH configuration selects `SSH_AUTH_SOCK` for forwarded/selected sessions and
disables disk identity files there. Local sessions preserve the previous disk
key behavior. Connections to the two trusted computers always forward that
computer's own 1Password socket, preventing forwarding loops. Neither a failed
key-list probe nor an empty/locked agent causes a switch to another device.

Git commit signing is not enabled or reconfigured here. `ssh-keygen` follows
`SSH_AUTH_SOCK`; `op-ssh-sign` may require `SSH_TTY` to use forwarding, which
Herdr's background transport does not supply. Repository-specific signing
configuration should be checked if signing still opens the wrong prompt.

1Password may reuse an earlier approval, so a successful operation need not
show a new prompt. If a background request needs approval, open 1Password's
tray icon on the **selected device** and choose **SSH request waiting**.
Unlocking the app alone does not approve a pending key request.

## Files and maintenance

The shared configuration, relay, peer map, SSH hook, user unit, and desktop
environment setting belong to the `ssh` Stow package. `.zshenv` belongs to
the `zsh` package. `~/.ssh/config` comes from one additional host package:

| Computer | Host package | Config source |
| --- | --- | --- |
| Laptop (`omarchy`) | `ssh-omarchy` | `ssh-omarchy/.ssh/config` |
| Desktop (`devtop`) | `ssh-devtop` | `ssh-devtop/.ssh/config` |

Choose exactly one host package. On the laptop:

```sh
stow --dir="$HOME/.dotfiles" --target="$HOME" ssh zsh ssh-omarchy
```

On the desktop:

```sh
stow --dir="$HOME/.dotfiles" --target="$HOME" ssh zsh ssh-devtop
```

Stow owns these relative links. The package's `.stow-local-ignore` keeps
documentation, tests, Python caches, and any leftover legacy `hosts/` directory
inside the checkout. Stowing does not create `~/hosts` or `~/tests`.

On a fresh installation, enable the user service after stowing:

```sh
systemctl --user daemon-reload
systemctl --user enable --now ssh-agent-routing.service
dbus-update-activation-environment --systemd "SSH_AUTH_SOCK=$HOME/.1password/agent.sock"
```

Preview a restow on either of these two computers with:

```sh
stow --simulate --restow --verbose --dir="$HOME/.dotfiles" --target="$HOME" ssh zsh "ssh-$(hostname -s)"
```

The desktop default is set by `~/.config/environment.d/ssh-agent.conf`, linked
to this package's `.config/environment.d/ssh-agent.conf`. It sets
`SSH_AUTH_SOCK=${HOME}/.1password/agent.sock` for new user services. During
installation, the systemd user and D-Bus activation environments are refreshed
with that explicit local path. Do not import a selected terminal's forwarded
socket as the desktop default.

Already-running applications and launchers keep their inherited environment.
Log out and back in to apply the default throughout each desktop session.
Incoming SSH sessions still use their forwarded sockets, and `agent-use`
continues to change only the selected terminal and its children.

If a device is re-enrolled in Tailscale and gets a different IP, update both
`agent-peers.json` and `config.d/1password.conf`, then restart the user service.
Do not run `bootstrap/omarchy/ssh-setup.sh` to maintain this setup: that script
installs a separate plain OpenSSH agent.

```sh
systemctl --user status ssh-agent-routing.service
journalctl --user -u ssh-agent-routing.service -n 30 --no-pager
systemctl --user restart ssh-agent-routing.service
```

The initial installation saves replaced files and the former shared symlink
under `~/.ssh/agent-routing-backups/<timestamp>/`, with a manifest mapping each
backup to its original path. To roll back, disable the routing service, restore
those entries, remove the newly installed links listed in the manifest, reload
the user systemd manager, and open a new shell.
The desktop-environment change has a separate manifest in an
`<timestamp>-environment` backup directory. Its manifest records the original
environment file and previous systemd value.
The Stow migration records the previous link targets and copies of the former
host config files in an `<timestamp>-stow` backup directory. Restoring those
old links also requires restoring their old host config files from that backup.

## Focused checks

These checks are specific to this implementation; no bootstrap installer is run.

```sh
python3 -B -m unittest discover -s ssh/tests -v
zsh -n zsh/.zshenv
sh -n ssh/.ssh/rc
systemd-analyze --user verify ssh/.config/systemd/user/ssh-agent-routing.service
```

The tests bind temporary Unix sockets and may need to run outside a sandbox
that blocks sockets. They also exercise real Stow, restow, and unstow operations
in temporary home directories, preserving unrelated files and rejecting the
wrong host package. Live verification checks Stow's dry runs and `ssh -G` for
both devices' aliases and agent selection. Forwarding checks use public-key
listing; real signing verification requires approval on the selected computer.
Tests never commit or push to Git.
