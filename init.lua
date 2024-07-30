require "core"

local custom_init_path = vim.api.nvim_get_runtime_file("lua/custom/init.lua", false)[1]

if custom_init_path then
  dofile(custom_init_path)
end

require("core.utils").load_mappings()

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

-- bootstrap lazy.nvim!
if not vim.loop.fs_stat(lazypath) then
  require("core.bootstrap").gen_chadrc_template()
  require("core.bootstrap").lazy(lazypath)
end


vim.api.nvim_create_augroup('PasteRemoveCarriageReturn', { clear = true })
-- Remove carriage returns after pasting in normal mode
vim.api.nvim_create_autocmd('VimEnter', {
  group = 'PasteRemoveCarriageReturn',
  callback = function()
    vim.cmd([[
      nnoremap <silent> P :execute "normal! P" <bar> %s/\r//g<CR>
      nnoremap <silent> p :execute "normal! p" <bar> %s/\r//g<CR>
    ]])
  end
})

-- todo move these from here
-- Remove carriage returns after pasting in insert mode
vim.api.nvim_create_autocmd('InsertLeave', {
  group = 'PasteRemoveCarriageReturn',
  callback = function()
    vim.cmd([[
      nnoremap <silent> <C-r> :execute "normal! <C-r>" <bar> %s/\r//g<CR>
    ]])
  end
})
-- Define autocmd group
vim.cmd [[
  augroup LineNumberToggle
    autocmd!
    autocmd InsertLeave * setlocal relativenumber
    autocmd InsertEnter * setlocal norelativenumber
  augroup END
]]

-- highlight yanked text for 200ms using the "Visual" highlight group
vim.cmd [[
  augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=300})
  augroup END
]]

-- Autocmd to open NvimTree on startup if no file is specified
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local buffer_name = vim.api.nvim_buf_get_name(0)
    if buffer_name == "" or buffer_name == nil then
      vim.cmd("NvimTreeToggle")
    end
  end,
})
dofile(vim.g.base46_cache .. "defaults")
vim.opt.rtp:prepend(lazypath)
require "plugins"
