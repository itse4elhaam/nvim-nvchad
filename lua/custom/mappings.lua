local M = {}


M.gopher = {
  plugin = true,
  n = {
    ["<leader>gsj"] = {
      "<cmd> GoTagAdd json <CR>",
      "Add json struct tags"
    },
    ["<leader>gsy"] = {
      "<cmd> GoTagAdd yaml <CR>",
      "Add yaml struct tags"
    }
  }
}

M.general = {
  n = {
    ["yf"] = { "vaijy" },
    ["sa"] = { "G$Vgg" },
    ["ya"] = { ":%y<CR>" },
    ["da"] = { "G$vgg_d" },
    ["<C-K>"] = {"_dd"},
    ["dla"] = {"%_dd"},

    -- switch b/w buffers
    ["<S-h>"] = { ":bprevious<CR>" },
    ["<S-l>"] = { ":bnext<CR>" },

    -- splits
    ["<leader>v"] = { ":vsplit<CR>" },
    ["<leader>s"] = { ":split<CR>" },

    -- panes
    -- ["<leader>h"] = { ":wincmd h<CR>" },
    -- ["<leader>j"] = { ":wincmd j<CR>" },
    -- ["<leader>k"] = { ":wincmd k<CR>" },
    -- ["<leader>l"] = { ":wincmd l<CR>" },

    -- cmd
    ["<leader>wq"] = { ":wq!<CR>" },
    ["<leader>w"] = { ":w!<CR>" },
    ["<leader>q"] = { ":q!<CR>" },

    ["[d"] = { ":lua vim.diagnostic.goto_prev()<CR>" },
    ["]d"] = { ":lua vim.diagnostic.goto_next()<CR>" },

    ["<C-p>"] = { ":Telescope find_files<CR>" },

    ["<C-w>"] = { ":bd<CR>" },

    ["el"] = { "$" },
    ["sl"] = { "_" },

    ["gh"] = { ":lua vim.lsp.buf.hover()<CR>" },
    ["gd"] = { ":lua vim.lsp.buf.definition()<CR>" },

    ["<leader>ca"] = { ":lua vim.lsp.buf.code_action()<CR>" },
  },

  v = {
    ["<"] = { "<gv" },
    [">"] = { ">gv" },
    ["<leader>c"] = { ":lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>" },
  },

  i = {
    ["<C-w>"] = { "<C-w>" },
  },
}


return M
