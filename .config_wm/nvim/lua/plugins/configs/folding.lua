local M = {}

M.opts = {
  provider_selector = function(bufnr, filetype, buftype)
    return { "treesitter", "indent" }
  end,
}

M.setup = function(_, opts)
  -- Mandatory Global Options for UFO
  -- Snacks.statuscolumn will provide the icons instead, thus foldcolumn is set to 0
  vim.o.foldcolumn = "0"
  vim.o.foldlevel = 99
  vim.o.foldlevelstart = 99
  vim.o.foldenable = true

  require("ufo").setup(opts)
end

return M
