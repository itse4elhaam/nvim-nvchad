local load_mappings = require("core.utils").load_mappings

local merge_plugins = require("custom.utils").mergePlugins

---@return table
local function get_ai_plugins()
  return {
    {
      "olimorris/codecompanion.nvim",
      cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
      opts = require("custom.configs.codecompanion").opts,
      dependencies = require("custom.configs.codecompanion").dependencies,
      keys = load_mappings "code_companion",
    },
  }
end

---@return table
local function get_editing_enhancement_plugins()
  return {
    {
      "abecodes/tabout.nvim",
      enabled = false,
      lazy = false,
      config = require "custom.configs.tabout",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
      },
      opt = true,
      event = "InsertCharPre",
      priority = 1000,
    },
    {
      "chrisgrieser/nvim-various-textobjs",
      event = "VeryLazy",
      opts = {
        keymaps = {
          useDefaults = true,
        },
      },
    },
    {
      "kylechui/nvim-surround",
      version = "*",
      lazy = false,
      config = function()
        require("nvim-surround").setup {}
      end,
    },
    {
      "johmsalas/text-case.nvim",
      cmd = require("custom.configs.text-case").cmd,
      dependencies = { "nvim-telescope/telescope.nvim" },
      config = function()
        require("textcase").setup {}
      end,
      keys = load_mappings "text_case",
    },
    {
      "echasnovski/mini.ai",
      event = "VeryLazy",
      version = "*",
      config = function()
        require("mini.ai").setup()
      end,
    },
    {
      "echasnovski/mini.operators",
      event = "VeryLazy",
      version = "*",
      config = function()
        require("mini.operators").setup()
      end,
    },
    {
      "windwp/nvim-autopairs",
      event = "InsertEnter",
      config = true,
      opts = {},
    },
    {
      "rmagatti/alternate-toggler",
      config = require "custom.configs.alternate-toggler",
      event = { "BufReadPost" },
    },
    {
      "gbprod/yanky.nvim",
      opts = {},
      config = require "custom.configs.yanky",
    },
    {
      "Wansmer/treesj",
      lazy = true,
      cmd = { "TSJToggle", "TSJSplit", "TSJJoin" },
      keys = {
        { "gJ", "<cmd>TSJToggle<CR>", desc = "Toggle Split/Join" },
      },
      opts = {
        use_default_keymaps = false,
      },
    },
    {
      "gbprod/stay-in-place.nvim",
      lazy = false,
      config = true,
    },
    {
      "letieu/btw.nvim",
      config = function()
        require("btw").setup()
      end,
      lazy = false,
    },
  }
end

---@return table
local function get_motion_plugins()
  return {
    {
      "folke/flash.nvim",
      event = "VeryLazy",
      ---@type Flash.Config
      opts = {
        modes = {
          chars = {
            jump_labels = true,
          },
        },
      },
      -- stylua: ignore
      keys = load_mappings "flash",
    },
    {
      "christoomey/vim-tmux-navigator",
      cmd = require("custom.configs.vim-tmux-navigator").cmd,
      keys = load_mappings "vim_tmux_navigator",
    },
    { "chrisgrieser/nvim-spider", lazy = false, keys = load_mappings "spider_motion" },
    {
      "danielfalk/smart-open.nvim",
      lazy = false,
      branch = "0.2.x",
      dependencies = {
        "kkharji/sqlite.lua",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        { "nvim-telescope/telescope-fzy-native.nvim" },
      },
    },
  }
end

---@return table
local function get_lsp_and_completion_plugins()
  return {
    {
      "mfussenegger/nvim-lint",
      event = {
        "BufReadPre",
        "BufNewFile",
      },
      config = require "custom.configs.nvim-lint",
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
      "williamboman/mason.nvim",
      opts = require "custom.configs.mason",
    },
    {
      "neovim/nvim-lspconfig",
      event = "User FilePost",
      dependencies = { "saghen/blink.cmp" },
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
      "saghen/blink.cmp",
      event = "InsertEnter",
      dependencies = { "rafamadriz/friendly-snippets", "fang2hou/blink-copilot", "archie-judd/blink-cmp-words" },
      version = "v0.*",
      opts = require "custom.configs.blink",
      opts_extend = { "sources.default" },
    },
    {
      "j-hui/fidget.nvim",
      opts = {},
    },
  }
end

