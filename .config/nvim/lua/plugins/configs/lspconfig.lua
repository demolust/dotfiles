local M = {}

M.setup = function()
  local keymaps = require("plugins.configs.keymaps").lspconfig

  -- Define on_attach (Sets keymaps when LSP connects)
  local on_attach = function(client, bufnr)
    for _, keys in ipairs(keymaps) do
      local opts = { buffer = bufnr, desc = keys.desc }
      vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
    end
  end

  -- Define Capabilities (Standard for nvim-cmp)
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local status_ok, blink = pcall(require, "blink.cmp")
  if status_ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  -- Apply global defaults (Neovim 0.11+ style)
  -- Use "*" to apply on_attach and capabilities to every enabled server
  if vim.lsp.config then
    vim.lsp.config("*", {
      on_attach = on_attach,
      capabilities = capabilities,
    })
  end

  -- Server Specific Configurations
  if vim.lsp.config then
    --Pwsh
    local pwsh_es_path = vim.fs.joinpath(vim.g.mason_package_path, "powershell-editor-services")
    vim.lsp.config("powershell_es", {
      bundle_path = pwsh_es_path,
      init_options = { enableProfileLoading = false },
    })

    -- Go
    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          analyses = { unusedparams = true },
        },
      },
    })

    -- ltex
    vim.lsp.config("ltex", {
      cmd = { "ltex-ls" },
      settings = {
        ltex = {
          checkFrequency = "save",
          language = "en-US",
          enabled = true,
        },
      },
      filetypes = { "bibtex", "gitcommit", "org", "tex", "latex", "markdown", "text" },
    })
  end

  -- List of standard servers to enable (those without special config)
  local servers = {
    "clangd", "cmake", "sqlls", "jsonls", "yamlls", "omnisharp",
    "lemminx", "html", "lua_ls", "bashls", "awk_ls", "pylsp",
    "ts_ls", "puppet", "ansiblels", "terraformls", "taplo",
    "dockerls", "docker_compose_language_service", "nginx_language_server",
    --"asm_lsp",
  }

  -- Enable everything
  if vim.lsp.enable then
    vim.lsp.enable(servers)
    vim.lsp.enable({ "gopls", "ltex" ,"powershell_es"})
  else
    -- Fallback for Neovim < 0.11
    local lspconfig = require("lspconfig")
    for _, lsp in ipairs(servers) do
      lspconfig[lsp].setup({ on_attach = on_attach, capabilities = capabilities })
    end
    lspconfig.lua_ls.setup({ on_attach = on_attach, capabilities = capabilities })
  end
end

return M
