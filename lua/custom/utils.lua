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
        ["v"] = "*.vim",
        ["n"] = "*.{vim,lua}",
        ["c"] = "*.c",
        ["r"] = "*.rs",
        ["g"] = "*.go",
        ["js"] = "*.{js,jsx}",
        ["json"] = "*.json",
        ["l"] = "*.lua",
        ["lua"] = "*.lua",
        ["md"] = "*.md",
        ["styles"] = "{styles.tsx,styles.ts,styles.js,*.styles.tsx,*.styles.ts,*.styles.js}",
        ["stories"] = "{stories.tsx,stories.ts,stories.js,*.stories.tsx,*.stories.ts,*.stories.js}",
        ["test"] = "*{.test.tsx,.test.ts,.test.js,-test.tsx,-test.ts,-test.js}",
        ["tests"] = "*{.test.tsx,.test.ts,.test.js,-test.tsx,-test.ts,-test.js}",
        ["typescript"] = "*.ts",
        ["ts"] = {
          "*.{ts,tsx}",
          "!*{.test.tsx,.test.ts,.test.js,-test.tsx,-test.ts,-test.js}",
        },
        ["tsx"] = {
          "*.tsx",
          "!*{.test.tsx,.test.ts,.test.js,-test.tsx,-test.ts,-test.js}",
        },
        ["xml"] = "*.xml",
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

    local annotation

    -- Step 1: Remove markdown code block (if present) and extract the type definition
    type_info = type_info:gsub("`", "") -- Remove backticks from the type_info

    -- Step 2: Check for type in curly braces
    annotation = type_info:match "{(.*)}"
    if annotation then
      annotation = "{ " .. annotation .. " }" -- Reconstruct curly brace block
    else
      -- Step 3: Try to extract type after ":" but before "=" or end of line
      annotation = type_info:match ":([^=]*)"        -- Match everything after ":"
      if annotation then
        annotation = annotation:match "^%s*(.-)%s*$" -- Trim spaces
      end

      -- Step 4: Handle alias case like "(alias)..."
      if not annotation then
        annotation = type_info:match "%(alias%)[^:]*:%s*([^=]*)"
        if annotation then
          annotation = annotation:match "^%s*(.-)%s*$" -- Trim spaces
        end
      end
    end

    -- Step 5: If no valid annotation is found, notify and return
    if not annotation or annotation == "" then
      vim.notify("Type annotation not found in hover response", vim.log.levels.WARN)
      return
    end

    -- Copy the annotation to clipboard
    vim.fn.setreg("+", annotation) -- Copies to the clipboard
    vim.notify("Type annotation copied to clipboard: ", vim.log.levels.INFO)
  end)
end

function M.addParentheses()
  local word = vim.fn.expand "<cword>"  -- Get the word under the cursor
  local word_with_paren = word .. "\\(" -- Add `\(` to it
  require("telescope.builtin").find_files {
    prompt_title = word_with_paren,
  }
end

function M.addAngleBracket()
  local word = vim.fn.expand "<cword>"        -- Get the word under the cursor
  local word_with_angle_bracket = "<" .. word -- Add `<` to the start of it
  require("telescope.builtin").find_files {
    prompt_title = word_with_angle_bracket,
  }
end

function M.copyCurrentScopeFunction()
  -- Get the current line where the cursor is
  local line_number = vim.fn.line "."

  -- Get the line content
  local line_content = vim.fn.getline(line_number)

  -- Regular expression to match function names (for languages like JavaScript, Python, etc.)
  local function_name = line_content:match "function%s+(%w+)"
      or line_content:match "class%s+[%w_]+"
      or line_content:match "def%s+(%w+)" -- for Python

  -- If no function name is found in the current line, try searching for the function name in previous lines
  if not function_name then
    for i = line_number, 1, -1 do
      local prev_line = vim.fn.getline(i)
      function_name = prev_line:match "function%s+(%w+)"
          or prev_line:match "class%s+[%w_]+"
          or prev_line:match "def%s+(%w+)" -- for Python
      if function_name then
        break
      end
    end
  end

  -- If we find a function name, copy it to the clipboard
  if function_name then
    vim.fn.setreg("+", function_name)
    vim.notify("Copied function name: " .. function_name)
  else
    vim.notify("No function name found", vim.log.levels.WARN)
  end
