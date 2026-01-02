local ui = {
  theme = "tokyonight",
  transparency = true,
  statusline = {
    theme = "default",
    separator_style = "round",
    overriden_modules = function(modules)
      -- Available highlight groups (from statusline/default.lua):
      -- %#St_NormalMode# - Blue background (mode colors)
      -- %#St_LspStatus# - White text with background
      -- %#St_gitIcons# - White text, no background
      -- %#St_lspError# - Red text
      -- %#St_lspWarning# - Yellow text
      -- %#St_lspHints# - Cyan text
      -- %#St_lspInfo# - Blue text
      -- %#St_cwd_icon# - Folder icon color
      -- %#St_cwd_text# - White text with background
      -- %#St_file_info# - File info colors
      -- %#St_pos_text# - Position text

      -- Module positions:
      -- 1=mode, 2=fileInfo, 3=git, 4=%=, 5=LSP_progress, 6=%=, 7=LSP_Diagnostics, 8=LSP_status, 9=cwd, 10=cursor_position

      local utils = require "custom.utils"
      if vim.g.fancy_statusline then
        modules[3] = "%#St_gitIcons#" .. " " .. utils.vim_zen .. " "
        modules[7] = modules[7] .. utils.nes_status -- Add NES status after LSP diagnostics
        modules[8] = "%#St_lspHints#" .. " " .. utils.buffer_size .. " "
        modules[9] = (function()
          if utils.streak_display ~= "" then
            return "%#St_lspWarning#" .. " " .. utils.streak_display .. " "
          else
            return ""
          end
        end)()
        modules[10] = "%#St_file_txt#" .. " | " .. utils.wakatime_stats
      else
        modules[3] = ""
        modules[7] = modules[7] .. utils.nes_status -- Add NES status even in non-fancy mode
        modules[8] = ""
        modules[9] = ""
        modules[10] = "%#St_file_txt#" .. utils.wakatime_stats
      end
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
