local M = {}

function M.addDirective(directive)
  local bufnr = vim.api.nvim_get_current_buf()
  local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""

  if not first_line:match("^['\"]" .. directive .. "['\"]") then
    vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, { '"' .. directive .. '"' })
    print('"' .. directive .. '" added to the top of the file')
  else
    print('"' .. directive .. '" is already present')
  end
end

function M.copyDiagnosticToClip()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line "." - 1 })
  if #diagnostics == 0 then
    print "No diagnostics on this line."
    return
  end

  local diagnostic_message = diagnostics[1].message

  vim.fn.setreg("+", diagnostic_message)
  print("Copied diagnostic to clipboard: " .. diagnostic_message)
end

function M.openOrCreateFiles(filenames)
  for _, filename in ipairs(filenames) do
    -- Check if the file exists
    if vim.fn.filereadable(filename) == 1 then
      vim.cmd("edit " .. filename)
      print(filename .. " opened")
      return
    end
  end

  -- If no file exists, ask the user before creating the file
  local create_file = vim.fn.input("File not found. Do you want to create " .. filenames[1] .. "? (y/N): ")
  if create_file:lower() == "y" then
    vim.fn.writefile({}, filenames[1])
    vim.cmd("edit " .. filenames[1])
    print(filenames[1] .. " created and opened")
  else
    print "File creation aborted."
  end
end

function M.toggleDiagnostics()
  if vim.diagnostic.is_disabled(0) then
    vim.diagnostic.enable(0)
    print "Diagnostics enabled for this buffer"
  else
    vim.diagnostic.disable(0)
    print "Diagnostics disabled for this buffer"
  end
end

function M.searchGitConflicts()
  local builtin = require "telescope.builtin"
  builtin.live_grep {
    prompt_title = "Search Git Conflicts",
    default_text = "<<<<< HEAD",
    find_command = { "rg", "--files", "--glob", "*", "-t", "tracked" },
  }
end

return M
