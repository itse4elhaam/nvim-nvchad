return {
  ui = { enabled = false },
  workspaces = {
    {
      name = "personal",
      path = vim.fn.expand "~/vaults/obsidian-notes",
    },
  },
  templates = {
    folder = "templates",
    date_format = "%Y-%m-%d-%a",
    time_format = "%H:%M",
  },
}
