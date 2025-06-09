local M = {}

local kind_icons = {
  Text = "", Method = "", Function = "󰊕", Constructor = "", Field = "",
  Variable = "󰂡", Class = "", Interface = "", Module = "", Property = "",
  Unit = "", Value = "󰎠", Enum = "", Keyword = "󰌋", Snippet = "",
  Color = "", File = "", Reference = "", Folder = "", EnumMember = "",
  Constant = "󰏿", Struct = "", Event = "", Operator = "", TypeParameter = "",
}

M.opts = {
  keymap = {
    preset = "enter",
    ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    ["<C-u>"] = { "scroll_documentation_up", "fallback" },
    ["<C-d>"] = { "scroll_documentation_down", "fallback" },
    ['<Up>'] = {},
    ['<Down>'] = {},
  },

  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
    kind_icons = kind_icons,
  },

  snippets = { preset = "default" },

  completion = {
    accept = { auto_brackets = { enabled = true } },
    menu = {
      draw = {
        treesitter = { "lsp" },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    ghost_text = { enabled = false },
  },

  signature = { enabled = true },

  sources = {
    default = { "lsp", "path", "snippets", "buffer", "lazydev" },

    providers = {
      lazydev = {
        name = "LazyDev",
        module = "lazydev.integrations.blink",
        score_offset = 100,
      },
    },

    -- Adding any nvim-cmp sources here will enable them with blink.compat
    --compat = {},
  },

  cmdline = {
    enabled = true,
    keymap = {
      preset = "cmdline",
      ["<Right>"] = false,
      ["<Left>"] = false,
    },
  },
}

M.setup = function(_, opts)
  -- Handle 'compat' sources (The LazyVim Logic)
  -- This allows to use old nvim-cmp sources by just adding them to opts.sources.compat
  local enabled = opts.sources.default
  for _, source in ipairs(opts.sources.compat or {}) do
    opts.sources.providers[source] = vim.tbl_deep_extend(
      "force",
      { name = source, module = "blink.compat.source" },
      opts.sources.providers[source] or {}
    )
    if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
      table.insert(enabled, source)
    end
  end

  -- Check if is needed to override symbol kinds
  for _, provider in pairs(opts.sources.providers or {}) do
    if provider.kind then
      local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
      local kind_idx = #CompletionItemKind + 1

      CompletionItemKind[kind_idx] = provider.kind
      CompletionItemKind[provider.kind] = kind_idx

      local transform_items = provider.transform_items
      provider.transform_items = function(ctx, items)
        items = transform_items and transform_items(ctx, items) or items
        for _, item in ipairs(items) do
          item.kind = kind_idx or item.kind
        end
        return items
      end
      provider.kind = nil
    end
  end

  require("blink.cmp").setup(opts)
end

return M
