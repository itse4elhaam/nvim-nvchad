local opt = vim.opt

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99

opt.relativenumber = true
vim.g.lazyvim_prettier_needs_config = false

vim.api.nvim_create_augroup("PasteRemoveCarriageReturn", { clear = true })

-- adds .env to sh group
vim.cmd [[
  autocmd BufRead,BufNewFile *.env set filetype=sh
]]

-- Remove carriage returns after pasting in normal mode
vim.api.nvim_create_autocmd("VimEnter", {
  group = "PasteRemoveCarriageReturn",
  callback = function()
    vim.cmd [[
      nnoremap <silent> P :execute "normal! P" <bar> %s/\r//g<CR>
      nnoremap <silent> p :execute "normal! p" <bar> %s/\r//g<CR>
    ]]
  end,
})

-- Remove carriage returns after pasting in insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "PasteRemoveCarriageReturn",
  callback = function()
    vim.cmd [[
      nnoremap <silent> <C-r> :execute "normal! <C-r>" <bar> %s/\r//g<CR>
    ]]
  end,
})
-- Define autocmd group
vim.cmd [[
  augroup LineNumberToggle
    autocmd!
    autocmd InsertLeave * setlocal relativenumber
    autocmd InsertEnter * setlocal norelativenumber
  augroup END
]]

-- set highlight color as this
-- TODO: fix this
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("Color", {}),
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "LspReferenceRead", { fg = "#3e4451" })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { fg = "#3e4451" })
    vim.api.nvim_set_hl(0, "LspReferenceText", { fg = "#3e4451" })
  end,
})
-- highlight yanked text for 200ms using the "Visual" highlight group
vim.cmd [[
  augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=300})
  augroup END
]]

vim.api.nvim_create_augroup("Shape", { clear = true })

vim.api.nvim_create_autocmd("VimLeave", {
  group = "Shape",
  -- this is for underscore
  command = "set guicursor=a:hor30",
})

local Job = require "plenary.job"
local async = require "plenary.async"

-- Define an asynchronous function to get today's WakaTime usage
local get_wakatime_time = async.void(function()
  local tx, rx = async.control.channel.oneshot()
  local ok, job = pcall(Job.new, Job, {
    command = os.getenv "HOME" .. "/.wakatime/wakatime-cli",
    args = { "--today" },
    on_exit = function(j, _)
      tx(j:result()[1] or "No data")
    end,
  })
  if not ok then
    vim.notify("Failed to create WakaTime job: " .. job, "error")
    return
  end

  job:start()
  local result = rx()
  if result then
    print(result) -- Print the result to Neovim's command line
  end
end)

-- Define a command to execute the async function
vim.api.nvim_create_user_command("FetchWakaTime", function()
  async.run(get_wakatime_time)
end, {})

-- Optional: Set an autocommand to fetch WakaTime data on a regular basis
vim.api.nvim_create_autocmd("CursorHold", {
  pattern = "*",
  callback = function()
    async.run(get_wakatime_time)
  end,
  desc = "Fetch WakaTime data when the cursor is held in place",
})
