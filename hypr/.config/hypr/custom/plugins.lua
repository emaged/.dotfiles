local home = os.getenv("HOME") or ""

local function hyprbars_theme_colors()
  local colors = {
    hyprbarForeground = "rgb(cdd6f4)",
    hyprbarBackground = "rgb(585b70)",
    hyprbarClose = "rgb(f38ba8)",
    hyprbarFullscreen = "rgb(f9e2af)",
    hyprbarFloat = "rgb(89b4fa)",
  }
  local theme = io.open(home .. "/.local/state/omarchy/current/theme/hyprbars.conf", "r")

  if theme then
    for line in theme:lines() do
      local name, value = line:match("^%s*%$(hyprbar[%w]+)%s*=%s*(.-)%s*$")
      if name and value then
        colors[name] = value
      end
    end
    theme:close()
  end

  return colors
end

-- Load enabled hyprpm plugins at startup, then re-read this config once their
-- Lua APIs and configuration options have been registered.
o.exec_on_start("hyprpm reload -n && hyprctl reload")

-- The first startup config pass happens before hyprpm loads the plugin.
if hl.plugin.hyprbars then
  local colors = hyprbars_theme_colors()

  hl.config({
    plugin = {
      hyprbars = {
        enabled = true,
        bar_height = 25,
        bar_color = colors.hyprbarBackground,
        col = { text = colors.hyprbarForeground },
        bar_text_size = 11,
        bar_text_font = "JetBrainsMono Nerd Font Mono Bold",
        bar_text_align = "center",
        bar_precedence_over_border = true,
      },
    },
  })

  hl.plugin.hyprbars.add_button({
    bg_color = colors.hyprbarClose,
    fg_color = colors.hyprbarForeground,
    size = 15,
    icon = "",
    action = [[hyprctl dispatch 'hl.dsp.window.close()']],
  })
  hl.plugin.hyprbars.add_button({
    bg_color = colors.hyprbarFullscreen,
    fg_color = colors.hyprbarForeground,
    size = 15,
    icon = "",
    action = [[hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" })']],
  })
  hl.plugin.hyprbars.add_button({
    bg_color = colors.hyprbarFloat,
    fg_color = colors.hyprbarForeground,
    size = 15,
    icon = "",
    action = [[hyprctl dispatch 'hl.dsp.window.float({ action = "toggle" })']],
  })

  -- Browsers already draw their own window chrome.
  o.window({ tag = "firefox-based-browser" }, { ["hyprbars:no_bar"] = true })
  o.window({ tag = "chromium-based-browser" }, { ["hyprbars:no_bar"] = true })

  -- Keep floating terminals and their title bars opaque.
  o.window({ tag = "terminal", float = true }, { opacity = "1.0 1.0" })
end
