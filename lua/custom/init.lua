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
opt.iskeyword = "@,48-57,_,192-255,-"
opt.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

-- Global variables
g.lazyvim_prettier_needs_config = false
g.fancyScroll = true
g.auto_ai = false
g.fancy_statusline = os.getenv "NVIM_FANCY_STATUSLINE" == "true"
g.customBigFileOpt = true
g.disableFormat = os.getenv "NVIM_DISABLE_FORMAT" == "true"
g.smear_cursor = os.getenv "NVIM_SMEAR_CURSOR" == "true"
g.enable_nes = os.getenv "NVIM_ENABLE_NES" == "true"
g.enable_inlay_hints = false -- Feature flag: disabled by default
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

api.nvim_create_autocmd("TextYankPost", {
  group = augroup "YankHistory",
  callback = function()
    if vim.v.event.operator == "y" then
      for i = 9, 1, -1 do -- Shift all numbered registers.
        vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
      end
    end
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
    local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
    if ok then
      local ts_indent = ts_configs.get_module "indent"
      ts_indent.disable = function(_, b)
        return vim.b[b] and vim.b[b].bigfile_disable
      end
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

-- Setup buffer memory (cursor position preservation)
utils.setup_buffer_memory()

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

-- Enable writing mode by default for markdown and text files
-- Disables AI completions, diagnostics, and LSP for distraction-free writing
vim.api.nvim_create_augroup("WritingMode", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = "WritingMode",
  pattern = { "markdown", "text" },
  callback = function()
    vim.defer_fn(function()
      require("custom.utils").set_writing_mode(true, { silent = true })
    end, 10)
  end,
})

-- Guard against LSP clients attaching while writing mode is active
vim.api.nvim_create_autocmd("LspAttach", {
  group = "WritingMode",
  callback = function(args)
    local ok, val = pcall(vim.api.nvim_buf_get_var, args.buf, "completion")
    if ok and val == false then
      vim.schedule(function()
        if args.data and args.data.client_id then
          pcall(vim.lsp.stop_client, args.data.client_id)
        end
      end)
    end
  end,
})

-- =============================================================================
-- Auto Theme Switcher: falcon for writing files, tokyonight for code
-- =============================================================================

-- Writing-oriented filetypes (lowercase)
local writing_filetypes = {
  markdown = true,
  mdx = true,
  pandoc = true,
  rmd = true,
  quarto = true,
  text = true,
  asciidoc = true,
  typst = true,
  latex = true,
  tex = true,
}

-- Also match by extension for buffers where filetype isn't set yet
local writing_extensions = {
  md = true,
  markdown = true,
  mdx = true,
  txt = true,
  text = true,
  rmd = true,
  qmd = true,
  typ = true,
  adoc = true,
  asciidoc = true,
  latex = true,
  tex = true,
}

-- Track current theme to avoid redundant reloads when staying in same category
local current_theme = vim.g.nvchad_theme

api.nvim_create_autocmd("BufEnter", {
  group = augroup "AutoThemeSwitcher",
  desc = "Switch between falcon (writing) and tokyonight (code) based on filetype",
  callback = function()
    -- Skip special buffers (terminals, quickfix, nvim-tree, etc.)
    if vim.bo.buftype ~= "" then
      return
    end

    local ft = vim.bo.filetype
    local bufname = vim.api.nvim_buf_get_name(0)
    local ext = vim.fn.fnamemodify(bufname, ":e"):lower()

    -- Determine if the current buffer is a writing file
    local is_writing = writing_filetypes[ft] or writing_extensions[ext]

    local target_theme = is_writing and "falcon" or "tokyonight"

    -- Skip if already on the target theme (prevents flickering/redundant reloads)
    if current_theme == target_theme then
      return
    end

    -- Switch theme using official NvChad/Base46 API
    vim.g.nvchad_theme = target_theme
    require("base46").load_all_highlights()
    current_theme = target_theme
  end,
})

-- =============================================================================
-- Final Setup
-- =============================================================================
vim.loader.enable()
