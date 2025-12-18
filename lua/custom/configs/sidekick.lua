return {
  -- Enable Next Edit Suggestions (NES)
  nes = {
    enabled = true,
  },
  signs = {
    enabled = true,
    icon = " ",
  },
  cli = {
    mux = {
      backend = "tmux",
      enabled = true,
    },
    win = {
      keys = {
        say_hi = {
          "<c-h>",
          function()
            require("sidekick.cli").focus()
          end,
        },
      },
    },
  },
  -- Track copilot status
  copilot = {
    status = {
      enabled = true,
      level = vim.log.levels.WARN,
    },
  },
}

