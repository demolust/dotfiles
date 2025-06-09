local M = {}

M.filetypes = {
  "html", "javascript", "typescript", "javascriptreact", "typescriptreact",
  "svelte", "vue", "tsx", "jsx", "rescript", "xml", "php", "markdown"
}

M.opts = {
  enable_close = true,
  enable_rename = true,
  enable_close_on_slash = false,
}

M.setup = function(_, opts)
  require("nvim-ts-autotag").setup({ opts = opts })
end

return M
