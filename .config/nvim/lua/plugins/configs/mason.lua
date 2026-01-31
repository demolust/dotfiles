local M = {}

M.setup = function()
  local mason = require("mason")
  local mason_tool_installer = require("mason-tool-installer")

  mason.setup({
    PATH = "skip",
    ui = {
      icons = {
        package_pending = " ",
        package_installed = "󰄳 ",
        package_uninstalled = " 󰚌",
      },
      keymaps = {
        toggle_server_expand = "<CR>",
        install_server = "i",
        update_server = "u",
        check_server_version = "c",
        update_all_servers = "U",
        check_outdated_servers = "C",
        uninstall_server = "X",
        cancel_installation = "<C-c>",
      },
    },
    max_concurrent_installers = 10,
  })

  mason_tool_installer.setup({
      ensure_installed = {
        -- Useful defaults for nvim
        "lua-language-server", "stylua",
        -- Programming languages LSP's (python, go, C#, C/C++) & formatters
        "python-lsp-server", "black", "pyment",
        "gopls", "goimports", "golines", "gotests", "gofumpt",
        "omnisharp",
        "csharpier",
        "clang-format", "cmake-language-server", "cmakelang",
        "clangd",
        --"asm-lsp",
        -- Shell LSP's & formatters
        "bash-language-server", "powershell-editor-services",
        "shfmt",
        "awk-language-server",
        -- General LSP's (SQL, JSON, YAML, XML, HTML) & formatters
        "sqlls", "sql-formatter", "taplo",
        "html-lsp", "json-lsp", "yaml-language-server",
        "lemminx",
        "prettier", "yamlfmt", "xmlformatter",
        -- Debuggers (bash, python, go, C#, C/C++)
        "bash-debug-adapter", "codelldb", "netcoredbg",
        "debugpy", "delve", "go-debug-adapter",
        -- Programming language linters
        "pylint", "cpplint", "sonarlint-language-server", "golangci-lint",
        "jsonlint", "sqlfluff", "yamllint", "shellcheck",
        -- DevOps LSP's
        "puppet-editor-services", "ansible-language-server", "terraform-ls",
        "dockerfile-language-server", "docker-compose-language-service",
        "nginx-language-server",
        -- DevOps linters
        "ansible-lint",
        -- Other languages
        "typescript-language-server",
        -- Grammar rules & spell checker for text files, markup files, docs files, comments, etc, in various languages
        -- (en-US, es, de-DE)
        "ltex-ls", "marksman", "markdown-oxide",
        --Docs fromatters
        "latexindent",
        -- Docs linters
        "vale",
      },
    auto_update = false,
    run_on_start = true,
  })
end

return M
