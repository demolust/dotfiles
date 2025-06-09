-- Define some settings used for further config

local function get_os()
  if vim.fn.has("win32") == 1 then return "Windows" end
  if vim.fn.has("unix") == 1 then
    -- Distinguish between Linux and Mac (Darwin)
    if vim.fn.has("mac") == 1 then return "Mac" end
    return "Linux"
  end
  return "Unknown"
end

-- Set OS globally safely
vim.g.os = get_os()

-- Calculate Paths safely using vim.fn.stdpath
-- standard data path is usually ~/.local/share/nvim or AppData/Local/nvim-data
local data_path = vim.fn.stdpath("data")

-- Define Mason path for some LSP configs
-- Using standard path joining (works on Windows/Linux)
-- Can't use env var $MASON since is not loaded until neovim is fully initialised
vim.g.mason_package_path = vim.fs.joinpath(data_path, "mason", "packages")

-- Also need to define user 'home' path for other configs:
vim.g.home_path = vim.loop.os_homedir()
