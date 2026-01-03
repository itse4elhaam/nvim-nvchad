return {
  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
      sync_root_with_pwd = true, -- Sync with project root
      key = function()
        return vim.fn.getcwd() -- Separate marks per project
      end,
    },
  },
  keys = function()
    local keys = {
      {
        "<leader>H",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon File",
      },
      {
        "<leader>h",
        function()
          local harpoon = require "harpoon"
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
      {
        "<Leader>[",
        function()
          local harpoon = require "harpoon"
          harpoon:list():prev()
        end,
        desc = "Harpoon Prev",
      },
      {
        "<Leader>]",
        function()
          local harpoon = require "harpoon"
          harpoon:list():next()
        end,
        desc = "Harpoon Next",
      },
    }

    for i = 1, 9 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon to File " .. i,
      })
    end
    return keys
  end,
}
