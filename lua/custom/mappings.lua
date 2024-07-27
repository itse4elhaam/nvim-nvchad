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
    -- NAVIGATION
    -- switch b/w buffers
    ["yf"] = { "vaijy" },

    ["<leader>1"] = { ":foldlevel1<CR>" },
    ["<leader>2"] = { ":foldlevel2<CR>" },
    ["<leader>3"] = { ":foldlevel3<CR>" },
    ["<leader>4"] = { ":foldlevel4<CR>" },
    ["<leader>0"] = { ":unfoldall<CR>" },

    ["sa"] = { "G$Vgg" },

    ["<S-h>"] = { ":bprevious<CR>" },
    ["<S-l>"] = { ":bnext<CR>" },

    -- splits
    ["<leader>v"] = { ":vsplit<CR>" },
    ["<leader>s"] = { ":split<CR>" },

    -- panes
    ["<leader>h"] = { ":wincmd h<CR>" },
    ["<leader>j"] = { ":wincmd j<CR>" },
    ["<leader>k"] = { ":wincmd k<CR>" },
    ["<leader>l"] = { ":wincmd l<CR>" },

    -- NICE TO HAVE
    ["<leader>wq"] = { ":wq!<CR>" },
    ["<leader>w"] = { ":w!<CR>" },
    ["<leader>q"] = { ":q!<CR>" },

    ["[d"] = { ":lua vim.diagnostic.goto_prev()<CR>" },
    ["]d"] = { ":lua vim.diagnostic.goto_next()<CR>" },
    ["<leader>ca"] = { ":lua vim.lsp.buf.code_action()<CR>" },

    ["<C-p>"] = { ":Telescope find_files<CR>" },
    ["gh"] = { ":lua vim.lsp.buf.hover()<CR>" },

    ["<C-w>"] = { ":bd<CR>" },

    ["el"] = { "$" },
    ["sl"] = { "_" },

    ["Y"] = { "y$" },

    ["ya"] = { ":%y<CR>" },
    ["da"] = { "G$vgg_d" },
    ["dp"] = { "<C-d>zz" },
    ["up"] = { "<C-u>zz" },

    ["gd"] = { ":lua vim.lsp.buf.definition()<CR>" },
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
