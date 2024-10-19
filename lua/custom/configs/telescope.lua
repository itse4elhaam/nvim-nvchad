return function()
  require("telescope").setup {
    extensions = {
      undo = {},
    },
  }
  require("telescope").load_extension "undo"
  require("telescope").load_extension "refactoring"
end