end

-- this add shebang on the top and makes the file executable
function M.prepareBashFile()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file name detected", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_buf_set_lines(0, 0, 0, false, { "#!/bin/bash" })
  --  this makes sure that the file is on the disk
  vim.cmd "write"

  -- Make the file executable
  local result = vim.fn.system("chmod +x " .. vim.fn.shellescape(file))

  if vim.v.shell_error == 0 then
    vim.notify("File made executable: " .. file, vim.log.levels.INFO)
  else
    vim.notify("Failed to make executable: " .. result, vim.log.levels.WARN)
  end
end

function M.closeOtherBuffers()
  vim.cmd "mark z"               -- Save cursor position
  vim.cmd "keepjumps %bd!"       -- Delete all buffers
  vim.cmd "e#"                   -- Reopen the last active buffer
  vim.cmd "bd#"                  -- Delete the temporary buffer
  vim.cmd "keepjumps normal! 'z" -- Restore cursor position
  vim.cmd "delmark z"            -- deletes the mark
  vim.cmd "normal! zz"           -- centers you
end

function M.mergePlugins(...)
  local merged = {}
  for _, tbl in ipairs { ... } do
    for _, plugin in ipairs(tbl) do
      table.insert(merged, plugin)
    end
  end
  return merged
end

function M.clearComments()
  vim.ui.input({ prompt = "Comment string to remove (e.g., -- or //): " }, function(comment)
    if not comment or comment == "" then
      return
    end

    -- Escape Lua magic characters
    local escaped = comment:gsub("([^%w])", "%%%1")

    -- Build regex for single-line comments
    local pattern = escaped .. ".*"

    -- Delete all single-line comments
    vim.cmd("silent! %s/" .. pattern .. "//g")
  end)
end

function M.TestLearningLsp()
  local basePath = "/home/elhaam/workspace/learning/go-lsp"
  local client = vim.lsp.start_client {
    name = "learninglsp",
    cmd = { basePath .. "/main" },
    on_attach = require("plugins.configs.lspconfig").on_attach,
  }

  if not client then
    vim.notify("Failed to start LSP client: learninglsp", vim.log.levels.ERROR)
    return
  end

  vim.lsp.buf_attach_client(0, client)

  vim.notify("LSP client 'learninglsp' successfully started and attached!", vim.log.levels.INFO)
end

M.wakatime_stats = "..."
M.vim_zen = ""

local zen_quotes = {
  "🧘 zen",
  "🍃 flow",
  "✨ vibe",
  "🔥 cook",
  "⚡ zap",
  "🎯 lock",
  "🌊 wave",
  "💫 zone",
}

