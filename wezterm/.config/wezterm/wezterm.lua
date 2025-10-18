-- WezTerm Keybindings Documentation by dragonlobster
-- ===================================================
-- Leader Key:
-- The leader key is set to ALT + q, with a timeout of 2000 milliseconds (2 seconds).
-- To execute any keybinding, press the leader key (ALT + q) first, then the corresponding key.

-- Keybindings:
-- 1. Tab Management:
--    - LEADER + c: Create a new tab in the current pane's domain.
--    - LEADER + x: Close the current pane (with confirmation).
--    - LEADER + b: Switch to the previous tab.
--    - LEADER + n: Switch to the next tab.
--    - LEADER + <number>: Switch to a specific tab (1–9).

-- 2. Pane Splitting:
--    - LEADER + |: Split the current pane horizontally into two panes.
--    - LEADER + \: Split the current pane vertically into two panes.
-- 3. Pane Navigation:
--    - LEADER + h: Move to the pane on the left.
--    - LEADER + j: Move to the pane below.
--    - LEADER + k: Move to the pane above.
--    - LEADER + l: Move to the pane on the right.

-- 4. Pane Resizing:
--    - LEADER + LeftArrow: Increase the pane size to the left by 5 units.
--    - LEADER + RightArrow: Increase the pane size to the right by 5 units.
--    - LEADER + DownArrow: Increase the pane size downward by 5 units.
--    - LEADER + UpArrow: Increase the pane size upward by 5 units.

-- 5. Status Line:
--    - The status line indicates when the leader key is active, displaying an ocean wave emoji (🌊).

-- Miscellaneous Configurations:
-- - Tabs are shown even if there's only one tab.
-- - The tab bar is located at the bottom of the terminal window.
-- - Tab and split indices are zero-based.

-- Pull in the wezterm API
local wezterm = require("wezterm")

-- Session manager API
local session_manager = require("wezterm-session-manager/session-manager")
-- Session manager functions
wezterm.on("save_session", function(window)
	session_manager.save_state(window)
end)
wezterm.on("load_session", function(window)
	session_manager.load_state(window)
end)
wezterm.on("restore_session", function(window)
	session_manager.restore_state(window)
end)

-- This table will hold the configuration.
local config = {}

config.enable_wayland = true

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- max fps
config.max_fps = 120
config.animation_fps = 120

--[[
============================
Custom Configuration
============================
]]
--

-- Rounded or Square Style Tabs

-- change to square if you don't like rounded tab style
local tab_style = "square"

-- leader active indicator prefix
local leader_prefix = utf8.char(0x1f30a) -- ocean wave

--[[
============================
Font
============================
]]
--

config.font = wezterm.font_with_fallback({ "JetBrainsMono Nerd Font Mono", "JetBrains Mono" })
config.font_size = 14

config.window_decorations = "RESIZE | TITLE"

--[[
============================
Colors
============================
]]
--

local color_scheme = "Catppuccin Macchiato"
config.color_scheme = color_scheme

-- color_scheme not sufficient in providing available colors
-- local colors = wezterm.color.get_builtin_schemes()[color_scheme]

-- color scheme colors for easy access
local scheme_colors = {
	catppuccin = {
		macchiato = {
			rosewater = "#f4dbd6",
			flamingo = "#f0c6c6",
			pink = "#f5bde6",
			mauve = "#c6a0f6",
			red = "#ed8796",
			maroon = "#ee99a0",
			peach = "#f5a97f",
			yellow = "#eed49f",
			green = "#a6da95",
			teal = "#8bd5ca",
			sky = "#91d7e3",
			sapphire = "#7dc4e4",
			blue = "#8aadf4",
			lavender = "#b7bdf8",
			text = "#cad3f5",
			crust = "#181926",
		},
	},
}

