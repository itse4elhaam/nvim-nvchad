local ui = {
  theme = "tokyonight",
  transparency = true,
  statusline = {
    theme = "default",
    separator_style = "round",
    overriden_modules = function(modules)
      local utils = require "custom.utils"
      modules[3] = "%#St_gitIcons#  " .. utils.wakatime_stats
    end,
  },
  tabufline = {
    enabled = true,
    show_numbers = false,
    overriden_modules = function(modules)
      -- Remove the buttons (theme toggle and close all buffers)
      modules[4] = ""
    end,
  },
}

return ui
