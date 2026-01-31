local M = {}

M.apply_overrides = function()
  local function hl(group, options)
    vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", options, { force = true }))
  end

  -------------------------------------------------------------------------
  -- Snacks.nvim Picker Fixes (Visibility)
  -------------------------------------------------------------------------
  hl("SnacksPickerDir", { link = "Directory" })         -- Folder paths
  hl("SnacksPickerPath", { link = "Comment" })          -- File paths
  hl("SnacksPickerPathHidden", { fg = "#5c6370" })      -- Grey out redundant parts
  hl("SnacksPickerPathIgnored", { fg = "#46577a" })     -- Light Blue out redundant parts

  -------------------------------------------------------------------------
  -- Snacks.nvim Git & UI
  -------------------------------------------------------------------------
  hl("SnacksPickerGitStatusModified", { link = "DiffChange" })
  hl("SnacksPickerGitStatusAdded", { link = "DiffAdd" })
  hl("SnacksPickerGitStatusDeleted", { link = "DiffDelete" })
  hl("SnacksPickerGitStatusUntracked", { link = "DiagnosticInfo" })

  -- Indent guides (making them visible since NonText is invisible)
  hl("SnacksIndent", { fg = "#3e4452" })
  hl("SnacksIndentScope", { link = "Special" })

  -------------------------------------------------------------------------
  -- Dashboard / Starter
  -------------------------------------------------------------------------
  hl("SnacksDashboardHeader", { link = "Title" })
  hl("SnacksDashboardDesc", { link = "Special" })
  
  -- Add any other NonText fixes here 
end

return M
