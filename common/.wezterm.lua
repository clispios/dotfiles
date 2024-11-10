local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices
config.font = wezterm.font_with_fallback({
	{ family = "Iosevka Nerd Font", weight = "Regular" },
	"Noto Color Emoji",
	"Noto Sans CJK JP",
	"Noto Sans",
})
config.font_size = 13
--config.freetype_load_target = "VerticalLcd"
--config.freetype_render_target = "HorizontalLcd"
config.color_scheme = "Kanagawa (Gogh)" -- "tokyonight_night"

config.initial_cols = 120
config.initial_rows = 30
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
	left = 2,
	right = 2,
	top = 2,
	bottom = 2,
}

-- keybinds and tmux things
config.keys = {
	{
		key = "|",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "_",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	{
		key = "w",
		mods = "CTRL|SHIFT",
		action = wezterm.action.CloseCurrentPane({ confirm = true }),
	},
	{
		key = "l",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Right"),
	},
	{
		key = "h",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Left"),
	},
	{
		key = "j",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Down"),
	},
	{
		key = "k",
		mods = "CTRL|SHIFT",
		action = wezterm.action.ActivatePaneDirection("Up"),
	},
	{
		key = "b",
		mods = "CTRL|SHIFT",
		action = wezterm.action.RotatePanes("CounterClockwise"),
	},
	{
		key = "f",
		mods = "CTRL|SHIFT",
		action = wezterm.action.RotatePanes("Clockwise"),
	},
	{
		key = "LeftArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Left", 10 }),
	},
	{
		key = "RightArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Right", 10 }),
	},
	{
		key = "UpArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Up", 10 }),
	},
	{
		key = "DownArrow",
		mods = "CTRL|SHIFT",
		action = wezterm.action.AdjustPaneSize({ "Down", 10 }),
	},
	{
		key = "f",
		mods = "CTRL|SHIFT|ALT",
		action = wezterm.action.ToggleFullScreen,
	}, -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
	{ key = "LeftArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bb" }) },
	-- Make Option-Right equivalent to Alt-f; forward-word
	{ key = "RightArrow", mods = "OPT", action = wezterm.action({ SendString = "\x1bf" }) },
}

config.window_decorations = "NONE"
config.front_end = "WebGpu"
config.webgpu_power_preference = "HighPerformance"
config.max_fps = 144
-- wezterm.on("window-config-reloaded", function(window, _)
-- 	window:toast_notification("wezterm", "configuration reloaded! Nice!", nil, 1000)
-- end)
-- tab bar
-- config.window_decorations = "RESIZE"
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true

-- wezterm.on("window-config-reloaded", function(window, _)
-- 	window:toast_notification("wezterm", "configuration reloaded!", nil, 1000)
-- end)

-- and finally, return the configuration to wezterm
return config
