local opt = vim.opt

-- opt.foldmethod = "expr"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"
-- opt.foldlevelstart = 99

opt.relativenumber = true
vim.g.lazyvim_prettier_needs_config = false
vim.g.fancyScroll = true
vim.g.customBigFileOpt = true
vim.o.swapfile = false
vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.g.disableFormat = false

vim.api.nvim_create_augroup("PasteRemoveCarriageReturn", { clear = true })
vim.g.maplocalleader = ","

-- adds .env to sh group
vim.cmd [[
  autocmd BufRead,BufNewFile *.env* set filetype=sh
]]

-- removes out commenting of next lines
vim.cmd [[autocmd FileType * set formatoptions-=ro]]

-- Remove carriage returns after pasting in normal mode
vim.api.nvim_create_autocmd("VimEnter", {
  group = "PasteRemoveCarriageReturn",
  callback = function()
    vim.cmd [[
      nnoremap <silent> P :execute "normal! P" <bar> silent! %s/\r//g<CR>
      nnoremap <silent> p :execute "normal! p" <bar> silent! %s/\r//g<CR>
    ]]
  end,
})

-- Remove carriage returns after pasting in insert mode
-- nnoremap <silent> <C-r> :execute "normal! <C-r>" <bar> silent! %s/\r//g<CR>
vim.api.nvim_create_autocmd("InsertLeave", {
  group = "PasteRemoveCarriageReturn",
  callback = function()
    vim.cmd [[
      silent! %s/\r//g
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

local highLightClr = "#3e4451"

-- set highlight color as this
vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = vim.api.nvim_create_augroup("Color", {}),
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "LspReferenceRead", { fg = highLightClr })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { fg = highLightClr })
    vim.api.nvim_set_hl(0, "LspReferenceText", { fg = highLightClr })
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

local uv = vim.loop

vim.api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
  callback = function()
    if vim.env.TMUX_PLUGIN_MANAGER_PATH then
      uv.spawn(vim.env.TMUX_PLUGIN_MANAGER_PATH .. "/tmux-window-name/scripts/rename_session_windows.py", {})
    end
  end,
})

-- vim.api.nvim_create_autocmd("CmdlineEnter", {
--   callback = function()
--     vim.api.nvim_set_keymap("c", "<CR>", "<CR>", { noremap = true, silent = true })
--   end,
-- })

-- this is for testing the lsp I made
function TestLearningLsp()
  local client = vim.lsp.start_client {
    name = "learninglsp",
    cmd = { "/home/e4elhaam/coding/projects/go-lsp/main" },
    on_attach = require("plugins.configs.lspconfig").on_attach,
  }

  if not client then
    vim.notify("Failed to start LSP client: learninglsp", vim.log.levels.ERROR)
    return
  end

  vim.lsp.buf_attach_client(0, client)

  vim.notify("LSP client 'learninglsp' successfully started and attached!", vim.log.levels.INFO)
end

vim.api.nvim_create_user_command(
  "TestLearningLsp", -- The command name
  function()
    TestLearningLsp()
  end,
  { desc = "Test the custom LSP client: learninglsp" } -- Optional description
)

local eslint_active = false

vim.api.nvim_create_user_command("ToggleESLint", function()
  eslint_active = not eslint_active
  if eslint_active then
    vim.lsp.start_client { name = "eslint" }
    print "ESLint enabled"
  else
    vim.lsp.stop_client(vim.lsp.get_active_clients({ name = "eslint" })[1].id)
    print "ESLint disabled"
  end
end, {})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local filetypes = { "sql", "mysql", "psql" }
    if vim.tbl_contains(filetypes, vim.bo.filetype) then
      vim.bo.commentstring = "-- %s"
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match "env" then
      vim.lsp.stop_client(vim.lsp.get_clients { bufnr = 0 })
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "nvcheatsheet", "neo-tree", "dbui" },
  callback = function()
    require("ufo").detach()
    vim.opt_local.foldenable = false
  end,
})

vim.loader.enable()

vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  desc = "Disable features on big files",
  callback = function(args)
    local bufnr = args.buf
    local size = vim.fn.getfsize(vim.fn.expand "%")
    local max_filesize = 500 * 1024

    if size < max_filesize or not vim.g.customBigFileOpt then
      return
    end

    vim.b[bufnr].bigfile_disable = true

    -- Set up Treesitter module disable
    local module = require("nvim-treesitter.configs").get_module "indent"
    module.disable = function(lang, bufnr)
      return vim.b[bufnr].bigfile_disable == true
    end

    -- Disable autoindent
    vim.bo.indentexpr = ""
    vim.bo.autoindent = false
    vim.bo.smartindent = false
    -- Disable folding
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.foldexpr = "0"
    -- Disable statuscolumn
    vim.opt_local.statuscolumn = ""
    -- Disable search highlight
    vim.opt_local.hlsearch = false
    -- Disable line wrapping
    vim.opt_local.wrap = false
    -- Disable cursorline
    vim.opt_local.cursorline = false
    -- Disable swapfile
    vim.opt_local.swapfile = false
    -- Disable spell checking
    vim.opt_local.spell = false
  end,
})
-- had to use this post nvim v11 upgrade because the buffer background colors were weird
vim.api.nvim_set_hl(0, "TabLine", { bg = "NONE" })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    for _, client in pairs((vim.lsp.get_clients {})) do
      if client.name == "tailwindcss" then
        client.server_capabilities.completionProvider.triggerCharacters =
        { '"', "'", "`", ".", "(", "[", "!", "/", ":" }
      end
    end
  end,
})