---@return table
local function get_language_specific_plugins()
  return {
    {
      "MeanderingProgrammer/render-markdown.nvim",
      event = "LspAttach",
      dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
      ---@module 'render-markdown'
      ---@type render.md.UserConfig
      opts = {},
    },
    {
      "iamcco/markdown-preview.nvim",
      cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
      build = "cd app && yarn install",
      init = function()
        vim.g.mkdp_filetypes = { "markdown" }
      end,
      ft = { "markdown" },
    },
    {
      "olrtg/nvim-emmet",
      event = "LspAttach",
      config = function()
        vim.keymap.set({ "n", "v" }, "<leader>xe", require("nvim-emmet").wrap_with_abbreviation)
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
    {
      "pmizio/typescript-tools.nvim",
      event = "LspAttach",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "neovim/nvim-lspconfig",
        {
          "saghen/blink.cmp",
          lazy = false,
          priority = 1000,
        },
      },
      ft = { "typescript", "typescriptreact", "javascript", "javascriptreact", "svelte" },
      opts = require "custom.configs.typescript-tools",
    },
    {
      "linux-cultist/venv-selector.nvim",
      dependencies = {
        "neovim/nvim-lspconfig",
        "mfussenegger/nvim-dap",
        { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
      },
      branch = "regexp",
      config = function()
        require("venv-selector").setup()
      end,
      ft = { "python" },
    },
    {
      "MunifTanjim/prettier.nvim",
      event = "LspAttach",
      config = require "custom.configs.prettier",
    },
    {
      "tronikelis/ts-autotag.nvim",
      opts = {},
      event = "VeryLazy",
    },
    {
      "Goose97/timber.nvim",
      version = "*",
      event = "VeryLazy",
      config = require "custom.configs.timber",
    },
    {
      "MaximilianLloyd/tw-values.nvim",
      keys = {
        { "<Leader>cv", "<CMD>TWValues<CR>", desc = "Tailwind CSS values" },
      },
      opts = {
        border = "rounded",
        show_unknown_classes = true,
      },
    },
    {
      "dmmulroy/ts-error-translator.nvim",
      config = true,
    },
  }
end

---@return table
local function get_treesitter_plugins()
  return {
    {
      "nvim-treesitter/nvim-treesitter-context",
      lazy = true,
      event = { "BufReadPost", "BufNewFile" },
      config = require "custom.configs.nvim-treesitter-context",
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
      "nvim-treesitter/nvim-treesitter-textobjects",
      lazy = true,
      config = require "custom.configs.textobjects",
    },
  }
end

---@return table
local function get_ui_and_visual_plugins()
  return {
    {
      "jinh0/eyeliner.nvim",
      enabled = true,
      lazy = false,
      config = require "custom.configs.eyeliner",
    },
    {
      "sphamba/smear-cursor.nvim",
      enabled = true,
      lazy = false,
      opts = require "custom.configs.smear-cursor",
    },
    {
      "folke/todo-comments.nvim",
      event = "LspAttach",
      dependencies = { "nvim-lua/plenary.nvim" },
      opts = {},
    },
    {
      "kevinhwang91/nvim-ufo",
      requires = "kevinhwang91/promise-async",
      lazy = false,
      config = require "custom.configs.ufo",
    },
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = require "custom.configs.snacks",
      keys = load_mappings "snacks",
    },
    {
      "chentoast/marks.nvim",
      event = "BufEnter",
      config = true,
    },
    {
      "nacro90/numb.nvim",
      lazy = false,
      opts = {},
    },
  }
end

---@return table
local function get_picker_plugins()
  return {
    {
      "nvim-telescope/telescope-ui-select.nvim",
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
      "axkirillov/easypick.nvim",
      requires = "nvim-telescope/telescope.nvim",
      cmd = "Easypick",
      config = require "custom.configs.easypick",
    },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    {
      "stevearc/quicker.nvim",
      event = "FileType qf",
      ---@module "quicker"
      opts = {},
      config = function()
        require("quicker").setup()
      end,
    },
    {
      "ThePrimeagen/harpoon",
      branch = "harpoon2",
      opts = require("custom.configs.harpoon").opts,
      keys = require("custom.configs.harpoon").keys,
    },
  }
end

---@return table
local function get_git_plugins()
  return {
    { "akinsho/git-conflict.nvim", version = "*", config = true, event = "VeryLazy" },
    {
      "MagicDuck/grug-far.nvim",
      cmd = "GrugFar",
      config = function()
        require("grug-far").setup {}
      end,
    },
  }
end

