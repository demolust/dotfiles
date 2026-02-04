-----------------------------------------------------------
-- Plugin Mappings
-----------------------------------------------------------

local M = {}
local map = vim.keymap.set

-- Noice
map("n", "<leader>nh", "<cmd> Noice history <CR>", {desc = "Notifications history" })
-- Clear all notifications and messages
map("n", "<leader>nd", function()
  require("noice").cmd("dismiss")
end, { desc = "Dismiss all notifications" })

-- Set lint using nvim-lint
map("n", "<leader>ci", function() require("lint").try_lint() end, { desc = "Lintting" })

-- Gitsigns
M.gitsigns = {
  -- Navigation through hunks
  {
    "]c",
    function()
      if vim.wo.diff then return "]c" end
      vim.schedule(function() require("gitsigns").next_hunk() end)
      return "<Ignore>"
    end,
    desc = "Jump to next hunk",
    expr = true,
  },
  {
    "[c",
    function()
      if vim.wo.diff then return "[c" end
      vim.schedule(function() require("gitsigns").prev_hunk() end)
      return "<Ignore>"
    end,
    desc = "Jump to prev hunk",
    expr = true,
  },

  -- Actions
  {
    "<leader>gH",
    function() require("gitsigns").reset_hunk() end,
    desc = "Reset hunk",
  },
  {
    "<leader>gh",
    function() require("gitsigns").preview_hunk() end,
    desc = "Preview hunk",
  },
  {
    "<leader>gB",
    function() require("gitsigns").blame_line() end,
    desc = "Blame line",
  },
  {
    "<leader>gD",
    function() require("gitsigns").toggle_deleted() end,
    desc = "Toggle deleted",
  },
}

