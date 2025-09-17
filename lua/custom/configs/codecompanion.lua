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
      acp = {
        qwen = function()
          return require("codecompanion.adapters").extend("gemini_cli", {
            defaults = {
              auth_method = "oauth-personal",
            },
          })
        end,
      },
      gemini = function()
        return require("codecompanion.adapters").extend("gemini", {
          env = {
            api_key = "GEMINI_API_KEY",
          },
          schema = {
            model = {
              default = "gemini-2.5-pro",
            },
          },
        })
      end,
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
