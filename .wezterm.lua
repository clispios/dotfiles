-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font = wezterm.font("Iosevka Nerd Font", { weight = "DemiBold" })
config.font_size = 15
--config.freetype_load_target = "VerticalLcd"
--config.freetype_render_target = "HorizontalLcd"
config.color_scheme = "tokyonight_night"

config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.window_frame = {
	font = require("wezterm").font("Iosevka Nerd Font Mono", { weight = "ExtraBold" }),
	font_size = 11,
	--active_titlebar_bg = "#333333",
	--inactive_titlebar_bg = "#333333",
}

-- wezterm.on("maximize-active-window", function(window, _)
-- 	window:toast_notification("wezterm", "ahhhhh!", nil, 4000)
-- 	window:maximize()
-- end)

config.colors = {
	tab_bar = {
		active_tab = {
			bg_color = "#333333",
			fg_color = "#ffffff",
		},
	},
}

config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}

config.keys = {
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	{
		key = "f",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.ToggleFullScreen,
	},
}

config.window_decorations = "RESIZE"

wezterm.on("window-config-reloaded", function(window, _)
	window:toast_notification("wezterm", "configuration reloaded!", nil, 1000)
end)

-- and finally, return the configuration to wezterm
return config
