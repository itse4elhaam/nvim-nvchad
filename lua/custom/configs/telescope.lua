return function()
  local telescope = require "telescope"
  local pickers = require "telescope.pickers"
  local finders = require "telescope.finders"
  local conf = require("telescope.config").values
  local actions = require "telescope.actions"
  local action_state = require "telescope.actions.state"

  -- Setup Telescope with extensions
  telescope.setup {
    extensions = {
      undo = {}, -- Example extension
      refactoring = {}, -- Another example extension
    },
  }

  telescope.load_extension "undo"
  telescope.load_extension "refactoring"

  -- Custom function for Git conflicts
  function Git_conflict_to_telescope()
    vim.cmd "GitConflictListQf" -- Populate Quickfix list

    -- Get Quickfix items
    local qf_list = vim.fn.getqflist()

    if not qf_list or #qf_list == 0 then
      vim.notify("No Git conflicts found.", vim.log.levels.INFO)
      return
    end

    -- Populate Telescope with Quickfix items
    pickers
      .new({}, {
        prompt_title = "Git Conflicts",
        finder = finders.new_table {
          results = qf_list,
          entry_maker = function(entry)
            return {
              value = entry,
              display = entry.text,
              ordinal = entry.text,
              filename = entry.filename,
              lnum = entry.lnum,
            }
          end,
        },
        sorter = conf.generic_sorter {},
        attach_mappings = function(_, map)
          map("i", "<CR>", function(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            actions.close(prompt_bufnr)
            vim.cmd("e " .. selection.value.filename)
            vim.fn.cursor(selection.value.lnum, 0)
          end)
          return true
        end,
      })
      :find()
  end

  -- Map the command to a key
  vim.api.nvim_set_keymap("n", "<leader>fgc", ":lua Git_conflict_to_telescope()<CR>", { noremap = true, silent = true })
end