local function update_vim_zen()
  M.vim_zen = zen_quotes[math.random(#zen_quotes)]
  vim.cmd "redrawstatus"
end

M.buffer_size = "..."

local function update_buffer_size()
  local bufnr = vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_line_count(bufnr)

  if lines < 100 then
    M.buffer_size = "🐛 " .. lines
  elseif lines < 500 then
    M.buffer_size = "📄 " .. lines
  elseif lines < 1000 then
    M.buffer_size = "📚 " .. lines
  elseif lines < 5000 then
    M.buffer_size = "🏔️ " .. lines
  elseif lines < 10000 then
    M.buffer_size = "🌋 " .. lines
  else
    M.buffer_size = "🌌 " .. lines
  end
end

M.key_streak = 0
M.streak_display = ""

local last_key_time = 0
local streak_timer = nil

local function update_key_streak()
  local current_time = vim.loop.hrtime() / 1e9

  if current_time - last_key_time < 0.5 then
    M.key_streak = M.key_streak + 1
  else
    M.key_streak = 1
  end

  last_key_time = current_time

  if M.key_streak > 20 then
    M.streak_display = "🔥 " .. M.key_streak
  elseif M.key_streak > 10 then
    M.streak_display = "⚡ " .. M.key_streak
  else
    M.streak_display = ""
  end

  vim.cmd "redrawstatus"

  if streak_timer then
    streak_timer:stop()
  end

  streak_timer = vim.defer_fn(function()
    M.key_streak = 0
    M.streak_display = ""
    vim.cmd "redrawstatus"
  end, 1000)
end

local function update_wakatime()
  local wakatime_cli = vim.fn.expand "~/.wakatime/wakatime-cli"

  if vim.fn.filereadable(wakatime_cli) ~= 1 then
    return
  end

  vim.system({ wakatime_cli, "--today" }, {}, function(obj)
    if obj.code == 0 and obj.stdout then
      local output = obj.stdout:match "^%s*(.-)%s*$"
      if output and output ~= "" then
        local total_minutes = 0

        -- match both hr/hrs and min/mins (case-insensitive)
        for h in output:gmatch "(%d+)%s*h[r]?[s]?" do
          total_minutes = total_minutes + (tonumber(h) * 60)
        end
        for m in output:gmatch "(%d+)%s*m[i]?[n]?[s]?" do
          total_minutes = total_minutes + tonumber(m)
        end

        local total_hours = math.floor(total_minutes / 60)
        local remaining_minutes = total_minutes % 60

        -- Pick emoji based on hours coded
        local emoji = "☕"
        if total_hours == 0 then
          emoji = "🐢"
        elseif total_hours >= 1 and total_hours < 3 then
          emoji = "⚡"
        elseif total_hours >= 3 and total_hours < 5 then
          emoji = "💥"
        elseif total_hours >= 5 and total_hours < 8 then
          emoji = "🦾"
        elseif total_hours >= 8 then
          emoji = "🌀"
        end

        local total_time = ""
        if total_minutes == 0 then
          total_time = output
        elseif total_hours > 0 then
          total_time = string.format("%dh %dm", total_hours, remaining_minutes)
        else
          total_time = string.format("%dm", remaining_minutes)
        end

        M.wakatime_stats = string.format(" %s %s ", emoji, total_time)
        vim.schedule(function()
          vim.cmd "redrawstatus"
        end)
      end
    end
  end)
end

vim.defer_fn(function()
  update_wakatime()

  local timer = vim.uv.new_timer()
  timer:start(0, 900000, vim.schedule_wrap(update_wakatime))

  vim.api.nvim_create_autocmd("FocusGained", {
    callback = update_wakatime,
  })

  update_vim_zen()
  local zen_timer = vim.uv.new_timer()
  zen_timer:start(0, 300000, vim.schedule_wrap(update_vim_zen))

  vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
    callback = update_buffer_size,
  })
  update_buffer_size()

  vim.api.nvim_create_autocmd({ "TextChangedI", "TextChanged" }, {
    callback = update_key_streak,
  })
end, 100)


function M.git_push_background()
  local Job = require('plenary.job')

  local branch = vim.fn.trim(vim.fn.system("git rev-parse --abbrev-ref HEAD"))
  vim.notify("Pushing to " .. branch .. "...", vim.log.levels.INFO, { title = "Git" })

  Job:new({
    command = "bash",
    args = { "-ic", "git poc" },
    on_exit = function(j, return_val)
      if return_val == 0 then
        vim.schedule(function()
          vim.notify("Successfully pushed to " .. branch, vim.log.levels.INFO, { title = "Git" })
        end)
      else
        local error_messages = table.concat(j:stderr_result(), "\n")
        vim.schedule(function()
          vim.notify("Push failed for branch " .. branch .. ":\n" .. error_messages, vim.log.levels.ERROR, { title = "Git" })
        end)
      end
    end,
  }):start()
end

return M
