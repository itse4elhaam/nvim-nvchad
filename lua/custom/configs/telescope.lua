return function()
  local telescope = require "telescope"
  local themes = require "telescope.themes"

  telescope.setup {
    extensions = {
      undo = {},
      ["ui-select"] = themes.get_dropdown {
        previewer = true,
      },
    },
  }

  -- Load Telescope extensions
  telescope.load_extension "undo"
  telescope.load_extension "refactoring"
  telescope.load_extension "ui-select"
  telescope.load_extension "yank_history"
  telescope.load_extension "fzf"
end