-- Folding
M.ufo = {
  { "zR", function() require("ufo").openAllFolds() end, desc = "Open all folds" },
  { "zM", function() require("ufo").closeAllFolds() end, desc = "Close all folds" },
  { "zr", function() require("ufo").openFoldsExceptKinds() end, desc = "Open folds except kinds" },
  { "zm", function() require("ufo").closeFoldsWith() end, desc = "Close folds with" },
  { "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, desc = "Peek fold" },
}

-- Trouble.nvim (Diagnostics & Lists)
M.trouble = {
  {
    "<leader>tx",
    "<cmd> Trouble diagnostics toggle <cr>",
    desc = "Diagnostics (Trouble)",
  },
  {
    "<leader>tX",
    "<cmd> Trouble diagnostics toggle filter.buf=0 <cr>",
    desc = "Buffer Diagnostics (Trouble)",
  },
  {
    "<leader>ts",
    "<cmd> Trouble symbols toggle focus=false <cr>",
    desc = "Symbols (Trouble)",
  },
  {
    "<leader>tl",
    "<cmd> Trouble lsp toggle focus=false win.position=right <cr>",
    desc = "LSP Definitions / references / ... (Trouble)",
  },
  {
    "<leader>tL",
    "<cmd> Trouble loclist toggle <cr>",
    desc = "Location List (Trouble)",
  },
  {
    "<leader>tQ",
    "<cmd> Trouble qflist toggle <cr>",
    desc = "Quickfix List (Trouble)",
  },
}

-- Snacks
M.snacks = {
  -- Notifier
  -- Needs snacks.notifier
  --{ "<leader>uN", function() Snacks.notifier.show_history() end, desc = "Notification History" },
  --{ "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
  -- Scratch Buffers (Quick notes)
  { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
  { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
  -- Rename file using LSP
  { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },
  -- Terminal toggles
  {
    "<leader>h",
    function()
      Snacks.terminal(nil, { win = { position = "bottom", height = 0.4 } })
    end,
    desc = "New horizontal term",
  },
  {
    "<leader>v",
    function()
      Snacks.terminal(nil, { win = { position = "right", width = 0.4 } })
    end,
    desc = "New vertical term",
  },
  {
    "<leader>o",
    function()
      Snacks.terminal(nil, { win = { style = "float" } })
    end,
    desc = "New float term",
  },

  -- Picker
  -- Needs snacks.notifier
  --{ "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
  -- Needs snacks.explorer
  { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },
  { "<C-n>", function() Snacks.explorer() end, desc = "File Explorer" },

  -- 1. Global & Quick Access
  { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
  { "<leader>,", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
  { "<leader>/", function() Snacks.picker.grep() end, desc = "Live Grep (Search Normal Files)" },
  { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },

  -- 2. FIND Logic (Containers & Locations)
  { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
  { "<leader>fa", function() Snacks.picker.files({ hidden = true, ignored = true }) end, desc = "Find All Files (Hidden/Ignored)" },
  { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files Tracked By Git" },
  { "<leader>fp", function() Snacks.picker.projects() end, desc = "Find Projects" },
  { "<leader>fr", function() Snacks.picker.recent() end, desc = "Find Recent Opened Files" },
  { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
  { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },

  -- 3. GIT Logic (Version Control)
  { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
  { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Commit Log" },
  { "<leader>gL", function() Snacks.picker.git_log_line() end, desc = "Git Log Line" },
  { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
  { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
  { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
  { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Log File" },

  -- 4. GitHub (gh-cli)
  { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = "GitHub Issues (open)" },
  { "<leader>gI", function() Snacks.picker.gh_issue({ state = "all" }) end, desc = "GitHub Issues (all)" },
  { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "GitHub Pull Requests (open)" },
  { "<leader>gP", function() Snacks.picker.gh_pr({ state = "all" }) end, desc = "GitHub Pull Requests (all)" },

  -- 5. SEARCH Logic (Content & Internal State)
  -- A. Content Search
  { "<leader>sg", function() Snacks.picker.grep() end, desc = "Live Grep (Search Normal Files)" },
  { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Grep Word/Selection", mode = { "n", "x" } },
  { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
  {
    "<leader>sb",
    function()
      Snacks.picker.lines({
        layout = {
          preset = "default",
          preview = true,
        }
      })
    end,
    desc = "Fuzzy Search In Current Buffer"
  },

  -- B. System & Documentation
  { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
  { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
  { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Search Autocmds" },
  { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Search Keymaps" },
  { "<leader>su", function() Snacks.picker.undo() end, desc = "Search Undo History" },
  { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Search Highlights" },
  { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
  { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics" },
  { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Search Buffer Diagnostics" },
  -- Will need to first poulate the loclist using `vim.diagnostic.setloclist()`
  { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Search Diagnostic messages in current buffer window" },

  -- C. History, Registers & Lists
  { '<leader>s"', function() Snacks.picker.registers() end, desc = "Search Registers" },
  { "<leader>sC", function() Snacks.picker.commands() end, desc = "Search All Commands" },
  { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Search Command History" },
  { '<leader>s/', function() Snacks.picker.search_history() end, desc = "Search VimSearch History" },
  { "<leader>sm", function() Snacks.picker.marks() end, desc = "Search All Marks" },
  { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Search All Jumps" },
  { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Search Quickfix List" },
  { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },

  -- 6. Design & UI
  { "<leader>si", function() Snacks.picker.icons() end, desc = "Search Icons" },
  { "<leader>uC", function() Snacks.picker.colorschemes() end, desc = "Search & Select Colorschemes" },
  { "<leader>uh", function() Snacks.toggle.line_number():toggle() end, desc = "Toggle Line Numbers" },
  { "<leader>ud", function() Snacks.toggle.diagnostics():toggle() end, desc = "Toggle Diagnostics" },
  { "<leader>us", function() Snacks.toggle.scroll():toggle() end, desc = "Toggle Smooth Scroll" },

  -- 7. LSP
  { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
  { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
  { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
  { "gi", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
  { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
  { "gai", function() Snacks.picker.lsp_incoming_calls() end, desc = "C[a]lls Incoming" },
  { "gao", function() Snacks.picker.lsp_outgoing_calls() end, desc = "C[a]lls Outgoing" },
  { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
  { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },

  -- Lazygit
  { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },

  -- Custom commands
  -- Search installed treesitter parsers
  {
    "<leader>st",
    function()
      local items = vim.tbl_map(function(path)
        return {
          text = vim.fn.fnamemodify(path, ":t:r"),
          data = path
        }
      end, vim.api.nvim_get_runtime_file("parser/*.so", true))

      table.sort(items, function(a, b) return a.text < b.text end)

      Snacks.picker.pick({
        source = "treesitter_parsers",
        title = "Installed Treesitter Parsers",
        items = items,
        layout = { preset = "default", preview = false }, -- or select
        format = "text",
        confirm = function(picker, item)
          -- Default action on <CR>
          picker:close()
          vim.notify("Selected: " .. item.text)
        end,
      })
    end,
    desc = "Search installed TS parsers",
  },

  -- Diagnostics complementation (Overlapping with Search B part)
  { "<leader>cd", function() Snacks.picker.diagnostics() end, desc = "Search Diagnostics" },
  { "<leader>cD", function() Snacks.picker.diagnostics_buffer() end, desc = "Search Buffer Diagnostics" },
  -- Will need to first poulate the loclist using `vim.diagnostic.setloclist()`
  { "<leader>cL", function() Snacks.picker.loclist() end, desc = "Search Diagnostic messages in current buffer window" },

  -- Buffer complementation (Overlapping with Find definions & Quick access)
  { "<leader>bl", function() Snacks.picker.buffers() end, desc = "Find Buffers" },
  { "<leader>bx", function() Snacks.bufdelete() end, desc = "Close Buffer" },
  { "<leader>bX", function() Snacks.bufdelete.all() end, desc = "Close All Buffers" },

}

-- WhichKey
M.whichkey = {
  {
    "<leader>wK",
    function()
      vim.cmd("WhichKey")
    end,
    desc = "Which-key all keymaps",
  },
  {
    "<leader>wk",
    function()
      local input = vim.fn.input("WhichKey: ")
      vim.cmd("WhichKey " .. input)
    end,
    desc = "Which-key query lookup",
  },
  {
    "<leader>?",
    function()
      require("which-key").show({ global = true })
    end,
    desc = "Buffer Local Keymaps (Cheatsheet)",
  },
}

-- LSP specific mappings to be used in on_attach
M.lspconfig = {
  -- Only to be used when not having snacks plugin
  --{ "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
  --{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
  --{ "gr", vim.lsp.buf.references, desc = "References" },
  --{ "gi", vim.lsp.buf.implementation, desc = "Goto Implementation" },
  --{ "gy", vim.lsp.buf.type_definition, desc = "Goto Type Definition" },
  { "K", vim.lsp.buf.hover, desc = "Hover function info" },
  { "<leader>ls", vim.lsp.buf.signature_help, desc = "LSP signature help" },
  { "<leader>cr", vim.lsp.buf.rename, mode = { "n", "v" }, desc = "Rename variable/function" },
  { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "v" }, desc = "LSP code action" },
  {
    "<leader>wa",
    function()
      vim.lsp.buf.add_workspace_folder()
    end,
    desc = "Add workspace folder",
  },
  {
    "<leader>wr",
    function()
      vim.lsp.buf.remove_workspace_folder()
    end,
    desc = "Remove workspace folder",
  },
  {
    "<leader>wl",
    function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end,
    desc = "List workspace folders",
  },
}

-- Conform
M.conform = {
  {
    "<leader>cf",
    function()
      require("conform").format({ async = true, lsp_fallback = true })
    end,
    desc = "Format",
  },
}

-- DAP (General)
M.dap = {
  { "<leader>db", "<cmd> DapToggleBreakpoint <CR>", desc = "Add breakpoint at line" },
  { "<leader>dr", "<cmd> DapContinue <CR>", desc = "Start or continue the debugger" },
  {
    "<leader>ds",
    function()
      local widgets = require("dap.ui.widgets")
      local sidebar = widgets.sidebar(widgets.scopes)
      sidebar.open()
    end,
    desc = "Open debugging sidebar",
  },
}

-- DAP Python
M.dap_python = {
  {
    "<leader>dp",
    function()
      require("dap-python").test_method()
    end,
    desc = "Debug python",
  },
}

-- DAP Go
M.dap_go = {
  {
    "<leader>dgt",
    function()
      require("dap-go").debug_test()
    end,
    desc = "Debug go test",
  },
  {
    "<leader>dgl",
    function()
      require("dap-go").debug_last()
    end,
    desc = "debug last go test",
  },
}

return M
