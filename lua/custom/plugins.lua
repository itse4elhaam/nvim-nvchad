local load_mappings = require("core.utils").load_mappings

local plugins = {
  -- text editing
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    opts = {
      keymaps = {
        useDefaults = true,
      },
    },
  },
  { "chrisgrieser/nvim-spider", lazy = false, keys = load_mappings "spider_motion" },
  {
    "chrisgrieser/nvim-puppeteer",
    lazy = false,
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
    "folke/todo-comments.nvim",
    event = "LspAttach",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "johmsalas/text-case.nvim",
    cmd = {
      "Subs",
      "TextCaseOpenTelescope",
      "TextCaseOpenTelescopeQuickChange",
      "TextCaseOpenTelescopeLSPChange",
      "TextCaseStartReplacingCommand",
    },
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
    -- this is equivalent to setup({}) function
  },
  {
    "rmagatti/alternate-toggler",
    config = function()
      require("alternate-toggler").setup {
        alternates = {
          ["=="] = "!=",
          ["up"] = "down",
          ["let"] = "const",
        },
      }

      vim.keymap.set(
        "n",
        "<leader><space>", -- <space><space>
        "<cmd>lua require('alternate-toggler').toggleAlternate()<CR>"
      )
    end,
    event = { "BufReadPost" }, -- lazy load after reading a buffer
  },
  {
    "gbprod/yanky.nvim",
    opts = {},
    config = require "custom.configs.yanky",
  },

  -- lsp related
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      local lint = require "lint"

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
        svelte = { "eslint_d" },
        python = { "pylint" },
      }

      vim.keymap.set("n", "<leader>ln", function()
        lint.try_lint()
      end, { desc = "lint file" })
    end,
  },
  { "chrisgrieser/nvim-rulebook", cmd = "Rulebook", keys = load_mappings "rulebook" },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    event = "LspAttach",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" }, -- if you use the mini.nvim suite
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
    "williamboman/mason.nvim",
    opts = require "custom.configs.mason",
  },
  {
    "neovim/nvim-lspconfig",
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
    "pmizio/typescript-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "neovim/nvim-lspconfig",
      {
        "saghen/blink.cmp",
        lazy = false,
        priority = 1000,
      },
    },
    ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
    opts = {},
  },
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
    -- keys = load_mappings "venv_selector",
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
    "saghen/blink.cmp",
    event = "InsertEnter",
    dependencies = "rafamadriz/friendly-snippets",
    version = "v0.*",
    opts = require "custom.configs.blink",
    opts_extend = { "sources.default" },
  },
  {
    "tronikelis/ts-autotag.nvim",
    opts = {},
    -- ft = {}, optionally you can load it only in jsx/html
    event = "VeryLazy",
  },
  {
    "Goose97/timber.nvim",
    version = "*",
    event = "VeryLazy",
    config = require "custom.configs.timber",
  },
  {
    "jdrupal-dev/code-refactor.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- keys = load_mappings "code_refactor",
    config = function()
      require("code-refactor").setup {}
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    config = require "custom.configs.textobjects",
  },
  {
    "kevinhwang91/nvim-ufo",
    requires = "kevinhwang91/promise-async",
    lazy = true,
    event = "LspAttach",
    config = require "custom.configs.ufo",
  },

  -- pickers
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

  -- Misc
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
    config = function()
      local present, wk = pcall(require, "which-key")
      if not present then
        return
      end

      wk.add {
        { "<leader>as", group = "Snippets", nowait = false, remap = false },
        {
          "<leader>asa",
          '<cmd>lua require("scissors").addNewSnippet()<CR>',
          desc = "Add new snippet",
          nowait = false,
          remap = false,
        },
        {
          "<leader>ase",
          '<cmd>lua require("scissors").editSnippet()<CR>',
          desc = "Edit snippet",
          nowait = false,
          remap = false,
        },
      }

      wk.add {
        {
          "<leader>as",
          group = "Snippets",
          mode = "x",
          nowait = false,
          remap = false,
        },
        {
          "<leader>asa",
          '<cmd>lua require("scissors").addNewSnippet()<CR>',
          desc = "Add new snippet from selection",
          mode = "x",
          nowait = false,
          remap = false,
        },
      }
    end,
  },
  {
    "vuki656/package-info.nvim",
    event = "BufEnter package.json",
    opts = {
      colors = {
        up_to_date = "#3C4048", -- Text color for up to date package virtual text
        outdated = "#fc514e", -- Text color for outdated package virtual text
      },
      icons = {
        enable = true, -- Whether to display icons
      },
      autostart = true, -- Whether to autostart when `package.json` is opened
      hide_up_to_date = true, -- It hides up to date versions when displaying virtual text
      hide_unstable_versions = true, -- It hides unstable versions from version list e.g next-11.1.3-canary3

      package_manager = "yarn",
    },
  },
  {
    "chentoast/marks.nvim",
    event = "BufEnter",
    config = true,
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      -- options
    },
  },
  {
    "nacro90/numb.nvim",
    lazy = false,
    opts = {},
  },
  {
    "MaximilianLloyd/tw-values.nvim",
    keys = {
      { "<Leader>cv", "<CMD>TWValues<CR>", desc = "Tailwind CSS values" },
    },
    opts = {
      border = "rounded", -- Valid window border style,
      show_unknown_classes = true, -- Shows the unknown classes popup
    },
  },
  {
    "dmmulroy/ts-error-translator.nvim",
    config = true,
  },
  {
    "razak17/tailwind-fold.nvim",
    opts = {
      min_chars = 50,
    },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "html", "svelte", "astro", "vue", "typescriptreact" },
  },
  {
    "Pocco81/true-zen.nvim",
    cmd = {
      "TZNarrow",
      "TZFocus",
      "TZMinimalist",
      "TZAtaraxis",
    },
    config = require "custom.configs.true-zen",
    keys = load_mappings "true_zen",
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
    opts = {
      ui = { enabled = false },
      workspaces = {
        {
          name = "personal",
          path = "/home/e4elhaam/vaults/obsidian-notes",
        },
      },
      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d-%a",
        time_format = "%H:%M",
      },
    },
  },
  {
    "mbbill/undotree",
    cmd = "UndotreeToggle",
  },
  {
    "ThePrimeagen/vim-be-good",
    cmd = "VimBeGood",
  },

  -- Task UIs
  ---@type LazySpec
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
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      lazygit = { enabled = true },
      scratch = { enabled = true },
      gitbrowse = { enabled = true },
    },
    keys = load_mappings "snacks",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod", lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd = {
      "DBUI",
      "DBUIToggle",
      "DBUIAddConnection",
      "DBUIFindBuffer",
    },
    init = function()
      -- Your DBUI configuration
      vim.g.db_ui_use_nerd_fonts = 1
    end,
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true, event = "VeryLazy" },

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
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup {
        pre_save_cmds = { "tabdo NvimTreeClose" },
      }
    end,
  },

  -- utils
  { "kevinhwang91/promise-async" },
  {
    "nvim-lua/plenary.nvim",
    config = require "custom.configs.plenary",
  },
  { "wakatime/vim-wakatime", lazy = false },
}

return plugins
