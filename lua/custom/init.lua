local opt = vim.opt

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99

opt.relativenumber = true
vim.g.lazyvim_prettier_needs_config = false

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

vim.api.nvim_create_augroup("Shape", { clear = true })

vim.api.nvim_create_autocmd("VimLeave", {
  group = "Shape",
  -- this is for underscore
  command = "set guicursor=a:hor30"
})
