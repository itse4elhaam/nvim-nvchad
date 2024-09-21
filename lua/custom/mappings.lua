local M = {}

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
    ["<leader>ba"] = {
      "<cmd>%bd|e#<CR>",
      "Close all other buffers except the current one",
    },
    -- GrugFar operations
    ["<leader>gf"] = { "<cmd>GrugFar<CR>", "Open GrugFar buffer" },
    -- for git diff
    ["<leader>gd"] = { "<cmd> DiffviewOpen <CR>", "Open git diff" },
    ["<leader>gdc"] = { "<cmd> DiffviewClose <CR>", "Close git diff" },
    ["<leader>gdt"] = { "<cmd> DiffviewToggleFiles<CR>", "Toggle files git diff" },
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
      [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
      "Search and replace",
    },
    ["sa"] = { "G$Vgg" },
    ["<leader>ya"] = { "<cmd>%y<CR>" },
    ["<leader>da"] = { "G$Vgg_d" },
    ["<leader>yf"] = { "va{oky" },
    ["<leader>ef"] = { "va{<ESC>" },

    -- switch b/w buffers
    ["<S-h>"] = { "<cmd>bprevious<CR>" },
    ["<S-l>"] = { "<cmd>bnext<CR>" },

    -- splits
    ["<leader>v"] = { "<cmd>vsplit<CR>" },
    ["<leader>s"] = { "<cmd>split<CR>" },

    -- cmd
    ["<leader>wq"] = { "<cmd>wq!<CR>" },
    ["<leader>w"] = { "<cmd>w!<CR>" },
    ["<leader>q"] = { "<cmd>q!<CR>" },

    ["[d"] = { "<cmd>lua vim.diagnostic.goto_prev()<CR>" },
    ["]d"] = { "<cmd>lua vim.diagnostic.goto_next()<CR>" },

    ["<C-p>"] = { "<cmd>Telescope find_files<CR>" },

    ["el"] = { "$" },
    ["sl"] = { "_" },

    ["gh"] = { "<cmd>lua vim.lsp.buf.hover()<CR>" },
    ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<CR>" },

    ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<CR>" },
    ["<leader>xa"] = {
      "<cmd>bufdo bd<CR>",
      "Close all buffers",
    },
  },

  v = {
    ["<leader>dd"] = {
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
    ["<leader>dd"] = {
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
  },
}

return M
