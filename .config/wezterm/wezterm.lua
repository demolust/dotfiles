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

config.quit_when_all_windows_are_closed = false
config.window_close_confirmation = "NeverPrompt"
config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = false
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

local custom_os_keys = {}

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  config.font_rules = {
    {
      intensity = "Bold",
      font = wezterm.font({ family = "LiterationMono Nerd Font", weight = "Regular" }),
    },
  }

  config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
  --config.window_decorations = "TITLE|RESIZE"

  local launch_menu = {}
  config.window_background_opacity = 0.80
  config.win32_system_backdrop = "Acrylic"

  -- Set Pwsh as the default on Windows
  -- Add `-NoLogo` to disable info at start & `--No-Profile` to disable personal profile
  config.default_prog = { "pwsh.exe" }

  table.insert(launch_menu, {
    label = "Pwsh",
    args = { "pwsh.exe" },
  })
  table.insert(launch_menu, {
    label = "posh_tmux",
    args = { "wsl.exe", "~", "-d", "posh_tmux" },
  })
  table.insert(launch_menu, {
    label = "lf",
    args = { "lf" },
  })
  table.insert(launch_menu, {
    label = "yazi",
    args = { "yazi" },
  })
  table.insert(launch_menu, {
    label = "openSUSE Tumbleweed",
    args = { "wsl.exe", "~", "-d", "openSUSE-Tumbleweed" },
  })
  table.insert(launch_menu, {
    label = "PowerShell",
    args = { "powershell.exe" },
  })
  table.insert(launch_menu, {
    label = "Git Bash (Windows)",
    args = { "C:/Program Files/Git/bin/bash.exe", "-i", "-l" },
  })
  table.insert(launch_menu, {
    label = "Debian",
    args = { "wsl.exe", "~", "-d", "Debian" },
  })
  table.insert(launch_menu, {
    label = "Ubuntu",
    args = { "wsl.exe", "~", "-d", "Ubuntu" },
  })
  config.launch_menu = launch_menu

  table.insert(custom_os_keys, {
    key = "e",
    mods = "ALT",
    action = act.SpawnCommandInNewTab {
      args = { "wsl.exe", "~", "-d", "posh_tmux" },
    },
  })
  table.insert(custom_os_keys, {
    key = "r",
    mods = "ALT",
    action = act.SpawnCommandInNewTab {
      args = { "lf" },
    },
  })
  table.insert(custom_os_keys, {
    key = "l",
    mods = "CTRL",
    action = act.Multiple {
      act.ClearScrollback "ScrollbackAndViewport",
      act.SendKey { key = "L", mods = "CTRL" },
    },
  })
  table.insert(custom_os_keys, {
    key = "L",
    mods = "CTRL",
    action = act.Multiple {
      act.ClearScrollback "ScrollbackAndViewport",
      act.SendKey { key = "L", mods = "CTRL" },
    },
  })

  table.insert(custom_os_keys, {
    key = "Tab",
    mods = "CTRL|SHIFT",
    action = act.SendKey {
      key = "Tab", mods = "ALT"
    },
  })
elseif wezterm.target_triple == "x86_64-unknown-linux-gnu" then
  local launch_menu = {}

  config.default_prog = { "tmux_chooser.sh" }

  table.insert(launch_menu, {
    label = "tmux",
    args = { "tmux_chooser.sh" },
  })
  table.insert(launch_menu, {
    label = "lf",
    args = { "lfi" },
  })
  table.insert(launch_menu, {
    label = "yazi",
    args = { "yazi" },
  })
  table.insert(launch_menu, {
    label = "zsh",
    args = { "zsh" },
  })
  table.insert(launch_menu, {
    label = "bash",
    args = { "bash" },
  })
  config.launch_menu = launch_menu

  table.insert(custom_os_keys, {
    key = "e",
    mods = "ALT",
    action = act.SpawnCommandInNewTab {
      args = { "zsh" },
    },
  })
  table.insert(custom_os_keys, {
    key = "r",
    mods = "ALT",
    action = act.SpawnCommandInNewTab {
      args = { "lfi" },
    },
  })

  config.skip_close_confirmation_for_processes_named = {
    "tmux_chooser.sh",
    "bash",
    "sh",
    "zsh",
    "fish",
    "tmux",
    "nu",
    "cmd.exe",
    "pwsh.exe",
    "powershell.exe",
  }
