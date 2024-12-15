---@diagnostic disable: undefined-field
-- remap functions:

local M = {}

local utils = require "custom.utils"

M.gopher = {
  plugin = true,
  n = {
    ["<leader>gsj"] = {
      "<cmd> GoTagAdd json <CR>",
      "Add json struct tags",
    },
    ["<leader>gsy"] = {
      "<cmd> GoTagAdd yaml <CR>",
      "Add yaml struct tags",
    },
  },
}

M.general = {
  n = {
    ["<leader>rc"] = {
      function()
        local word = vim.fn.expand "<cword>"
        vim.cmd("normal! ciw<" .. word .. " />")
      end,
      "Wrap word under cursor with < />",
    },

    ["<leader>ctl"] = {
      function()
        require("timber.actions").clear_log_statements { global = false }
      end,
      "Clear timber log statements in current buffer",
    },

    -- NOTE: this is WSL specific
    ["gx"] = { "<CMD>execute '!wslview ' .. shellescape(expand('<cfile>'), v:true)<CR>", "Open file with xdg-open" },

    ["<leader>gw"] = {
      function()
        require("telescope.builtin").live_grep {
          default_text = vim.fn.expand "<cword>",
        }
      end,
      "Live grep current word",
    },
    ["<leader>fk"] = {
      function()
        require("telescope.builtin").keymaps()
      end,
      "Live grep current word",
    },

    -- NOTE: added this here because core ones were not working
    ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<CR>" },
    ["<leader>ra"] = {
      "<cmd>lua require('nvchad.renamer').open()<CR>",
      "LSP rename",
    },

    -- remaps for tabs
    ["<leader>tn"] = { "<cmd>tabnext<CR>", "Go to next tab" },
    ["<leader>tx"] = { "<cmd>tabclose<CR>", "Go to next tab" },
    ["<leader>tp"] = { "<cmd>tabprevious<CR>", "Go to previous tab" },
    ["<leader>t1"] = { "<cmd>tabn 1<CR>", "Go to tab 1" },
    ["<leader>t2"] = { "<cmd>tabn 2<CR>", "Go to tab 2" },

    ["<leader>du"] = { "<cmd>DBUIToggle<CR>", "Toggle Dadbod UI in a new tab" },
    ["<leader>,"] = { "mzA,<Esc>`z", "Add comma to the end of the line" },
    ["zR"] = { "<cmd>lua require('ufo').openAllFolds()<CR>", "Open all folds" },
    ["zM"] = { "<cmd>lua require('ufo').closeAllFolds()<CR>", "Close all folds" },
    ["K"] = {
      function()
        local winid = require("ufo").peekFoldedLinesUnderCursor()
        if not winid then
          vim.lsp.buf.hover()
        end
      end,
      "Peek Fold/Hover",
    },
    ["<leader>uc"] = {
      function()
        utils.addDirective "use client"
      end,
      "Add 'use client' to the top of the file",
    },
    ["<leader>us"] = {
      function()
        utils.addDirective "use server"
      end,
      "Add 'use server' to the top of the file",
    },
    ["ul"] = { "O<Esc>:normal j<CR>", "Insert line above and move down" },
    ["dl"] = { "o<Esc>:normal k<CR>", "Insert line below and move up" },
    ["<leader>esf"] = { "<cmd> EslintFixAll <CR>" },
    ["<C-sa>"] = { "<cmd> wa <CR>", "Save file" },
    ["<leader>tdg"] = {
      function()
        utils.toggleDiagnostics()
      end,
      "Toggle Diagnostics",
    },
    ["<leader>as"] = { "<cmd>ASToggle<CR>", "Toggle auto save" },
    ["<leader>lz"] = { "<cmd>Lazy<CR>", "Open Lazy" },
    ["<leader>cp"] = { ":bd | q<CR>", "Close Buffer/Pane" },
    -- lsp remaps
    ["<leader>ld"] = {
      "<cmd>LspStop<CR>",
      "Start LSP",
    },
    ["<leader>lr"] = {
      "<cmd>LspRestart<CR>",
      "Restart LSP",
    },
    ["<leader>le"] = {
      "<cmd>LspStart<CR>",
      "Stop LSP",
    },
    -- ts tool maps
    ["<leader>toi"] = {
      "<cmd>TSToolsOrganizeImports<CR>",
      "Organize Imports",
    },
    ["<leader>tai"] = {
      "<cmd>TSToolsAddMissingImports<CR>",
      "Add Missing Imports",
    },

    ["<leader>fw"] = {
      function()
        utils.multiGrep()
      end,
      "MultiGrep",
    },
    -- telescope remaps
    ["<leader>fgc"] = {
      function()
        utils.searchGitConflicts()
      end,
      "Search for git conflicts",
    },
    ["<leader>fch"] = { "<cmd> Telescope command_history <CR>", "Find command history" },
    ["<leader>fp"] = { "<cmd> Telescope yank_history <CR>", "Find command history" },
    ["<leader>fss"] = { "<cmd> Telescope spell_suggest <CR>", "Find command history" },
    ["<leader>fr"] = { "<cmd> Telescope registers <CR>", "Find command history" },
    ["<leader>fs"] = { "<cmd> Telescope lsp_document_symbols <CR>", "Find command history" },
    ["<leader>fd"] = { "<cmd> Telescope diagnostics <CR>", "Find command history" },
    ["<leader>ft"] = { "<cmd> TodoTelescope <CR>" },
    ["<leader>fc"] = { "<cmd> Telescope commands <CR>", "Find command history" },
    ["<leader>flr"] = { "<cmd> Telescope lsp_references <CR>", "LSP References" },
    ["gt"] = { "<cmd> Telescope lsp_type_definitions <CR>", "Type Definations" },
    ["<leader>u"] = {
      "<cmd>Telescope undo<cr>",
      "Open undo history using Telescope",
    },
    ["<leader>fbc"] = { "<cmd>Telescope git_bcommits<CR>", desc = "Find buffer commits" },
    ["<C-p>"] = { "<cmd>Telescope find_files<CR>" },
    ["gd"] = { "<cmd>Telescope lsp_definitions<CR>", desc = "Lsp defination" },

    ["<leader>te"] = {
      "<cmd>execute 'normal! O// @ts-expect-error'<CR>j",
      "Add // @ts-expect-error above the current line",
    },
    ["<leader>tsn"] = { "ggO// @ts-nocheck<Esc>", "Add ts-nocheck at the top of the file" },

    ["<leader>ba"] = {
      "<cmd>%bd|e#<CR>",
      "Close all other buffers except the current one",
    },
    -- GrugFar operations
    ["<leader>gf"] = { "<cmd>GrugFar<CR>", "Open GrugFar buffer" },
    ["<leader>rw"] = {
      function()
        require("grug-far").open {
          prefills = {
            search = vim.fn.expand "<cword>",
          },
        }
      end,
      "Open GrugFar buffer with word under cursor",
    },

    -- for git diff
    ["<leader>gd"] = { "<cmd> DiffviewOpen <CR>", "Open git diff" },
    ["<leader>gdc"] = { "<cmd> DiffviewClose <CR>", "Close git diff" },
    ["<leader>gdo"] = { "<cmd> DiffviewOpen <CR>", "Toggle files git diff" },
    ["<leader>dd"] = {
      [["_dd"]],
      "Delete single line without overwriting reg",
    },
    ["J"] = {
      "mzJ`z",
      "Join lines and retain cursor position",
    },
    ["<C-d>"] = {
      "<C-d>zz",
      "Half-page down and center",
    },
    ["<C-u>"] = {
      "<C-u>zz",
      "Half-page up and center",
    },
    ["n"] = {
      "nzzzv",
      "Next search result and center",
    },
    ["N"] = {
      "Nzzzv",
      "Previous search result and center",
    },
    ["<leader>sr"] = {
      [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/cgI<Left><Left><Left>]],
      "Search and replace",
    },
    ["sa"] = { "G$Vgg", "Select all" },
    ["<leader>so"] = { ":source %<CR>", "Source the current file" },
    ["<leader>ya"] = { "<cmd>%y<CR>" },
    ["<leader>da"] = { "G$Vgg_d" },
    ["<leader>ef"] = { "va{<ESC>" },

    -- splits
    ["<leader>v"] = { "<cmd>vsplit<CR>" },
    ["<leader>s"] = { "<cmd>split<CR>" },

    -- cmd
    ["<leader>wq"] = { "<cmd>wqa!<CR>" },
    ["<leader>w"] = { "<cmd>wa<CR>" },
    ["<leader>q"] = { "<cmd>q!<CR>" },

    ["[d"] = { "<cmd>lua vim.diagnostic.goto_prev()<CR>" },
    ["]d"] = { "<cmd>lua vim.diagnostic.goto_next()<CR>" },

    ["el"] = { "$" },
    ["sl"] = { "_" },

    ["<leader>ts"] = { "<cmd>set spell!<CR>", desc = "Toggle spell check" },
    ["<leader>env"] = {
      function()
        utils.openOrCreateFiles { ".env", ".env.local" }
      end,
      "Open .env file",
    },

    ["<leader>gi"] = {
      function()
        utils.openOrCreateFiles { ".gitignore" }
      end,
      "Open .gitignore file",
    },

    ["<leader>cd"] = {
      function()
        utils.copyDiagnosticToClip()
      end,
      "Copy diagnostic to clipboard",
    },
    ["<leader>cln"] = {
      function()
        local line_number = vim.fn.line "."
        vim.fn.setreg("+", tostring(line_number))
        vim.notify("Copied line number: " .. line_number)
      end,
      "Copy current line number to clipboard",
    },
  },

  v = {
    -- NOTE: added this here because core ones were not working
    ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<CR>" },

    ["<leader>rw"] = {
      function()
        vim.cmd 'noau normal! "vy"' -- Yank the selection into a register
        local selection = vim.fn.getreg("v"):gsub("\n", " ")
        require("grug-far").open {
          prefills = {
            search = selection,
          },
        }
      end,
      "Open GrugFar buffer with word under cursor",
    },

    ["<leader>gw"] = {
      function()
        vim.cmd 'noau normal! "vy"' -- Yank the selection into a register
        local selection = vim.fn.getreg("v"):gsub("\n", " ")
        require("telescope.builtin").live_grep {
          default_text = selection,
        }
      end,
      "Live grep visual selection",
    },

    ["<leader>o"] = {
      function()
        utils.openClosestLink()
      end,
      "Open closest URL under cursor",
    },

    ["<leader>d"] = {
      [["_d"]],
      "Delete without overwriting register",
    },
    ["<"] = { "<gv" },
    [">"] = { ">gv" },
    ["J"] = {
      ":m '>+1<CR>gv=gv",
      "Move selected lines down",
    },
    ["K"] = {
      ":m '<-2<CR>gv=gv",
      "Move selected lines up",
    },
  },

  x = {
    ["<leader>rr"] = {
      function()
        require("telescope").extensions.refactoring.refactors()
      end,
      "Open refactoring options with Telescope",
    },

    ["<leader>d"] = {
      [["_d"]],
      "Delete without overwriting register",
    },
    ["<leader>pp"] = {
      [["_dP"]],
      "Paste without overwriting register",
    },
  },

  i = {
    ["<S-Tab>"] = { "<C-w>" },
    ["<C-h>"] = { "<C-w>" },
  },
}

return M
