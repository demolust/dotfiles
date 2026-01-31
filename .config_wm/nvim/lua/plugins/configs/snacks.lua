local M = {}

M.opts = {
  -- Main indent module
  indent = {
    -- Passive guides config (The grey lines)
    indent = {
      enabled = true,
      priority = 1,
      char = "│",
      only_scope = false,
      only_current = false,
      hl = "SnacksIndent",
    },

    -- Active scope config (The current block)
    scope = {
      enabled = true,
      priority = 200,
      char = "│",
      underline = false,
      only_current = false,
      hl = "SnacksIndentScope",
    },

    -- Active scope animation config
    animate = {
      enabled = vim.fn.has("nvim-0.10") == 1,
      style = "out",
      easing = "linear",
      duration = { step = 20, total = 500 },
    },

    -- Chunk (Disabled)
    chunk = { enabled = false },

    -- Filter to apply indent
    -- buftype must be empty string "" (normal file)
    filter = function(buf)
      -- If buffer is not a normal file (e.g. terminal, help), disable
      if vim.bo[buf].buftype ~= "" then
        return false
      end

      -- Custom exclusion list
      local exclude_ft = {
        "help",
        "terminal",
        "lazy",
        "lspinfo",
        "TelescopePrompt",
        "TelescopeResults",
        "mason",
        "nvdash",
        "nvcheatsheet",
      }

      if vim.tbl_contains(exclude_ft, vim.bo[buf].filetype) then
        return false
      end

      return true
    end,
  },

  -- Enable terminal module
  terminal = {
    enabled = true,
    env = {
      WEZTERM_SHELL_SKIP_ALL = 1,
    },
    win = {
      style = "terminal",
    },
  },

  statuscolumn = {
    enabled = true,
    left = { "mark", "sign" },
    right = { "fold", "git" },
    folds = {
      open = true,
      git_hl = false,
    },
  },

  -- Enable Picker & explorer
  picker = {
    enabled = true,
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
        directory_stats = true,
        win = {
          list = {
            keys = {
              -- 0. Disable default Snacks keys
              ["m"] = false,           -- Disables default rename/move logic
              --["r"] = false,           -- Disables default rename (use R)
              ["a"] = false,           -- Disables default add (use % or d)
              ["y"] = false,           -- Disables default yank
              ["H"] = false,           -- Disables default toggle hidden files
              ["I"] = false,           -- Disables default toggle git ignore files
              ["<C-n>"] = false,       -- Disables move the selection to the next item
              ["<C-a>"] = false,       -- Disables select all
              -- Add new keybinds
              ["l"] = "confirm",          -- Open (right)
              ["h"] = "explorer_up",      -- Up (left)
              -- Add back some of the overwritten explorer keybinds with new ones
              ["O"] = "explorer_open",    -- Ooen with system
              -- Netrw like keys
              -- 1.  Navigation
              ["-"] = "explorer_up",      -- Up a directory
              ["<CR>"] = "confirm",       -- Open
              -- 2. File Operations
              ["%"] = "explorer_add",     -- New File (netrw style)
              ["d"] = "explorer_add",     -- New Directory (append /)
              ["R"] = "explorer_rename",  -- Rename
              ["D"] = "explorer_del",     -- Delete
              -- 3. Selection & Movement (The 'Mark' Workflow)
              --["mf"] = "select_and_next",     -- Mark file
              ["mf"] = {
                function()
                  local pickers = require("snacks").picker.get()
                  local p = pickers[1]
                  if not p then return end
                  local current = p.list.cursor
                  local total = p:count()
                  if current < total then
                    p:action("select_and_next")
                  else
                    p:action("select_and_next")
                    p:action("list_bottom")
                    p:update()
                  end
                end,
              },
              ["mF"] = {
                function()
                  local pickers = require("snacks").picker.get()
                  local p = pickers[1]
                  if not p then return end
                  local current = p.list.cursor
                  if current > 1 then
                    p:action("select_and_prev")
                  else
                    p:action("select_and_prev")
                    p:action("list_top")
                    p:update()
                  end
                end,
              },
              ["mu"] = {
                function()
                  local pickers = require("snacks").picker.get()
                  for _, p in ipairs(pickers) do
                    if p.list and p.list.set_selected then
                      p.list:set_selected({})
                    end
                    if p.list then
                      p.list.selected = {}
                      p.list.selected_map = {}
                    end
                    p:update()
                  end
                end,
                desc = "Unselect All",
                mode = { "n", "i" }
              },
              ["ma"] = "select_all",
              ["mm"] = "explorer_move",       -- Move marked files to current dir
              --["mc"] = "explorer_copy",       -- Copy marked files to current dir
              ["mc"] = {
                function()
                  local Snacks = require("snacks")
                  local p = Snacks.picker.get()[1] -- Get the active picker
                  if not p then return Snacks.notify.warn("No active picker") end
                  local Util = Snacks.picker.util
                  local paths = vim.tbl_map(Util.path, p:selected())
                  if #paths == 0 then return Snacks.notify.warn("No selection") end
                  local target = p:dir()
                  local msg = string.format("Copy %d file%s to %s?",
                    #paths, #paths > 1 and "s" or "", vim.fn.fnamemodify(target, ":~:."))
                  Util.confirm(msg, function()
                    Util.copy(paths, target)
                    require("snacks.explorer.tree"):refresh(target)
                    if p.list then
                      p.list:set_selected() -- Canonical clear method
                      p.list.selected, p.list.selected_map = {}, {} -- Safety wipe
                    end
                    p:find()
                  end)
                end,
              },
              ["md"] = "explorer_del",     -- Delete
              ["mD"] = {
                function()
                  local Snacks = require("snacks")
                  local p = Snacks.picker.get()[1] -- Get the active picker
                  if not p then return Snacks.notify.warn("No active picker") end
                  local Util = Snacks.picker.util
                  local paths = vim.tbl_map(Util.path, p:selected())
                  if #paths == 0 then return Snacks.notify.warn("No selection") end
                  local msg = string.format("Irreversibly delete %d file%s?",
                    #paths, #paths > 1 and "s" or "")
                  Util.confirm(msg, function()
                    for _, path in ipairs(paths) do
                      local res = vim.fn.delete(path, "rf")
                      if res ~= 0 then
                        Snacks.notify.error("Failed to delete " .. path)
                      end
                    end
                    require("snacks.explorer.tree"):refresh(p:dir())
                    if p.list then
                      p.list:set_selected()
                      p.list.selected, p.list.selected_map = {}, {}
                    end
                    p:find()
                  end)
                end,
              },
              -- 4. Layouts
              ["o"] = "edit_split",       -- Horizontal split
              ["v"] = "edit_vsplit",      -- Vertical split
              ["t"] = "edit_tab",         -- New tab
              ["p"] = "toggle_preview",   -- Toggle preview (like netrw 'p')
              -- Scroll Preview	<C-f> / <C-b>	preview_scroll_down / preview_scroll_up
              -- 5. Filtering & Visibility
              ["gh"] = "toggle_hidden",   -- Toggle hidden files manually
              ["ga"] = "toggle_ignored",  -- Toggle git-ignored files
              ["<C-l>"] = "refresh",      -- Refresh view
              ["s"] = _G.ExplorerActions.cycle_sort,
              ["r"] = _G.ExplorerActions.reverse_sort,
            },
          },
        },
      },
    },
  },
  explorer = {
    enabled = true,
    replace_netrw = true,
  },

  -- Enable other snacks with default configs
  input = { enabled = true },
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scroll = { enabled = true },

}

M.setup = function(_, opts)
  require("snacks").setup(opts)
end


return M
