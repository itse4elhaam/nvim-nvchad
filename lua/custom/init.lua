_G.dd = function(...)
  Snacks.debug.inspect(...)
end
_G.bt = function()
  Snacks.debug.backtrace()
end
if vim.fn.has "nvim-0.11" == 1 then
  vim._print = function(_, ...)
    dd(...)
  end
else
  vim.print = dd
end
-- =============================================================================
-- Options
-- =============================================================================
local opt = vim.opt
local g = vim.g
local cmd = vim.cmd
local api = vim.api

-- General
opt.relativenumber = true
opt.swapfile = false
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Global variables
g.lazyvim_prettier_needs_config = false
g.fancyScroll = true
g.auto_ai = false
g.fancy_statusline = os.getenv "NVIM_FANCY_STATUSLINE" == "true"
g.customBigFileOpt = true
g.disableFormat = os.getenv "NVIM_DISABLE_FORMAT" == "true"
g.smear_cursor = os.getenv "NVIM_SMEAR_CURSOR" == "true"
g.nvchad_hot_reload = false
g.maplocalleader = ","

-- =============================================================================
-- Autocommands
-- =============================================================================

local function augroup(name)
  return api.nvim_create_augroup("custom_" .. name, { clear = true })
end

-- Remove carriage returns after pasting in normal mode
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup "PasteRemoveCarriageReturn",
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
  group = augroup "PasteRemoveCarriageReturn",
  callback = function()
    vim.cmd [[
      silent! %s/\r//g
    ]]
  end,
})

-- Editing Enhancements
api.nvim_create_autocmd("TextYankPost", {
  group = augroup "HighlightYank",
  callback = function()
    vim.highlight.on_yank { higroup = "Visual", timeout = 300 }
  end,
})

vim.cmd [[
  augroup LineNumberToggle
    autocmd!
    autocmd InsertLeave * setlocal relativenumber
    autocmd InsertEnter * setlocal norelativenumber
  augroup END
]]

-- UI Customization
api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
  group = augroup "CustomHighlights",
  callback = function()
    local highLightClr = "#3e4451"
    api.nvim_set_hl(0, "LspReferenceRead", { fg = highLightClr })
    api.nvim_set_hl(0, "LspReferenceWrite", { fg = highLightClr })
    api.nvim_set_hl(0, "LspReferenceText", { fg = highLightClr })
    api.nvim_set_hl(0, "TabLine", { bg = "NONE" })
    api.nvim_set_hl(0, "FlashLabel", { fg = "#ffffff", bg = "#ff007c", bold = true })
  end,
})

-- api.nvim_create_autocmd("VimLeave", {
--   group = augroup "CursorShape",
--   command = "set guicursor=a:hor30",
-- })

-- Filetype-Specific Settings
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup "FiletypeDetection",
  pattern = "*.env*",
  command = "set filetype=sh",
})

api.nvim_create_autocmd("FileType", {
  group = augroup "FormatOptions",
  command = "set formatoptions-=ro",
})

api.nvim_create_autocmd("FileType", {
  group = augroup "SqlSettings",
  pattern = { "sql", "mysql", "psql" },
  callback = function()
    vim.bo.commentstring = "-- %s"
  end,
})

api.nvim_create_autocmd("FileType", {
  group = augroup "UfoDetach",
  pattern = { "nvcheatsheet", "neo-tree", "dbui", "dbee" },
  callback = function()
    if pcall(require, "ufo") then
      require("ufo").detach()
      vim.opt_local.foldenable = false
    end
  end,
})

-- Performance for large files
api.nvim_create_autocmd("BufReadPre", {
  group = augroup "BigFilePerformance",
  callback = function(args)
    local bufnr = args.buf
    local max_filesize = 500 * 1024 -- 500 KB
    local ok, size = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
    if not ok or not size or size.size < max_filesize or not g.customBigFileOpt then
      return
    end

    vim.b[bufnr].bigfile_disable = true
    local ts_indent = require("nvim-treesitter.configs").get_module "indent"
    ts_indent.disable = function(_, b)
      return vim.b[b] and vim.b[b].bigfile_disable
    end
    vim.bo[bufnr].autoindent = false
    vim.bo[bufnr].smartindent = false
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.statuscolumn = ""
    vim.opt_local.hlsearch = false
    vim.opt_local.wrap = false
    vim.opt_local.cursorline = false
    vim.opt_local.swapfile = false
    vim.opt_local.spell = false
  end,
})

-- LSP and Integrations
api.nvim_create_autocmd("BufReadPost", {
  group = augroup "LspManagement",
  callback = function()
    if vim.api.nvim_buf_get_name(0):match "env" then
      for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
        vim.lsp.stop_client(client.id)
      end
    end
  end,
})

api.nvim_create_autocmd("LspAttach", {
  group = augroup "LspCustomAttach",
  callback = function(_)
    for _, client in ipairs(vim.lsp.get_clients {}) do
      if client.name == "tailwindcss" then
        client.server_capabilities.completionProvider.triggerCharacters =
        { '"', "'", "`", ".", "(", "[", "!", "/", ":" }
      end
    end
  end,
})

api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
  group = augroup "TmuxIntegration",
  callback = function()
    if vim.env.TMUX_PLUGIN_MANAGER_PATH then
      vim.loop.spawn(vim.env.TMUX_PLUGIN_MANAGER_PATH .. "/tmux-window-name/scripts/rename_session_windows.py", {})
    end
  end,
})

-- =============================================================================
-- User Commands
-- =============================================================================
local utils = require "custom.utils"

api.nvim_create_user_command("TestLearningLsp", function()
  utils.TestLearningLsp()
end, { desc = "Test the custom LSP client: learninglsp" })

api.nvim_create_user_command("RemoveComments", function()
  utils.clearComments()
end, { desc = "Remove all comments from the current buffer" })

api.nvim_create_user_command("ToggleESLint", function()
  local eslint_clients = vim.lsp.get_clients { name = "eslint" }
  if #eslint_clients > 0 then
    for _, client in ipairs(eslint_clients) do
      vim.lsp.stop_client(client.id)
    end
    print "ESLint disabled"
  else
    cmd "LspStart eslint"
    print "ESLint enabled"
  end
end, { desc = "Toggle ESLint LSP server" })

-- =============================================================================
-- Final Setup
-- =============================================================================
vim.loader.enable()
