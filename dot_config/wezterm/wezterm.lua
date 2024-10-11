-- Pull in the wezterm API
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Save and reload the configuration without restarting wezterm
local sm = require("wezterm-session-manager/session-manager")
wezterm.on("save_state", function(window, pane)
	sm.save_state(window, pane)
end)
wezterm.on("load_state", function()
	sm.load_state()
end)
wezterm.on("restore_state", function(window)
	sm.restore_state(window)
end)

-- Spawn a new fullscreen window when wezterm starts
wezterm.on("gui-startup", function(cmd)
	local tab, pane, window = mux.spawn_window(cmd or {})
	window:gui_window():maximize()
	sm.restore_state(window:gui_window())
end)

config.color_scheme = "Catppuccin Macchiato"
config.font = wezterm.font("JetBrains Mono", { weight = "Regular" })
config.font_size = 14
config.use_dead_keys = false
config.scrollback_lines = 5000
config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false
config.default_cursor_style = "BlinkingBar"
config.window_decorations = "RESIZE"
config.background = {
	{
		source = {
			File = wezterm.home_dir .. "/.config/wezterm/background.png",
		},
		hsb = {
			brightness = 0.15,
			saturation = 1.05,
			hue = 1.0,
		},
		width = "100%",
		height = "100%",
	},
	{
		source = {
			Color = "#282c35",
		},
		width = "100%",
		height = "100%",
		opacity = 0.45,
	},
}

config.inactive_pane_hsb = {
	brightness = 0.1,
	saturation = 0.8,
}

config.window_padding = {
	left = 3,
	right = 3,
	top = 0,
	bottom = 0,
}

-- tmux
config.disable_default_key_bindings = true
config.leader = { key = "q", mods = "ALT", timeout_milliseconds = 2000 }
config.keys = {
	-- save/load/reload window layout
	{ key = "S", mods = "LEADER", action = act({ EmitEvent = "save_state" }) },
	{ key = "L", mods = "LEADER", action = act({ EmitEvent = "load_state" }) },
	{ key = "R", mods = "LEADER", action = act({ EmitEvent = "restore_state" }) },
	{ key = "n", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "N", mods = "LEADER", action = act.SpawnWindow },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "f", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "d", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "b", mods = "LEADER", action = act.SendString("\x02") },
	{ key = "=", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	{ key = "Enter", mods = "LEADER", action = act.ActivateCopyMode },
	-- copy/paste to/from clipboard linux style
	{ key = "c", mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
	-- change tab name
	{
		key = ".",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Enter new name for the tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	-- toggle pane zoom state
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	-- active move_tab key table
	{ key = "m", mods = "LEADER", action = act.ActivateKeyTable({ name = "move_tab", one_shot = false }) },
	-- active resize_pane key table
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	-- open workspace launcher
	{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
	-- Prompt for a name to use for a new workspace and switch to it.
	{
		key = "W",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = wezterm.format({
				{ Attribute = { Intensity = "Bold" } },
				{ Foreground = { AnsiColor = "Fuchsia" } },
				{ Text = "Enter name for new workspace" },
			}),
			action = wezterm.action_callback(function(window, pane, line)
				-- line will be `nil` if they hit escape without entering anything
				-- An empty string if they just hit enter
				-- Or the actual line of text they wrote
				if line then
					window:perform_action(
						act.SwitchToWorkspace({
							name = line,
						}),
						pane
					)
				end
			end),
		}),
	},
}

-- tab switching with LEADER + number
for i = 1, 9 do
	-- leader + number to activate that tab
	table.insert(config.keys, {
		key = tostring(i),
		mods = "LEADER",
		action = wezterm.action.ActivateTab(i - 1),
	})
end

-- tab bar
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.tab_max_width = 60
config.show_new_tab_button_in_tab_bar = false
config.status_update_interval = 1000
--- config.tab_and_split_indices_are_zero_based = true

-- tmux status
wezterm.on("update-right-status", function(window, _)
	local SOLID_LEFT_ARROW = ""
	local ARROW_FOREGROUND = { Foreground = { Color = "#c6a0f6" } }
	local prefix = ""

	if window:leader_is_active() then
		prefix = " " .. utf8.char(0x1f30a) -- ocean wave
		SOLID_LEFT_ARROW = utf8.char(0xe0b2)
	end

	if window:active_tab():tab_id() ~= 0 then
		ARROW_FOREGROUND = { Foreground = { Color = "#1e2030" } }
	end -- arrow color based on if tab is first pane

	window:set_left_status(wezterm.format({
		{ Background = { Color = "#b7bdf8" } },
		{ Text = prefix },
		ARROW_FOREGROUND,
		{ Text = SOLID_LEFT_ARROW },
	}))

	window:set_right_status(window:active_workspace())
end)

config.key_tables = {
	resize_pane = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
	move_tab = {
		{ key = "h", action = act.MoveTabRelative(-1) },
		{ key = "j", action = act.MoveTabRelative(-1) },
		{ key = "k", action = act.MoveTabRelative(1) },
		{ key = "l", action = act.MoveTabRelative(1) },
		{ key = "Escape", action = "PopKeyTable" },
		{ key = "Enter", action = "PopKeyTable" },
	},
}

-- and finally, return the configuration to wezterm
return config
