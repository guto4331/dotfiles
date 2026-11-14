local wezterm = require("wezterm")

local config = wezterm.config_builder()
if wezterm.target_triple:find("windows") then
	config.default_prog = { "wsl.exe", "--cd", "~" }
end

config.enable_tab_bar = false
config.color_scheme = "Tokyo Night"
config.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Noto Sans Mono CJK JP",
})

local scroll_remainder_by_pane = {}
config.mouse_bindings = {}

for _, wheel in ipairs({ "WheelUp", "WheelDown" }) do
	table.insert(config.mouse_bindings, {
		event = { Down = { streak = 1, button = { [wheel] = 1 } } },
		mods = "NONE",
		alt_screen = false,
		action = wezterm.action_callback(function(window, pane)
			local direction = wheel == "WheelUp" and -1 or 1
			local delta = window:current_event().Down.button[wheel]
			local pane_id = pane:pane_id()
			local scaled_scroll = (scroll_remainder_by_pane[pane_id] or 0) + direction * delta * 3
			local lines = math.modf(scaled_scroll / 10)
			scroll_remainder_by_pane[pane_id] = scaled_scroll - lines * 10
			if lines ~= 0 then
				window:perform_action(wezterm.action.ScrollByLine(lines), pane)
			end
		end),
	})
end

return config
