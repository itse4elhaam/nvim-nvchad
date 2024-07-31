-- lua/custom/utils.lua

local M = {}

M.open_nvim_tree_if_no_buffers = function()
  -- Get the list of open buffers
  local buffers = vim.api.nvim_list_bufs()

  -- Check if there are no buffers open
  local no_buffers_open = true
  for _, buf in ipairs(buffers) do
    if vim.api.nvim_buf_get_name(buf) ~= "" then
      no_buffers_open = false
      break
    end
  end

  -- Open NvimTree in full-screen mode if no buffers are open
  if no_buffers_open then
    -- Use vim.schedule to ensure NvimTree is fully loaded
    vim.schedule(function()
      -- Close all windows except the current one to make NvimTree full-screen
      vim.cmd("only")
      -- Ensure the NvimTree plugin is loaded
      if vim.fn.exists(":NvimTreeToggle") == 2 then
        vim.cmd("NvimTreeToggle")
        -- Set the width of NvimTree to 100%
        vim.cmd("NvimTreeResize 100")
      else
        print("NvimTree command not available.")
      end
    end)
  end
end

return M