local colors = {
	border = scheme_colors.catppuccin.macchiato.crust,
	tab_bar_active_tab_fg = scheme_colors.catppuccin.macchiato.lavender,
	tab_bar_active_tab_bg = scheme_colors.catppuccin.macchiato.crust,
	tab_bar_text = scheme_colors.catppuccin.macchiato.crust,
	arrow_foreground_leader = scheme_colors.catppuccin.macchiato.lavender,
	arrow_background_leader = scheme_colors.catppuccin.macchiato.crust,
}

--[[
============================
Border
============================
]]
--

config.window_frame = {
	border_left_width = "0.4cell",
	border_right_width = "0.4cell",
	border_bottom_height = "0.15cell",
	border_top_height = "0.15cell",
	border_left_color = colors.border,
	border_right_color = colors.border,
	border_bottom_color = colors.border,
	border_top_color = colors.border,
}

--[[
============================
Shortcuts
============================
]]
--

-- shortcut_configuration
config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 2000 }
config.keys = {
	-- Session manager bindings
	{
		key = "s",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ EmitEvent = "save_session" }),
	},
	{
		key = "L",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ EmitEvent = "load_session" }),
	},
	{
		key = "R",
		mods = "LEADER|SHIFT",
		action = wezterm.action({ EmitEvent = "restore_session" }),
	},
	{
		key = "$",
		mods = "LEADER|SHIFT",
		action = wezterm.action.PromptInputLine({
			description = "Enter new name for session",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					mux.rename_workspace(window:mux_window():get_workspace(), line)
				end
			end),
		}),
	},
	-- Attach to muxer
	{
		key = "a",
		mods = "LEADER",
		action = wezterm.action.AttachDomain("unix"),
	},

	-- Detach from muxer
	{
		key = "d",
		mods = "LEADER",
		action = wezterm.action.DetachDomain({ DomainName = "unix" }),
	},
	{
		key = "s",
		mods = "LEADER",
		action = wezterm.action.ShowLauncherArgs({ flags = "WORKSPACES|DOMAINS" }),
	},
	{
		mods = "LEADER",
		key = "[",
		action = wezterm.action.SwitchWorkspaceRelative(1),
	},
	{
		mods = "LEADER",
		key = "]",
		action = wezterm.action.SwitchWorkspaceRelative(-1),
	},
	{
		mods = "LEADER",
		key = "t",
		action = wezterm.action.SpawnTab("CurrentPaneDomain"),
	},
	{
		mods = "LEADER",
		key = "c",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{ key = "v", mods = "CTRL", action = wezterm.action.PasteFrom("Clipboard") },
	{
		key = "q",
		mods = "CTRL|SHIFT",
		action = wezterm.action.QuitApplication,
	},
	{
		mods = "LEADER",
		key = "b",
		action = wezterm.action.ActivateTabRelative(-1),
	},
	{
		mods = "LEADER",
		key = "n",
		action = wezterm.action.ActivateTabRelative(1),
	},
	{
		mods = "LEADER",
		key = "\\",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER|SHIFT",
		key = "|",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		mods = "LEADER",
		key = "h",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		mods = "LEADER",
		key = "j",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		mods = "LEADER",
		key = "k",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		mods = "LEADER",
		key = "l",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		mods = "LEADER",
		key = "LeftArrow",
		action = wezterm.action.AdjustPaneSize({ "Left", 5 }),
	},
	{
		mods = "LEADER",
		key = "RightArrow",
		action = wezterm.action.AdjustPaneSize({ "Right", 5 }),
	},
	{
		mods = "LEADER",
		key = "DownArrow",
		action = wezterm.action.AdjustPaneSize({ "Down", 5 }),
	},
	{
		mods = "LEADER",
		key = "UpArrow",
		action = wezterm.action.AdjustPaneSize({ "Up", 5 }),
	},
	-- Ctrl + Backspace → delete previous word in Neovim
	{ key = "Backspace", mods = "CTRL", action = wezterm.action.SendString("\x17") },

	-- Ctrl + Left → move back one word
	{ key = "LeftArrow", mods = "CTRL", action = wezterm.action.SendString("\x1bb") },

	-- Ctrl + Right → move forward one word
	{ key = "RightArrow", mods = "CTRL", action = wezterm.action.SendString("\x1bw") },
}

