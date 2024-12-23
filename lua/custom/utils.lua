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

M.multiGrep = function(opts)
  local conf = require("telescope.config").values
  local finders = require "telescope.finders"
  local make_entry = require "telescope.make_entry"
  local pickers = require "telescope.pickers"

  local flatten = vim.tbl_flatten

  -- i would like to be able to do telescope
  -- and have telescope do some filtering on files and some grepping

  opts = opts or {}
  opts.cwd = opts.cwd and vim.fn.expand(opts.cwd) or vim.loop.cwd()
  opts.shortcuts = opts.shortcuts
    or {
      ["l"] = "*.lua",
      ["v"] = "*.vim",
      ["n"] = "*.{vim,lua}",
      ["c"] = "*.c",
      ["r"] = "*.rs",
      ["g"] = "*.go",
    }
  opts.pattern = opts.pattern or "%s"

  local custom_grep = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      -- splitting it so that we can search in .txs files only with this -> test  *.tsx, this is split by space
      local prompt_split = vim.split(prompt, "  ")

      -- this gives the actual prompt
      local args = { "rg" }
      if prompt_split[1] then
        table.insert(args, "-e")
        table.insert(args, prompt_split[1])
      end

      -- this gives the flags
      if prompt_split[2] then
        table.insert(args, "-g")

        local pattern
        if opts.shortcuts[prompt_split[2]] then
          pattern = opts.shortcuts[prompt_split[2]]
        else
          pattern = prompt_split[2]
        end

        table.insert(args, string.format(opts.pattern, pattern))
      end

      return flatten {
        args,
        { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
      }
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  }

  pickers
    .new(opts, {
      debounce = 100,
      prompt_title = "Live Grep (with shortcuts)",
      finder = custom_grep,
      previewer = conf.grep_previewer(opts),
      sorter = require("telescope.sorters").empty(),
    })
    :find()
end

function M.copyTypeDefinition()
  local params = vim.lsp.util.make_position_params()

  vim.lsp.buf_request(0, "textDocument/hover", params, function(err, result, ctx, config)
    if err then
      vim.notify("Error fetching type: " .. err.message, vim.log.levels.ERROR)
      return
    end
    if not result or not result.contents then
      vim.notify("No type definition available", vim.log.levels.WARN)
      return
    end

    -- Convert hover contents to markdown lines
    local type_info = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    if type(type_info) == "table" then
      type_info = table.concat(type_info, "\n")
    end

    -- Extract the type definition block between curly braces
    local annotation = type_info:match "{.*}"
    if not annotation then
      vim.notify("Type annotation not found in hover response", vim.log.levels.WARN)
      return
    end

    -- Copy the annotation to the clipboard
    vim.fn.setreg("+", annotation)
    vim.notify("Copied type annotation to clipboard:\n" .. annotation, vim.log.levels.INFO)
  end)
end

return M