---@return table
local function get_file_management_plugins()
  return {
    {
      "LintaoAmons/bookmarks.nvim",
      cmd = require("custom.configs.bookmarks").cmd,
      dependencies = require("custom.configs.bookmarks").dependencies,
      config = require("custom.configs.bookmarks").config,
    },
    {
      "epwalsh/obsidian.nvim",
      version = "*", -- recommended, use latest release instead of latest commit
      lazy = true,
      event = {
        "BufReadPre /home/e4elhaam/vaults/obsidian-notes/*.md",
        "BufNewFile /home/e4elhaam/vaults/obsidian-notes/*.md",
      },
      dependencies = {
        "nvim-lua/plenary.nvim",
      },
      opts = require "custom.configs.obsidian",
    },
    {
      "mbbill/undotree",
      cmd = "UndotreeToggle",
    },
    {
      "mikavilpas/yazi.nvim",
      cmd = "Yazi",
      keys = load_mappings "yazi",
      opts = {
        open_for_directories = false,
        keymaps = {
          show_help = "<f1>",
        },
      },
    },
    {
      "atiladefreitas/dooing",
      event = "VeryLazy",
      config = function()
        require("dooing").setup {}
      end,
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
      "stevearc/oil.nvim",
      opts = {
        default_file_explorer = false,
      },
      dependencies = { { "echasnovski/mini.icons", opts = {} } },
      lazy = false,
      config = function()
        require("oil").setup {
          default_file_explorer = false,
        }
      end,
    },
    {
      "refractalize/oil-git-status.nvim",

      dependencies = {
        "stevearc/oil.nvim",
      },

      config = true,
    },
    {
      "JezerM/oil-lsp-diagnostics.nvim",
      dependencies = { "stevearc/oil.nvim" },
      opts = {},
    },
  }
end

---@return table
local function get_database_plugins()
  return {
    {
      "kndndrj/nvim-dbee",
      dependencies = {
        "MunifTanjim/nui.nvim",
      },
      cmd = "Dbee",
      build = function()
        require("dbee").install()
      end,
      config = function()
        require("dbee").setup()
      end,
    },
    {
      "kristijanhusak/vim-dadbod-ui",
      dependencies = require("custom.configs.vim-dadbod-ui").dependencies,
      cmd = require("custom.configs.vim-dadbod-ui").cmd,
      init = function()
        vim.g.db_ui_use_nerd_fonts = 1
      end,
    },
  }
end

---@return table
local function get_snippet_and_refactor_plugins()
  return {
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
    {
      "chrisgrieser/nvim-scissors",
      event = "BufEnter",
      dependencies = "nvim-telescope/telescope.nvim",
      opts = {
        snippetDir = vim.fn.stdpath "config" .. "/snippets",
      },
      keys = {
        "<Leader>asa",
        "<Leader>ase",
      },
      config = require "custom.configs.scissors",
    },
    {
      "chrisgrieser/nvim-rip-substitute",
      cmd = "RipSubstitute",
      opts = {},
      keys = {
        {
          "<leader>rs",
          function()
            require("rip-substitute").sub()
          end,
          mode = { "n", "x" },
          desc = " rip substitute",
        },
      },
    },
  }
end

---@return table
local function get_utility_plugins()
  return {
    { "chrisgrieser/nvim-puppeteer", lazy = false },
    { "chrisgrieser/nvim-rulebook",  cmd = "Rulebook", keys = load_mappings "rulebook" },
    {
      "m4xshen/hardtime.nvim",
      lazy = false,
      enabled = false,
      dependencies = { "MunifTanjim/nui.nvim" },
      opts = {},
    },
    {
      "MunifTanjim/nui.nvim",
      lazy = true, -- Load only when needed
    },
    {
      "ThePrimeagen/vim-be-good",
      cmd = "VimBeGood",
    },
    { "kevinhwang91/promise-async", lazy = false },
    {
      "nvim-lua/plenary.nvim",
      config = require "custom.configs.plenary",
    },
    { "wakatime/vim-wakatime",      lazy = false },
  }
end

local plugins = merge_plugins(
  get_ai_plugins(),
  get_editing_enhancement_plugins(),
  get_motion_plugins(),
  get_lsp_and_completion_plugins(),
  get_language_specific_plugins(),
  get_treesitter_plugins(),
  get_ui_and_visual_plugins(),
  get_picker_plugins(),
  get_git_plugins(),
  get_file_management_plugins(),
  get_database_plugins(),
  get_snippet_and_refactor_plugins(),
  get_utility_plugins()
)

return plugins
