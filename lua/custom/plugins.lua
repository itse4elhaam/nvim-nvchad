local plugins = {
  {
    'MunifTanjim/prettier.nvim',
    lazy = false,
    config = require("custom.configs.prettier")
  },
  {
    'MagicDuck/grug-far.nvim',
    lazy = false,
    config = function()
      require('grug-far').setup({});
    end
  },
  {
    "sindrets/diffview.nvim",
    lazy = false,
  },
  {
    "letieu/btw.nvim",
    lazy = false,
    config = function()
      require('btw').setup()
    end,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require('ts_context_commentstring').setup {
        enable_autocmd = false,
      }
    end
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    event = "VeryLazy",
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end
  },
  {
    "folke/todo-comments.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {}
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = require("custom.configs.trouble"),
  },
  {
    "olrtg/nvim-emmet",
    config = function()
      vim.keymap.set({ "n", "v" }, '<leader>xe', require('nvim-emmet').wrap_with_abbreviation)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    config = require("custom.configs.nvim-treesitter-context"),
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = require("custom.configs.telescope"),
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup({
        pre_save_cmds = { "tabdo NvimTreeClose" },
      })
    end,
  },
  { "wakatime/vim-wakatime", lazy = false },
  {
    "0x00-ketsu/autosave.nvim",
    event = { "InsertLeave", "TextChanged" },
    config = require("custom.configs.autosave")
  },
  {
    "williamboman/mason.nvim",
    opts = require("custom.configs.mason"),
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {

    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.null-ls"
    end
  },
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
      require("core.utils").load_mappings("gopher")
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = function()
      require "custom.configs.treesitter"
    end

  },
}

return plugins
