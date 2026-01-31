-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action
local mux = wezterm.mux

wezterm.on("gui-startup", function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

config.font = wezterm.font({ family = "LiterationMono Nerd Font", weight = "Regular" })
config.font_size = 18

config.quit_when_all_windows_are_closed = true
config.window_close_confirmation = "neverprompt"
config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

-- and finally, return the configuration to wezterm
return config
