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
    note_id_func = function(title)
      -- Slug the title into the filename with a timestamp prefix to avoid collisions
      local suffix = ""
      if title ~= nil then
        suffix = title:gsub(" ", "-"):gsub("[^%w%-_]", ""):lower()
      end
      if suffix == "" then
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. "-" .. suffix
    end,
    templates = {
      folder = "templates",
      date_format = "%Y-%m-%d-%a",
      time_format = "%H:%M",
    },
    mappings = defaults,
  }
end
