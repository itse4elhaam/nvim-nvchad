return {
  nes = {
    enabled = true,
    debounce = 1000,
    triggers = {
      "TextChanged",
      "ModeChanged i:n",
    },
    diff = {
      inline = true,
      virt_text = {
        add = { text = "+", hl = "DiffAdd" },
        delete = { text = "-", hl = "DiffDelete" },
        change = { text = "~", hl = "DiffChange" },
      },
    },
  },

  -- CLI integration configuration
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
}
