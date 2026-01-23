return {
  nes = {
    enabled = vim.g.enable_nes,
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
  copilot = {
    status = {
      enabled = true,
      level = vim.log.levels.WARN,
    },
  },
  sections = {
    haunt = {
      title = " Bookmarks",
      icon = "󱚝 ",
      enabled = true,
      update_on = "User HauntUpdate",
      get = function()
        local ok, haunt_sidekick = pcall(require, "haunt.sidekick")
        if not ok then
          return {}
        end
        return haunt_sidekick.get_locations()
      end,
    },
  },
}