for i = 1, 9 do
	-- leader + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

--[[
============================
Tab Bar
============================
]]
--

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = false
config.use_fancy_tab_bar = true
config.tab_and_split_indices_are_zero_based = true

local function tab_title(tab_info)
	local title = tab_info.tab_title
	-- if the tab title is explicitly set, take that
	if title and #title > 0 then
		return title
	end
	-- Otherwise, use the title from the active pane
	-- in that tab
	return tab_info.active_pane.title
end

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- Visual indicator for tabs attached to the unix domain
	local domain_name = tab.active_pane.domain_name or ""
	local unix_indicator = (domain_name == "unix") and "🌐 " or ""

	local title = " " .. unix_indicator .. tab_title(tab) .. " "
	local left_edge_text = ""
	local right_edge_text = ""

	if tab.is_active then
		return {
			{ Background = { Color = colors.tab_bar_active_tab_bg } },
			{ Foreground = { Color = colors.tab_bar_active_tab_fg } },
			{ Text = left_edge_text },
			{ Background = { Color = colors.tab_bar_active_tab_fg } },
			{ Foreground = { Color = colors.tab_bar_text } },
			{ Text = title },
			{ Background = { Color = colors.tab_bar_active_tab_bg } },
			{ Foreground = { Color = colors.tab_bar_active_tab_fg } },
			{ Text = right_edge_text },
		}
	else
		return {
			{ Text = left_edge_text },
			{ Text = title },
			{ Text = right_edge_text },
		}
	end
end)

--[[
============================
Leader Active Indicator
============================
]]
--

wezterm.on("update-status", function(window, _)
	-- leader inactive
	local solid_left_arrow = ""
	local arrow_foreground = { Foreground = { Color = colors.arrow_foreground_leader } }
	local arrow_background = { Background = { Color = colors.arrow_background_leader } }
	local prefix = ""

	-- leaader is active
	if window:leader_is_active() then
		prefix = " " .. leader_prefix

		if tab_style == "rounded" then
			solid_left_arrow = wezterm.nerdfonts.ple_right_half_circle_thick
		else
			solid_left_arrow = wezterm.nerdfonts.pl_left_hard_divider
		end

		local tabs = window:mux_window():tabs_with_info()

		if tab_style ~= "rounded" then
			for _, tab_info in ipairs(tabs) do
				if tab_info.is_active and tab_info.index == 0 then
					arrow_background = { Foreground = { Color = colors.tab_bar_active_tab_fg } }
					solid_left_arrow = wezterm.nerdfonts.pl_right_hard_divider
					break
				end
			end
		end
	end

	window:set_left_status(wezterm.format({
		{ Background = { Color = colors.arrow_foreground_leader } },
		{ Text = prefix },
		arrow_foreground,
		arrow_background,
		{ Text = solid_left_arrow },
	}))
end)

config.unix_domains = {
	{
		-- The name; must be unique amongst all domains
		name = "unix",

		-- The path to the socket.  If unspecified, a reasonable default
		-- value will be computed.

		-- socket_path = "/some/path",

		-- If true, do not attempt to start this server if we try and fail to
		-- connect to it.

		-- no_serve_automatically = false,

		-- If true, bypass checking for secure ownership of the
		-- socket_path.  This is not recommended on a multi-user
		-- system, but is useful for example when running the
		-- server inside a WSL container but with the socket
		-- on the host NTFS volume.

		-- skip_permissions_check = false,
	},
}

-- This causes `wezterm` to act as though it was started as
-- `wezterm connect unix` by default, connecting to the unix
-- domain on startup.
-- If you prefer to connect manually, leave out this line.

--config.default_gui_startup_args = { "connect", "unix" }

config.show_tab_index_in_tab_bar = false
-- and finally, return the configuration to wezterm
return config
