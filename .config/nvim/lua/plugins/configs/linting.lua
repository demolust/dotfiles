local M = {}

M.setup = function()
  local lint = require("lint")
  -- All config details are located at
  -- https://github.com/mfussenegger/nvim-lint
  -- Need to review the name of the linter, as downloads names from mason are not the same

  local linters_by_ft_to_config = {
    sql = { "sqlfluff" },
    yaml = { "yamllint" },
    json = { "jsonlint" },
  }

  local go_filetypes = {
    "go",
    "gomod",
    "gowork",
    "gotmpl",
  }
  for _, filetype in ipairs(go_filetypes) do
    linters_by_ft_to_config[filetype] = { "golangcilint" }
  end

  lint.linters_by_ft = linters_by_ft_to_config

  local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
      lint.try_lint()
    end,
  })

  -- For vale need to check the following docs
  -- https://neovim.discourse.group/t/vale-linter-setup-with-nvim-lint-mason-exits-with-code-2/4669
  -- https://wise4rmgodadmob.medium.com/how-to-automate-linting-your-documentation-using-vale-and-github-actions-2726033f0d6c
end

return M
