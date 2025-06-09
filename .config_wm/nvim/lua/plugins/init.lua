local keymaps = require("plugins.configs.keymaps")

return {
  -----------------------------------------------------------------------------
  -- UI, Themes, Utils & Navigation
  -----------------------------------------------------------------------------

  -- General dependency
  { "nvim-lua/plenary.nvim" },

-- Theme
  {
    "lunarvim/horizon.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("horizon").setup()
      vim.cmd.colorscheme("horizon")
      -- Load and apply custom highlights
      require("plugins.configs.theme").apply_overrides()
    end,
  },

  -- UI Tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    lazy = false,
    config = function()
      require("plugins.configs.bufferline").setup()
    end,
  },

  -- Cmdline popup & other UI elements
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("plugins.configs.noice").setup()
    end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    lazy = false,
    config = function()
      require("plugins.configs.statusline").setup()
    end,
  },

  -- UI icons
  {
    "nvim-tree/nvim-web-devicons",
    config = function()
      require("nvim-web-devicons").setup()
    end,
  },

  -- Better Escape
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end,
  },

  -- Menus for Leader and general keys
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = keymaps.whichkey,
    config = function()
      require("which-key").setup({})
    end,
  },

  -- GitSigns
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = keymaps.gitsigns,
    opts = function()
      return require("plugins.configs.others").gitsigns
    end,
    config = function(_, opts)
      require("gitsigns").setup(opts)
    end,
  },

  -- Comments
  {
    "folke/ts-comments.nvim",
    opts = {},
    event = "VeryLazy",
    enabled = vim.fn.has("nvim-0.10.0") == 1,
  },

  -- Trouble (Diagnostics)
  {
    "folke/trouble.nvim",
    opts = {},
    keys = keymaps.trouble,
  },

  -- Snacks
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = keymaps.snacks,
    opts = function()
      require("plugins.configs.snacks_overrides")
      return require("plugins.configs.snacks").opts
    end,
    config = function(_, opts)
      require("snacks").setup(opts)
    end,
  },

  -----------------------------------------------------------------------------
  -- Programming setup
  -----------------------------------------------------------------------------

  -- Folding
  {
    "kevinhwang91/nvim-ufo",
    dependencies = { "kevinhwang91/promise-async" },
    event = "BufReadPost",
    keys = keymaps.ufo,
    opts = function()
      return require("plugins.configs.folding").opts
    end,
    config = function(_, opts)
      require("plugins.configs.folding").setup(_, opts)
    end,
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    branch = "main",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate", "TSBufEnable", "TSBufDisable" },
    build = ":TSUpdate",
    opts = function()
      return require("plugins.configs.treesitter").opts
    end,
    config = function(_, opts)
      require("plugins.configs.treesitter").setup(_, opts)
    end,
  },

  -- Mason
  {
    "williamboman/mason.nvim",
    lazy = false,
    dependencies = {
      "whoissethdaniel/mason-tool-installer.nvim",
    },
    config = function()
      require("plugins.configs.mason").setup()
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("plugins.configs.lspconfig").setup()
    end,
  },

  -- Conform (Formatting)
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    keys = keymaps.conform,
    opts = function()
      return require("plugins.configs.conform")
    end,
  },

  -- Nvim Lint (Linting)
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("plugins.configs.linting").setup()
    end,
  },

  -- Autotags
  {
    "windwp/nvim-ts-autotag",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = require("plugins.configs.autotag").filetypes,
    event = { "BufReadPre", "BufNewFile" },
    opts = function()
      return require("plugins.configs.autotag").opts
    end,
    config = function(_, opts)
      require("plugins.configs.autotag").setup(_, opts)
    end,
  },

  -- Blink CMP
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      -- Add blink.compat to support old nvim-cmp sources
      { "saghen/blink.compat", version = "*", opts = {} },
      -- Add lazydev for Lua development
      { "folke/lazydev.nvim", ft = "lua", opts = {} },
      -- Autopairs: Keeps ()[]{} balanced while you type
      {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        opts = {
          fast_wrap = {},
          disable_filetype = { "TelescopePrompt", "vim" },
        },
        config = function(_, opts)
          require("nvim-autopairs").setup(opts)
        end,
      },
    },
    version = "*",
    opts = function()
      return require("plugins.configs.blink").opts
    end,
    config = function(_, opts)
      require("plugins.configs.blink").setup(_, opts)
    end,
  },

  -- DAP
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
      "leoluz/nvim-dap-go",
      "mfussenegger/nvim-dap-python",
    },
    keys = function()
      local all_keys = {}
      for _, v in ipairs(keymaps.dap or {}) do table.insert(all_keys, v) end
      for _, v in ipairs(keymaps.dap_python or {}) do table.insert(all_keys, v) end
      for _, v in ipairs(keymaps.dap_go or {}) do table.insert(all_keys, v) end
      return all_keys
    end,
    config = function()
      require("plugins.configs.dap").setup()
    end,
  },
}
