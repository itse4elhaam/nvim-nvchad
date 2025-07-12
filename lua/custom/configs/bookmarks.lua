return {
  cmd = { "BookmarksMark", "BookmarksGoto", "BookmarksNewList", "BookmarksLists", "BookmarksCommands" },
  dependencies = {
    { "kkharji/sqlite.lua" },
    { "nvim-telescope/telescope.nvim" },
    { "stevearc/dressing.nvim" },
  },
  config = function()
    local opts = {}
    require("bookmarks").setup(opts)
  end,
}
