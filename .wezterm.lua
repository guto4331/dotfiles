local wezterm = require("wezterm")

local config = wezterm.config_builder()
config.enable_tab_bar = false
config.color_scheme = "Tokyo Night"
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Noto Sans Mono CJK JP",
})

return config
