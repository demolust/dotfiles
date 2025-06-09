local opt = vim.opt
local g = vim.g

-------------------------------------- globals -----------------------------------------
g.mapleader = " "
g.maplocalleader = "\\"

-- Disable some default providers
for _, provider in ipairs { "node", "perl", "python3", "ruby" } do
  g["loaded_" .. provider .. "_provider"] = 0
end

-- Fix markdown indentation settings
g.markdown_recommended_style = 0

-------------------------------------- options ------------------------------------------
-- General UI
opt.laststatus = 3            -- Global statusline
opt.showmode = false          -- Mode is usually handled by a statusline plugin
opt.cursorline = true         -- Highlight the current line
opt.termguicolors = true      -- True color support
opt.signcolumn = "yes"        -- Always show the signcolumn to prevent flickering
opt.mouse = "a"               -- Enable mouse support
opt.confirm = true            -- Confirm to save changes before exiting modified buffer
-- Disable nvim intro
--opt.shortmess:append "sI"
opt.shortmess:append "WIsCc"  -- Clean up messages/intro screen

-- Clipboard: Use system clipboard (with SSH check for OSC 52 compatibility)
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Numbers & Gutters
opt.number = true             -- Show line numbers
--opt.relativenumber = true      -- Relative line numbers
opt.numberwidth = 2           -- Gutter width
opt.ruler = false             -- Hide default ruler

-- Indenting & Tabs
opt.expandtab = true          -- Use spaces instead of tabs
opt.shiftwidth = 2            -- Size of an indent
opt.tabstop = 2               -- Number of spaces tabs count for
opt.softtabstop = 2
opt.smartindent = true        -- Insert indents automatically
opt.shiftround = true         -- Round indent to multiple of shiftwidth
opt.autoindent = true
opt.breakindent = true

-- Searching
opt.ignorecase = true         -- Ignore case in search
opt.smartcase = true          -- Don't ignore case with capitals
opt.inccommand = "nosplit"    -- Preview incremental substitute

-- Windows & Splits
opt.splitbelow = true         -- New windows go below
opt.splitright = true         -- New windows go right
opt.splitkeep = "screen"      -- Keep text on the same screen line when splitting

-- Scrolling & Performance
opt.scrolloff = 4             -- Minimum lines to keep above/below cursor
opt.sidescrolloff = 8         -- Columns of context
opt.smoothscroll = true
opt.updatetime = 200          -- Faster completion and swap file write
opt.timeoutlen = 300          -- Time to wait for a mapped sequence

-- Files & Backups
opt.undofile = true           -- Enable persistent undo
opt.undolevels = 10000
opt.autowrite = true          -- Enable auto write

-- Formatting & Wrapping
opt.wrap = false              -- Disable line wrap
opt.linebreak = true          -- Wrap lines at convenient points (if wrap is on)
opt.formatoptions = "jcroqlnt" -- Intelligent auto-formatting

-- Prevents the UI from flickering by syncing the draw calls
opt.termsync = true

-- Behavior
opt.virtualedit = "block"     -- Cursor can move where there is no text in visual block
opt.wildmode = "longest:full,full" -- Command-line completion mode

-- Navigation
opt.whichwrap:append "<>[]hl" -- Allow h,l,arrows to move to next/prev line

-- Visuals / Characters
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
opt.list = true               -- Show some invisible characters
opt.pumblend = 10             -- Popup blend (transparency)
opt.pumheight = 10            -- Max entries in popup

-------------------------------------- OS / Path ----------------------------------------
-- Add binaries installed by mason.nvim to path
local is_windows = vim.fn.has("win32") ~= 0
vim.env.PATH = vim.fn.stdpath "data" .. "/mason/bin" .. (is_windows and ";" or ":") .. vim.env.PATH

-- OS Specific Shell Configuration
if vim.g.os == "Windows" then
  -- Check for pwsh vs powershell
  local function get_powershell_executable()
    if vim.fn.executable("pwsh") == 1 then
      return "pwsh"
    elseif vim.fn.executable("powershell") == 1 then
      return "powershell"
    end
    -- Fallback, shouldn't get here anyway
    return "cmd.exe"
  end

  local shell = get_powershell_executable()

  opt.shell = shell

  -- Specific PowerShell 7+ configurations
  if shell ~= "cmd.exe" then
    opt.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.UTF8Encoding]::new();$PSDefaultParameterValues['Out-File:Encoding']='utf8';Remove-Alias -Force -ErrorAction SilentlyContinue tee;"
    opt.shellredir = '2>&1 | %%{ "$_" } | Out-File %s; exit $LastExitCode'
    opt.shellpipe = '2>&1 | %%{ "$_" } | tee %s; exit $LastExitCode'
    opt.shellxquote = ""
    opt.shellquote = ""
  end
end

