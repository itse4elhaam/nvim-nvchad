return function()
  local telescope = require "telescope"
  local themes = require "telescope.themes"

  telescope.setup {
    defaults = {
      cache_picker = {
        num_pickers = 10, -- Cache last 10 searches
      },
    },
    extensions = {
      undo = {},
      ["ui-select"] = themes.get_dropdown {
        previewer = true,
      },
    },
  }

  local function try_load_extension(name)
    pcall(telescope.load_extension, name)
  end

  try_load_extension "undo"
  try_load_extension "refactoring"
  try_load_extension "ui-select"
  try_load_extension "yank_history"
  try_load_extension "fzf"
  try_load_extension "textcase"
  try_load_extension "smart_open"
end
