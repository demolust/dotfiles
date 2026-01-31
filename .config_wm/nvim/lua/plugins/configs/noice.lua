local M = {}

-- Avoid flickering when using the search function on noice
vim.opt.incsearch = false

M.setup = function()
  require("noice").setup({
    cmdline = { view = "cmdline_popup" },

    -- Explicitly redirect history
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
      view_warn = "notify",
      view_history = "popup",
    },

    -- Define exactly what the "popup" view looks like
    views = {
      popup = {
        backend = "popup",
        relative = "editor",
        close = { events = { "BufLeave" }, keys = { "q" } },
        enter = true,
        border = { style = "rounded" },
        position = { row = "50%", col = "50%" },
        size = { width = "80%", height = "70%" },
        win_options = { winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" } },
      },
    },

    -- Ensure the history command uses that view
    commands = {
      history = {
        view = "popup",
        opts = { enter = true, format = "details" },
        filter = { any = { { event = "msg_show" }, { error = true }, { warning = true } } },
      },
    },

    presets = {
      bottom_search = false,
      -- Set to false to prevent it overriding the defined popup
      long_message_to_split = false,
      lsp_doc_border = true,
    },

    routes = {
      -- Mason,Treesitter,Lazy logic
      {
        filter = {
          event = "msg_show",
          any = { { find = "mason" }, { find = "Treesitter" }, { find = "lazy" } },
        },
        opts = { timeout = 500 },
      },
      {
        filter = { event = "msg_show", find = "written" },
        opts = { skip = true },
      },
    },
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
  })
end

return M
