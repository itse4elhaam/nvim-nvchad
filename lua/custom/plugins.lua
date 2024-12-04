local plugins = {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    config = require "custom.configs.textobjects",
  },
  {
    "stevearc/quicker.nvim",
    event = "FileType qf",
    ---@module "quicker"
    ---@type quicker.SetupOptions
    opts = {},
    config = function()
      require("quicker").setup()
    end,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    opts = {
      menu = {
        width = vim.api.nvim_win_get_width(0) - 4,
      },
      settings = {
        save_on_toggle = true,
      },
    },
    keys = require "custom.configs.harpoon",
  },
  { "kevinhwang91/promise-async" },
  {
    "kevinhwang91/nvim-ufo",
    requires = "kevinhwang91/promise-async",
    lazy = true,
    event = "LspAttach",
    config = require "custom.configs.ufo",
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    config = function()
      require("refactoring").setup()
    end,
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true, event = "VeryLazy" },
  {
    "pmizio/typescript-tools.nvim",
    event = "LspAttach",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  { "wakatime/vim-wakatime", lazy = false },
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
    },
    branch = "regexp", -- This is the regexp branch, use this for the new version
    config = function()
      require("venv-selector").setup()
    end,
    ft = { "python" },
    keys = {
      { "<leader>vs", "<cmd>VenvSelect<cr>" },
    },
  },
  {
    "nvim-lua/plenary.nvim",
    config = require "custom.configs.plenary",
  },
  {
    "MunifTanjim/prettier.nvim",
    event = "LspAttach",
    config = require "custom.configs.prettier",
  },
  {
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "nvimtools/none-ls.nvim",
    },
    config = function()
      require "custom.configs.null-ls"
    end,
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    config = function()
      require("grug-far").setup {}
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewOpen",
    },
  },
  {
    "letieu/btw.nvim",
    config = function()
      require("btw").setup()
    end,
    lazy = false,
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("ts_context_commentstring").setup {
        enable_autocmd = false,
      }
    end,
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-tree.lua",
    },
    event = "LspAttach",
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "LspAttach",
    config = function()
      require("nvim-surround").setup {}
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "LspAttach",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = require "custom.configs.trouble",
  },
  {
    "olrtg/nvim-emmet",
    event = "LspAttach",
    config = function()
      vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = true,
    event = { "BufReadPost", "BufNewFile" },
    config = require "custom.configs.nvim-treesitter-context",
  },
  {
    "nvim-telescope/telescope.nvim",
    lazy = true,
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = require "custom.configs.telescope",
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup {
        pre_save_cmds = { "tabdo NvimTreeClose" },
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = require "custom.configs.mason",
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
    event = "LspAttach",
    opts = function()
      return require "custom.configs.null-ls"
    end,
  },
  {
    "olexsmir/gopher.nvim",
    ft = "go",
    config = function(_, opts)
      require("gopher").setup(opts)
      require("core.utils").load_mappings "gopher"
    end,
    build = function()
      vim.cmd [[silent! GoInstallDeps]]
    end,
  },
}

return plugins
