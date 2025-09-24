return {
  opts = {
    default_strategy = "chat",
    strategies = {
      chat = {
        adapter = "gemini",
      },
      inline = {
        adapter = "gemini",
      },
      cmd = {
        adapter = "gemini",
      },
    },
    adapters = {
      http = {
        gemini = function()
          local api_key = vim.fn.getenv "GEMINI_API_KEY"
          if api_key == vim.NIL or api_key == "" then
            error "GEMINI_API_KEY environment variable is not set. Please set it in your shell."
          end

          return require("codecompanion.adapters").extend("gemini", {
            env = {
              api_key = api_key,
            },
            schema = {
              model = {
                default = "gemini-2.5-flash",
              },
            },
          })
        end,
      },
      acp = {
        qwen = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "oauth-personal",
            },
          })
        end,
      },
    },
    chat = {
      layout = "float",
      width = 80,
      height = 20,
    },
    keymaps = {
      chat = "<leader>cc",
      actions = "<leader>ca",
    },
    extensions = {
      history = {
        enabled = true,
        opts = {
          keymap = "gh",
          save_chat_keymap = "sc",
          auto_save = false,
          auto_generate_title = true,
          continue_last_chat = false,
          delete_on_clearing_chat = false,
          picker = "telescope",
          enable_logging = false,
          dir_to_save = vim.fn.stdpath "data" .. "/codecompanion-history",
        },
      },
      mcphub = {
        callback = "mcphub.extensions.codecompanion",
        opts = {
          make_vars = true,
          make_slash_commands = true,
          show_result_in_chat = true,
        },
      },
    },
  },
  dependencies = {
    "ravitemer/codecompanion-history.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "ravitemer/mcphub.nvim",
      cmd = "MCPHub",
      build = "npm install -g mcp-hub@latest",
      config = true,
    },
  },
}