end

-- Mousing bindings
local mouse_bindings = {
  -- Change the default click behavior so that it only selects
  -- text and doesn't open hyperlinks
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = act.CompleteSelection("ClipboardAndPrimarySelection"),
  },

  -- and make CTRL-Click open hyperlinks
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "CTRL",
    action = act.OpenLinkAtMouseCursor,
  },
  {
    event = { Down = { streak = 3, button = "Left" } },
    action = wezterm.action.SelectTextAtMouseCursor("SemanticZone"),
    mods = "NONE",
  },
}

config.default_cursor_style = "SteadyBar"
config.mouse_bindings = mouse_bindings
config.disable_default_key_bindings = true

local custom_keys = {
  { key = "W",          mods = "ALT|SHIFT",  action = act.SpawnWindow },
  { key = "w",          mods = "ALT",        action = act.SpawnTab("CurrentPaneDomain") },
  { key = "q",          mods = "ALT",        action = act.ShowLauncher },
  { key = "d",          mods = "ALT",        action = act.SpawnCommandInNewTab { args = { "yazi" }, }, },
  { key = "s",          mods = "ALT",        action = act.ShowLauncherArgs { flags = "FUZZY|TABS" } },
  { key = "x",          mods = "ALT",        action = act.CloseCurrentTab { confirm = false } },
  { key = "<",          mods = "ALT|SHIFT",  action = act.MoveTabRelative(-1) },
  { key = ">",          mods = "ALT|SHIFT",  action = act.MoveTabRelative(1) },
  { key = "LeftArrow",  mods = "ALT|SHIFT",  action = act.ActivateTabRelative(-1) },
  { key = "RightArrow", mods = "ALT|SHIFT",  action = act.ActivateTabRelative(1) },
  { key = "h",          mods = "ALT",        action = act.ActivateTabRelative(-1) },
  { key = "l",          mods = "ALT",        action = act.ActivateTabRelative(1) },
  { key = "1",          mods = "ALT",        action = act.ActivateTab(0) },
  { key = "2",          mods = "ALT",        action = act.ActivateTab(1) },
  { key = "3",          mods = "ALT",        action = act.ActivateTab(2) },
  { key = "4",          mods = "ALT",        action = act.ActivateTab(3) },
  { key = "5",          mods = "ALT",        action = act.ActivateTab(4) },
  { key = "6",          mods = "ALT",        action = act.ActivateTab(5) },
  { key = "7",          mods = "ALT",        action = act.ActivateTab(6) },
  { key = "8",          mods = "ALT",        action = act.ActivateTab(7) },
  { key = "9",          mods = "ALT",        action = act.ActivateTab(8) },
  { key = "0",          mods = "ALT",        action = act.ActivateTab(9) },
  { key = "0",          mods = "CTRL",       action = act.ResetFontSize },
  { key = "-",          mods = "CTRL",       action = act.DecreaseFontSize },
  { key = "+",          mods = "CTRL|SHIFT", action = act.IncreaseFontSize },
  { key = "C",          mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
  { key = "V",          mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },
  { key = "M",          mods = "CTRL|SHIFT", action = act.ShowDebugOverlay },
  { key = "Enter",      mods = "ALT",        action = act.ToggleFullScreen },
  { key = "F11",        mods = "NONE",       action = act.ToggleFullScreen },
}

--https://gist.github.com/qizhihere/cb2a14432d9bf65693ad?permalink_comment_id=4108905#gistcomment-4108905
function table_merge(...)
  local tables_to_merge = { ... }
  assert(#tables_to_merge > 1, "There should be at least two tables to merge them")

  for k, t in ipairs(tables_to_merge) do
    assert(type(t) == "table", string.format("Expected a table as function parameter %d", k))
  end

  local result = tables_to_merge[1]

  for i = 2, #tables_to_merge do
    local from = tables_to_merge[i]
    for k, v in pairs(from) do
      if type(k) == "number" then
        table.insert(result, v)
      elseif type(k) == "string" then
        if type(v) == "table" then
          result[k] = result[k] or {}
          result[k] = table_merge(result[k], v)
        else
          result[k] = v
        end
      end
    end
  end

  return result
end

local new_custom_keys = table_merge(custom_keys, custom_os_keys)

config.keys = new_custom_keys

-- and finally, return the configuration to wezterm
return config
