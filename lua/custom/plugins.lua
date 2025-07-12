-- lua/custom/plugins.lua

-- This file is now organized into functional categories.
-- Each category is a function that returns a list of plugins.
-- The final `plugins` table is a merged list of all categories.

local load_mappings = require("core.utils").load_mappings

local merge_plugins = require("custom.utils").mergePlugins

---@return table
local function get_ai_plugins()
  return {
    {
      "olimorris/codecompanion.nvim",
      cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
      opts = require "custom.configs.codecompanion",
      dependencies = {
        "ravitemer/codecompanion-history.nvim", -- Save and load conversation history
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        {
          "ravitemer/mcphub.nvim", -- Manage MCP servers
          cmd = "MCPHub",
          build = "npm install -g mcp-hub@latest",
          config = true,
        },
      },
      keys = load_mappings "code_companion",
    },
    {
      "zbirenbaum/copilot.lua",
      enabled = true,
      cmd = "Copilot",
      event = "InsertEnter",
      config = function()
        require("copilot").setup {}
      end,
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
      config = function()
        require("tabout").setup {
          tabkey = "<Tab>",             -- key to trigger tabout, set to an empty string to disable
          backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
          act_as_tab = true,            -- shift content if tab out is not possible
          act_as_shift_tab = false,     -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
          default_tab = "<C-t>",        -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
          default_shift_tab = "<C-d>",  -- reverse shift default action,
          enable_backwards = true,      -- well ...
          completion = false,           -- if the tabkey is used in a completion pum
          tabouts = {
            { open = "'", close = "'" },
            { open = '"', close = '"' },
            { open = "`", close = "`" },
            { open = "(", close = ")" },
            { open = "[", close = "]" },
            { open = "{", close = "}" },
          },
          ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
          exclude = {}, -- tabout will ignore these filetypes
        }
      end,
      dependencies = { -- These are optional
        "nvim-treesitter/nvim-treesitter",
      },
      opt = true,              -- Set this to true if the plugin is optional
      event = "InsertCharPre", -- Set the event to 'InsertCharPre' for better compatibility
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
    },
    {
      "rmagatti/alternate-toggler",
      config = function()
        require("alternate-toggler").setup {
          alternates = {
            ["=="] = "!=",
            ["up"] = "down",
            ["let"] = "const",
            ["development"] = "production",
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
      config = true, -- run require("stay-in-place").setup()
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
      keys = {
        { "s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
        { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
        { "r",     mode = "o",               function() require("flash").remote() end,            desc = "Remote Flash" },
        { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
      },
    },
    {
      "christoomey/vim-tmux-navigator",
      cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
        "TmuxNavigatorProcessList",
      },
      keys = load_mappings "vim_tmux_navigator",
    },
    { "chrisgrieser/nvim-spider", lazy = false, keys = load_mappings "spider_motion" },
    {
      "danielfalk/smart-open.nvim",
      lazy = false,
      branch = "0.2.x",
      dependencies = {
        "kkharji/sqlite.lua",
        -- Only required if using match_algorithm fzf
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        -- Optional.  If installed, native fzy will be used when match_algorithm is fzy
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
    {
      "folke/trouble.nvim",
      enabled = false,
      opts = {},
      cmd = "Trouble",
      keys = require "custom.configs.trouble",
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
      opts = {
        -- options
      },
    },
  }
end

---@return table
local function get_language_specific_plugins()
  return {
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
      opts = {
        on_attach = function(client, bufnr)
          -- Disable formatting to use a dedicated formatter (like conform.nvim or null-ls)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false

          -- Disable semantic tokens for large files (prevents lag)
          -- TODO: check if you need this or not
          -- if vim.api.nvim_buf_line_count(bufnr) > 3500 then
          --   client.server_capabilities.semanticTokensProvider = nil
          -- end
        end,
        settings = {
          tsserver_disable_suggestions = true,
          tsserver_log_verbosity = "off",
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "all",
            includeCompletionsForModuleExports = true,
            includeCompletionsWithInsertText = true,
          },
          tsserver_format_options = {}, -- Explicitly empty to disable formatting
          expose_as_code_action = {
            "fix_all",
            "add_missing_imports",
            "remove_unused",
            "remove_unused_imports",
            "organize_imports",
          },
          tsserver_max_memory = 8192, -- MB
          tsserver_fsa_use_browser_implementation = false,
        },
      },
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
      "MaximilianLloyd/tw-values.nvim",
      keys = {
        { "<Leader>cv", "<CMD>TWValues<CR>", desc = "Tailwind CSS values" },
      },
      opts = {
        border = "rounded",          -- Valid window border style,
        show_unknown_classes = true, -- Shows the unknown classes popup
      },
    },
    {
      "dmmulroy/ts-error-translator.nvim",
      config = true,
    },
    {
      "razak17/tailwind-fold.nvim",
      enabled = false,
      opts = {
        min_chars = 100,
      },
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      ft = { "html", "svelte", "astro", "vue", "typescriptreact" },
    },
    {
      "vuki656/package-info.nvim",
      dependencies = { "MunifTanjim/nui.nvim" },
      event = "BufEnter package.json",
      opts = {
        colors = {
          up_to_date = "#3C4048", -- Text color for up to date package virtual text
          outdated = "#fc514e",   -- Text color for outdated package virtual text
        },
        icons = {
          enable = true,               -- Whether to display icons
        },
        autostart = true,              -- Whether to autostart when `package.json` is opened
        hide_up_to_date = true,        -- It hides up to date versions when displaying virtual text
        hide_unstable_versions = true, -- It hides unstable versions from version list e.g next-11.1.3-canary3

        package_manager = "yarn",
      },
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
      "rasulomaroff/reactive.nvim",
      enabled = false,
      event = "VeryLazy",
      config = function()
        require("reactive").setup {
          builtin = {
            cursorline = true,
            cursor = true,
            modemsg = true,
          },
        }
      end,
    },
    {
      "jinh0/eyeliner.nvim",
      enabled = true,
      lazy = false,
      config = function()
        require("eyeliner").setup {
          -- show highlights only after keypress
          highlight_on_key = true,

          -- dim all other characters if set to true (recommended!)
          dim = false,

          -- set the maximum number of characters eyeliner.nvim will check from
          -- your current cursor position; this is useful if you are dealing with
          -- large files: see https://github.com/jinh0/eyeliner.nvim/issues/41
          max_length = 9999,

          -- filetypes for which eyeliner should be disabled;
          -- e.g., to disable on help files:
          -- disabled_filetypes = {"help"}
          disabled_filetypes = {},

          -- buftypes for which eyeliner should be disabled
          -- e.g., disabled_buftypes = {"nofile"}
          disabled_buftypes = {},

          -- add eyeliner to f/F/t/T keymaps;
          -- see section on advanced configuration for more information
          default_keymaps = true,
        }
      end,
    },
    {
      "sphamba/smear-cursor.nvim",
      enabled = true,
      lazy = false,
      opts = {
        smear_between_buffers = true,
        smear_between_neighbor_lines = true,
        smear_horizontally = true,
        smear_vertically = true,
        smear_diagonally = true,

        smear_to_cmd = true,
        smear_insert_mode = true,
        smear_replace_mode = false,
        smear_terminal_mode = false,

        vertical_bar_cursor = true,
        vertical_bar_cursor_insert_mode = true,
        horizontal_bar_cursor_replace_mode = true,

        never_draw_over_target = true,
        hide_target_hack = false,

        time_interval = 16, -- ~60FPS
        delay_event_to_smear = 2,
        delay_after_key = 4,

        -- Main mode animation
        stiffness = 0.8,                -- Snappy cursor
        trailing_stiffness = 0.45,      -- A bit of trailing effect
        trailing_exponent = 2,          -- Curve favors the head
        distance_stop_animating = 0.15, -- Stops early for crispness

        -- Insert mode animation
        stiffness_insert_mode = 0.55,
        trailing_stiffness_insert_mode = 0.35,
        trailing_exponent_insert_mode = 1.2,
        distance_stop_animating_vertical_bar = 0.6,

        -- Smear limits
        max_length = 20,
        max_length_insert_mode = 1,
      },
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
      opts = {
        bigfile = { enabled = true },
        zen = {
          enabled = true,
          on_open = function(_)
            vim.fn.system "tmux set-option status off"
          end,
          --- Callback when the window is closed.
          ---@param win snacks.win
          on_close = function(_)
            vim.fn.system "tmux set-option status on"
          end,
          --- Options for the `Snacks.zen.zoom()`
          ---@type snacks.zen.Config
          zoom = {
            toggles = {},
            show = { statusline = false, tabline = false },
            win = {
              backdrop = false,
              width = 0, -- full width
            },
          },
        },
        quickfile = { enabled = true },
        lazygit = { enabled = true },
        scratch = { enabled = true },
        gitbrowse = { enabled = true },
        notifier = { enabled = true },
        scroll = {
          enabled = false,
          animate = {
            duration = { step = 12, total = 180 }, -- nice and smooth
          },
          animate_repeat = {
            delay = 80,                         -- if next scroll happens within 80ms, use fast mode
            duration = { step = 1, total = 1 }, -- basically instant
          },
        },
      },
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
      cmd = { "BookmarksMark", "BookmarksGoto", "BookmarksNewList", "BookmarksLists", "BookmarksCommands" },
      dependencies = {
        { "kkharji/sqlite.lua" },
        { "nvim-telescope/telescope.nvim" },
        { "stevearc/dressing.nvim" },
      },
      config = function()
        local opts = {}
        require("bookmarks").setup(opts)
      end,
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
      ---@module 'oil'
      ---@type oil.SetupOpts
      opts = {
        default_file_explorer = false,
      },
      -- Optional dependencies
      dependencies = { { "echasnovski/mini.icons", opts = {} } },
      -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
      -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
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
        -- Install tries to automatically detect the install method.
        -- if it fails, try calling it with one of these parameters:
        --    "curl", "wget", "bitsadmin", "go"
        require("dbee").install()
      end,
      config = function()
        require("dbee").setup( --[[optional config]])
      end,
    },
    {
      "kristijanhusak/vim-dadbod-ui",
      dependencies = {
        { "tpope/vim-dadbod",                     lazy = true },
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
      "jdrupal-dev/code-refactor.nvim",
      enabled = false,
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      -- keys = load_mappings "code_refactor",
      config = function()
        require("code-refactor").setup {}
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
