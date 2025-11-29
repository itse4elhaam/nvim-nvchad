return {
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
        zen_toggle = {
          "<leader>zf",
          function(terminal)
            if _G.Snacks and Snacks.toggle and Snacks.toggle.zen then
              Snacks.toggle.zen()
            elseif _G.Snacks and Snacks.zen and Snacks.zen.zen then
              Snacks.zen.zen()
            else
              vim.notify("Snacks.zen not available", vim.log.levels.WARN)
            end
          end,
          mode = "t",
        },
      },
    },
  },
}