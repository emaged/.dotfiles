local home = os.getenv("HOME") or ""

-- Replace conflicting Omarchy defaults.
hl.unbind("SUPER + J")
hl.unbind("SUPER + K")
hl.unbind("SUPER + L")
hl.unbind("SUPER + ALT + K")

o.bind("SUPER + SHIFT + V", "VS Code", "code")

o.bind(
  "SUPER + CTRL + SHIFT + L",
  "Toggle workspace layout",
  "omarchy-hyprland-workspace-layout-toggle"
)
o.bind("SUPER + CTRL + J", "Toggle window split", hl.dsp.layout("togglesplit"))
o.bind("SUPER + B", "Show key bindings", "omarchy-menu-keybindings")

o.bind("SUPER + ALT + B", "Tmux keybindings", "omarchy-menu-tmux-keybindings")

-- Toggle Hyprbars when the plugin is loaded.
o.bind(
  "SUPER + ALT + T",
  "Toggle window bars",
  [[bash -c 'hyprctl keyword plugin:hyprbars:enabled $(hyprctl getoption plugin:hyprbars:enabled -j | jq -r ".int | if . == 1 then 0 else 1 end")']]
)

-- Vim-style focus movement.
o.bind("SUPER + H", "Move focus left", hl.dsp.focus({ direction = "l" }))
o.bind("SUPER + L", "Move focus right", hl.dsp.focus({ direction = "r" }))
o.bind("SUPER + K", "Move focus up", hl.dsp.focus({ direction = "u" }))
o.bind("SUPER + J", "Move focus down", hl.dsp.focus({ direction = "d" }))

-- Vim-style group movement.
o.bind("SUPER + ALT + H", "Move window to group on left", hl.dsp.window.move({ into_group = "l" }))
o.bind("SUPER + ALT + L", "Move window to group on right", hl.dsp.window.move({ into_group = "r" }))
o.bind("SUPER + ALT + K", "Move window to group on top", hl.dsp.window.move({ into_group = "u" }))
o.bind("SUPER + ALT + J", "Move window to group on bottom", hl.dsp.window.move({ into_group = "d" }))

-- Vim-style window movement.
o.bind("SUPER + SHIFT + H", "Move window left", hl.dsp.window.move({ direction = "l" }))
o.bind("SUPER + SHIFT + L", "Move window right", hl.dsp.window.move({ direction = "r" }))
o.bind("SUPER + SHIFT + K", "Move window up", hl.dsp.window.move({ direction = "u" }))
o.bind("SUPER + SHIFT + J", "Move window down", hl.dsp.window.move({ direction = "d" }))

-- Brightness controls.
o.bind("SUPER + F11", "Toggle brightness off", home .. "/.local/scripts/brightness-off")
o.bind("SUPER + F12", "Toggle brightness max", home .. "/.local/scripts/brightness-max")
