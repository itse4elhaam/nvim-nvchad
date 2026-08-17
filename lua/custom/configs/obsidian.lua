return function()
  local defaults = require("obsidian.config").MappingOpts.default()
  defaults["gd"] = {
    action = "<cmd>ObsidianFollowLink<CR>",
    opts = { buffer = true, desc = "Obsidian: follow link" },
  }

  return {
    ui = { enabled = false },
    workspaces = {
      {
        name = "personal",
        path = vim.fn.expand "~/personal/notes/obsidian-notes",
      },
    },
    notes_subdir = "Fleeting",
    new_notes_location = "notes_subdir",
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },
    mappings = defaults,
  }
end
