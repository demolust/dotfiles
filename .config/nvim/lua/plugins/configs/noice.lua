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
      signature = {
        enabled = true,
        -- Keep Noice's signature UI, but do not show it immediately when an
        -- LSP trigger character such as `(` or `,` is typed.
        auto_open = { enabled = false },
      },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
      },
    },
  })

  -- Noice has no configurable auto-open delay, so check for an LSP signature
  -- trigger only after the user has been idle in Insert mode for 12 seconds.
  -- This remains filetype-agnostic and uses the same UI as <leader>ls.
  local signature_idle_ms = 12000
  local signature_timer = vim.uv.new_timer()
  local signature_group = vim.api.nvim_create_augroup("noice_signature_idle", { clear = true })

  local function stop_signature_timer()
    signature_timer:stop()
  end

  local function restart_signature_timer()
    stop_signature_timer()

    local bufnr = vim.api.nvim_get_current_buf()
    local winid = vim.api.nvim_get_current_win()
    signature_timer:start(signature_idle_ms, 0, vim.schedule_wrap(function()
      if vim.api.nvim_get_mode().mode:sub(1, 1) ~= "i"
        or not vim.api.nvim_buf_is_valid(bufnr)
        or not vim.api.nvim_win_is_valid(winid)
        or vim.api.nvim_get_current_buf() ~= bufnr
        or vim.api.nvim_get_current_win() ~= winid
      then
        return
      end

      require("noice.lsp.signature").check()
    end))
  end

  vim.api.nvim_create_autocmd({ "InsertEnter", "CursorMovedI", "TextChangedI" }, {
    group = signature_group,
    callback = restart_signature_timer,
  })

  vim.api.nvim_create_autocmd("InsertLeave", {
    group = signature_group,
    callback = stop_signature_timer,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = signature_group,
    callback = function()
      stop_signature_timer()
      if not signature_timer:is_closing() then
        signature_timer:close()
      end
    end,
  })
end

return M
