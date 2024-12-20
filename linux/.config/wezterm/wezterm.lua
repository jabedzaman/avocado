local wezterm = require 'wezterm'
local config = {}

config.font = wezterm.font("Dank Mono Italic", {weight="Regular"})

return {
    color_scheme = "Dracula (Official)",
    tab_bar_at_bottom = true,
    use_fancy_tab_bar = false,
    window_decorations = "RESIZE"
}
