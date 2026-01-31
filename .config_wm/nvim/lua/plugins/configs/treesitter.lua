local M = {}

M.opts = {
  auto_install = true,
  sync_install = false,
  ensure_installed = {
    -- Defaults
    "vim", "vimdoc", "lua",
    -- Low level languages
    "c", "cpp",
    -- Can't be installed as for now (March 2024)
    -- "asm", "disassembly", "strace",
    -- High level languages
    "python", "requirements",
    "go", "gomod", "gosum", "gowork",
    "c_sharp",
    -- Shells
    "bash", "tmux",
    -- Data, config & docs
    "sql", "html", "xml", "yaml", "json",
    "regex", "ini", "csv", "toml", "doxygen",
    -- Git / System
    "git_config", "git_rebase", "gitattributes",
    "gitcommit", "gitignore", "kconfig",
    "awk", "diff", "gpg", "ssh_config", "udev",
    -- Can't be installed as for now (March 2024)
    --"tmux", "passwd", "pem",
    -- DevOps
    "http", "jq",
    "dockerfile", "puppet", "hcl", "promql",
    -- Build systems
    "cmake", "make",
    "meson", "ninja",
    -- Text / Docs
    "todotxt", "comment", "markdown", "markdown_inline",
    "typescript",
    "latex",

    --[[ To check for later
    "groovy", "java", "javascript", "rust",
    "graphql", "printf", "ispc", "llvm",
    "pioasm", "nasm",
    "bitbake", "capnp",
    "devicetree", "foam",
    "gn", "gstlaunch", "hurl",
    "luap", "nasm", "nix",
    "neorg", "m68k", "po", "proto",
    "pymanifest", "ql", "query",
    "re2c", "readline",
    "robot", "sparql",
    "systemtap", "tablegen",
    "textproto", "verilog",
      ]]
  },
}

-- robust Filesystem Scan for Main Branch
function M.get_installed_parsers()
  local parsers = {}
  local seen = {}

  -- Scan runtime path for 'parser/*.so' (or dll/dylib)
  local compiled_parsers = vim.api.nvim_get_runtime_file("parser/*", true)

  for _, path in ipairs(compiled_parsers) do
    local ext = vim.fn.fnamemodify(path, ":e")
    local lang = vim.fn.fnamemodify(path, ":t:r")

    -- Filter for shared objects and deduplicate
    if (ext == "so" or ext == "dll" or ext == "dylib") and not seen[lang] then
      table.insert(parsers, lang)
      seen[lang] = true
    end
  end

  table.sort(parsers)
  return parsers
end

M.setup = function(_, opts)
  local ts = require("nvim-treesitter")
  ts.setup(opts)

  -- Re-implement 'ensure_installed' logic (fixes issues with 'main' branch)
  local ensure_installed = opts.ensure_installed or {}
  local to_install = {}
  for _, lang in ipairs(ensure_installed) do
    if vim.fn.empty(vim.api.nvim_get_runtime_file("parser/" .. lang .. ".so", true)) > 0 then
      table.insert(to_install, lang)
    end
  end
  if #to_install > 0 then
    vim.notify("Installing missing parsers: " .. table.concat(to_install, ", "), vim.log.levels.INFO)
    ts.install(to_install)
  end

  -- The safe Autocmd to enable Highlighting & Indent
  vim.api.nvim_create_autocmd("FileType", {
    callback = function(args)
      local lang = vim.treesitter.language.get_lang(args.match)
      if lang then
        local success, _ = pcall(vim.treesitter.start, args.buf, lang)
      end
    end,
  })

  -- Command: :TSGetInstalled
  vim.api.nvim_create_user_command("TSGetInstalled", function()
    local parsers = M.get_installed_parsers()
    print(vim.inspect(parsers))
  end, {})
end

return M
