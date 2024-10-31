return function()
  require("telescope").setup {
    extensions = {
      undo = {},
      coc = {
        theme = "ivy",
        prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
        push_cursor_on_edit = true, -- save the cursor position to jump back in the future
        timeout = 3000, -- timeout for coc commands
      },
    },
  }
  require("telescope").load_extension "undo"
  require("telescope").load_extension "coc"
  require("telescope").load_extension "refactoring"
end
