local M = {}

M.setup = function()
  local lualine = require("lualine")

  -- Helper function to get active LSP client name
  local function get_lsp_client()
    local msg = "No LSP"
    local buf_ft = vim.api.nvim_get_option_value("filetype", { buf = 0 })
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if next(clients) == nil then
      return msg
    end
    for _, client in ipairs(clients) do
      local filetypes = client.config.filetypes
      if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
        return client.name
      end
    end
    return msg
  end

  lualine.setup({
    options = {
      theme = "auto",
      component_separators = { left = "|", right = "|" },
      section_separators = { left = "", right = "" },
      -- Force a single statusline at the bottom
      globalstatus = true,
    },
    sections = {
      lualine_a = { { "mode", icon = "" } },
      lualine_b = {
        { "branch", icon = "" },
        { "filename", path = 1 },
      },
      lualine_c = {
        { get_lsp_client, icon = " ", color = { fg = "#ffffff", gui = "bold" } },
      },
      lualine_x = {
        -- Git diff status
        {
          "diff",
          symbols = { added = " ", modified = "󰝤 ", removed = " " },
          diff_color = {
            added = { fg = "#98be65" },
            modified = { fg = "#ECBE7B" },
            removed = { fg = "#ec5f67" },
          },
        },
        "encoding",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end

return M
