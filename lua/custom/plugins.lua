local plugins = {
  {
    "nvim-treesitter/nvim-treesitter-context",
    lazy = false,
    config = function()
      require('treesitter-context').setup {
        enable = true,   -- Enable this plugin (Can be enabled/disabled later via commands)
        throttle = true, -- Throttle the update (may improve performance)
        max_lines = 0,   -- How many lines the window should span. Values <= 0 mean no limit.
        patterns = {     -- Match patterns for TS nodes. These get wrapped to match at word boundaries.
          -- For all filetypes
          default = {
            'class',
            'function',
            'method',
          },
        },
      }
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = function()
      require("telescope").setup({
        extensions = {
          undo = {
          },
        },
      })
      require("telescope").load_extension("undo")
      vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
    end,
  },
  {
    "rmagatti/auto-session",
    lazy = false,
    config = function()
      require("auto-session").setup({
        auto_session_enabled = true,
        auto_session_suppress_dirs = { "~/Downloads", "~/Documents" },
      })
    end,
  }, {
  "axelvc/template-string.nvim",
  config = function()
    require("template-string.nvim").setup({
      filetypes = { "html", "typescript", "javascript", "typescriptreact", "javascriptreact", "vue", "svelte", "python" },
      jsx_brackets = true,
      remove_template_string = false,
      restore_quotes = {
        normal = [["]],
        jsx = [["]],
      },
    })
  end
},
  { "wakatime/vim-wakatime",             lazy = false },
  -- todo move this to a seperate file
  {
    "0x00-ketsu/autosave.nvim",
    event = { "InsertLeave", "TextChanged" },
    config = function()
      require("autosave").setup {
        enabled = true,
        events = { "InsertLeave", "TextChanged" },
        conditions = {
          exists = true,
          filename_is_not = {},
          filetype_is_not = {},
          modifiable = true
        },
        write_all_buffers = false,
        on_off_commands = true,
        clean_command_line_interval = 0,
        debounce_delay = 100
      }
      -- local autosave_group = vim.api.nvim_create_augroup("AutoSaveFormatting", { clear = true })
      -- vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
      --   group = autosave_group,
      -- callback = function()
      --     vim.lsp.buf.format { async = false }
      --     vim.api.nvim_command("write")
      -- end,
      -- })
    end
  },
  { "williamboman/mason-lspconfig.nvim", lazy = false, opts = { auto_install = true } },
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "gopls",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    ft = "go",
    opts = function()
      return require "custom.configs.null-ls"
    end,
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
}

return plugins
