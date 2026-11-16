# lazygit.yazi
Plugin for [Yazi](https://github.com/sxyazi/yazi) to manage git repos with [lazygit](https://github.com/jesseduffield/lazygit)

## Local maintenance

This checkout includes local fixes for process errors and terminal restoration.
Its revision is pinned in `package.toml` so `ya pkg upgrade` will not replace
those fixes. Keep the tracked copy when restoring these dotfiles; review the
local changes before deliberately reinstalling or upgrading this plugin.

## Dependencies
Make sure [lazygit](https://github.com/jesseduffield/lazygit) is installed and in your `PATH`.
## Installation

### Using `ya pkg`
```
 ya pkg add Lil-Dank/lazygit
```

### Manual
**Linux/macOS**
```
git clone https://github.com/Lil-Dank/lazygit.yazi.git ~/.config/yazi/plugins/lazygit.yazi
```
**Windows**
```
git clone https://github.com/Lil-Dank/lazygit.yazi.git %AppData%\yazi\config\plugins\lazygit.yazi
```
## Configuration
add this to your **keymap.toml** file
```toml
[[mgr.prepend_keymap]]
on   = [ "g", "i" ]
run  = "plugin lazygit"
desc = "run lazygit"
```
you can customize the keybinding however you like. Please refer to the [keymap.toml](https://yazi-rs.github.io/docs/configuration/keymap) documentation
