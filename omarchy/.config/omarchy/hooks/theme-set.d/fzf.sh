#!/bin/bash
# Refresh fzf's options file; each new fzf invocation reads it automatically.
set -euo pipefail

python3 - "$@" <<'PY'
import fcntl
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import tomllib

current = Path.home() / ".local/state/omarchy/current"
theme_file = current / "theme.name"
destination = Path.home() / ".config/fzf/theme.opts"
starship = Path.home() / ".config/starship.toml"

# Official Catppuccin fzf role mapping, using the existing full flavor palettes.
# https://github.com/catppuccin/fzf/tree/main/themes
catppuccin_roles = {
    "bg+": "surface0", "bg": "base", "spinner": "rosewater", "hl": "red",
    "fg": "text", "header": "red", "info": "mauve", "pointer": "rosewater",
    "marker": "lavender", "fg+": "text", "prompt": "mauve", "hl+": "red",
    "selected-bg": "surface1", "border": "overlay0", "label": "text",
}
catppuccin_names = {
    "catppuccin": "catppuccin_mocha", "catppuccin-mocha": "catppuccin_mocha",
    "catppuccin-latte": "catppuccin_latte", "catppuccin-frappe": "catppuccin_frappe",
    "catppuccin-macchiato": "catppuccin_macchiato",
}


def current_theme():
    if theme_file.is_file():
        return theme_file.read_text().strip()
    return sys.argv[1] if len(sys.argv) > 1 else ""


def update():
    for _ in range(3):
        theme = current_theme()
        if not re.fullmatch(r"[a-z0-9][a-z0-9_-]*", theme):
            raise ValueError(f"Invalid or missing Omarchy theme name: {theme!r}")
        colors_file = current / "theme/colors.toml"
        if not colors_file.is_file():
            raise ValueError(f"Missing theme colors: {colors_file}")
        result = subprocess.run(
            ["omarchy", "theme", "color", "--file", str(colors_file), "--all"],
            text=True, stdout=subprocess.PIPE, check=True,
        )
        colors = dict(line.split("\t", 1) for line in result.stdout.splitlines())
        palettes = {}
        try:
            palettes = tomllib.loads(starship.read_text()).get("palettes", {})
        except (OSError, ValueError) as error:
            print(f"fzf: using Omarchy colors; cannot read saved palettes: {error}", file=sys.stderr)

        # Look up the requested theme, not Starship's current selection: hooks
        # can run in either order, and a previous theme's hook can finish late.
        names = {
            name.removeprefix("omarchy_").replace("_", "-"): name
            for name in palettes
            if name.startswith("omarchy_") and not name.startswith("omarchy_custom_")
        }
        names.update(catppuccin_names)
        names["rose-pine"] = "omarchy_rose_pine_dawn"
        palette = palettes.get(names.get(theme, "omarchy_custom_" + theme), {})

        if theme in catppuccin_names and all(key in palette for key in catppuccin_roles.values()):
            selected = {role: palette[key] for role, key in catppuccin_roles.items()}
            mode = "light" if theme == "catppuccin-latte" else "dark"
        else:
            # Preserve the active Omarchy surfaces and text; reuse the verified
            # accent colors saved for Starship where available.
            red = palette.get("red", colors.get("red", ""))
            blue = palette.get("lavender", colors.get("blue", ""))
            cyan = palette.get("sapphire", colors.get("cyan", ""))
            selected = {
                "bg+": colors.get("lighter_background", ""), "bg": colors.get("background", ""),
                "spinner": cyan, "hl": red, "fg": colors.get("foreground", ""),
                "header": red, "info": blue, "pointer": cyan, "marker": blue,
                "fg+": colors.get("bright_foreground", ""), "prompt": blue, "hl+": red,
                "selected-bg": colors.get("selection", ""), "border": colors.get("muted", ""),
                "label": colors.get("foreground", ""),
            }
            mode = "light" if colors.get("mode") == "light" else "dark"
        if not all(isinstance(value, str) and re.fullmatch(r"#[0-9a-fA-F]{6}", value)
                   for value in selected.values()):
            raise ValueError("Theme does not supply valid colors for every fzf role")
        options = "--color=" + mode + "," + ",".join(f"{key}:{value}" for key, value in selected.items()) + "\n"
        if current_theme() != theme:
            continue
        if destination.is_file() and destination.read_text() == options:
            return
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(mode="w", dir=destination.parent, delete=False) as output:
                temporary = Path(output.name)
                os.fchmod(output.fileno(), 0o644)
                output.write(options)
            os.replace(temporary, destination)
        finally:
            if temporary is not None:
                temporary.unlink(missing_ok=True)
        return
    raise ValueError("Theme changed repeatedly while updating fzf; please retry")


try:
    destination.parent.mkdir(parents=True, exist_ok=True)
    lock = os.open(destination.parent, os.O_RDONLY)
    try:
        fcntl.flock(lock, fcntl.LOCK_EX)
        update()
    finally:
        os.close(lock)
except (OSError, ValueError, subprocess.CalledProcessError) as error:
    print(f"fzf theme update failed: {error}", file=sys.stderr)
    sys.exit(1)
PY
