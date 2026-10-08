#!/bin/bash
# Generate a local Starship config without modifying the tracked base.
# Unknown themes get a palette generated from their active colors.toml.
set -euo pipefail

python3 - "$@" <<'PY'
import fcntl
import os
from pathlib import Path
import re
import stat
import subprocess
import sys
import tempfile
import tomllib

current = Path.home() / ".local/state/omarchy/current"
theme_file = current / "theme.name"
config = (Path.home() / ".config/starship.toml").resolve(strict=True)
destination = Path.home() / ".local/state/starship/starship.toml"
roles = {
    "red": "red", "peach": "orange", "yellow": "yellow", "green": "green",
    "sapphire": "cyan", "lavender": "blue", "crust": "background",
}
aliases = {
    "catppuccin": "catppuccin_mocha",
    "catppuccin-mocha": "catppuccin_mocha",
    "catppuccin-latte": "catppuccin_latte",
    "catppuccin-frappe": "catppuccin_frappe",
    "catppuccin-macchiato": "catppuccin_macchiato",
    "rose-pine": "omarchy_rose_pine_dawn",
}
for slug in (
    "ethereal everforest flexoki-light gruvbox hackerman kanagawa last-horizon "
    "lumon lupine matte-black miasma nord osaka-jade retro-82 ristretto solitude "
    "tokyo-night vantablack white"
).split():
    aliases[slug] = "omarchy_" + slug.replace("-", "_")


def current_theme():
    # A previous theme's hook can run late; always prefer the active theme.
    if theme_file.is_file():
        return theme_file.read_text().strip()
    return sys.argv[1] if len(sys.argv) > 1 else ""


def update():
    for _ in range(3):
        theme = current_theme()
        if not re.fullmatch(r"[a-z0-9][a-z0-9_-]*", theme):
            raise ValueError(f"Invalid or missing Omarchy theme name: {theme!r}")
        palette_name = aliases.get(theme, "omarchy_custom_" + theme)
        original = config.read_text()
        expected = tomllib.loads(original)
        palettes = expected.setdefault("palettes", {})
        updated = original

        if palette_name not in palettes:
            colors_file = current / "theme/colors.toml"
            if not colors_file.is_file():
                raise ValueError(f"Cannot generate a palette: {colors_file} is missing")
            result = subprocess.run(
                ["omarchy", "theme", "color", "--file", str(colors_file), "--all"],
                text=True, stdout=subprocess.PIPE, check=True,
            )
            colors = dict(line.split("\t", 1) for line in result.stdout.splitlines())
            palette = {role: colors.get(key, "") for role, key in roles.items()}
            if not all(re.fullmatch(r"#[0-9a-fA-F]{6}", value) for value in palette.values()):
                raise ValueError("Theme does not supply all required palette colors")
            palettes[palette_name] = palette
            updated = original.rstrip() + (
                f"\n\n# Generated from Omarchy theme {theme}: colors.toml\n"
                "# Regenerated from the active theme on each config rebuild.\n"
                f"[palettes.{palette_name}]\n"
            )
            updated += "".join(f'{key} = "{value}"\n' for key, value in palette.items())

        if not roles.keys() <= palettes[palette_name].keys():
            raise ValueError(f"Palette {palette_name!r} is missing prompt colors")

        # Select the palette in the generated copy.
        if expected.get("palette") != palette_name:
            updated, count = re.subn(
                r"(?m)^palette[ \t]*=[^\r\n]*",
                f"palette = '{palette_name}'", updated, count=1,
            )
            if count != 1:
                raise ValueError("Cannot locate the top-level Starship palette setting")
        expected["palette"] = palette_name
        if tomllib.loads(updated) != expected:
            raise ValueError("Palette update would change unrelated Starship settings")

        updated = "# Generated from ~/.config/starship.toml; edit that file instead.\n" + updated

        # Theme staging and hooks run separately; retry if colors changed while read.
        if current_theme() != theme:
            continue
        if config.read_text() != original:
            raise ValueError("Starship config changed during update; leaving it untouched")
        if destination.is_file() and destination.read_text() == updated:
            return

        # Publish the generated copy atomically; never write to the base config.
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(mode="w", dir=destination.parent, delete=False) as output:
                temporary = Path(output.name)
                os.fchmod(output.fileno(), stat.S_IMODE(config.stat().st_mode))
                output.write(updated)
            os.replace(temporary, destination)
        finally:
            if temporary is not None:
                temporary.unlink(missing_ok=True)
        return
    raise ValueError("Theme changed repeatedly while updating Starship; please retry")


try:
    destination.parent.mkdir(parents=True, exist_ok=True)
    # Serialize theme hooks and shell startup using the stable output directory.
    lock = os.open(destination.parent, os.O_RDONLY)
    try:
        fcntl.flock(lock, fcntl.LOCK_EX)
        update()
    finally:
        os.close(lock)
except (OSError, ValueError, subprocess.CalledProcessError) as error:
    print(f"Starship theme update failed: {error}", file=sys.stderr)
    sys.exit(1)
PY
