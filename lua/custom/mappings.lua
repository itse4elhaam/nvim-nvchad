local M = {}

function OpenEnvFile()
  local env_file = ".env"
  local env_local_file = ".env.local"

  -- Check if .env file exists
  if vim.fn.filereadable(env_file) == 1 then
    vim.cmd("edit " .. env_file)
  elseif vim.fn.filereadable(env_local_file) == 1 then
    vim.cmd("edit " .. env_local_file)
  else
    print ".env not found"
  end
end

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
    ["<leader>u"] = {
      "<cmd>Telescope undo<cr>",
      "Open undo history using Telescope",
    },

    -- Insert printf debugging statement
    ["<leader>rp"] = {
      function()
        require("refactoring").debug.printf { below = false }
      end,
      "Insert printf debug statement",
    },

    -- Cleanup debug statements
    ["<leader>rc"] = {
      function()
        require("refactoring").debug.cleanup {}
      end,
      "Clean up debug statements",
    },

    ["<leader>te"] = {
      "<cmd>execute 'normal! O// @ts-expect-error'<CR>j",
      "Add // @ts-expect-error above the current line",
    },

    ["<leader>ba"] = {
      "<cmd>%bd|e#<CR>",
      "Close all other buffers except the current one",
    },
    -- GrugFar operations
    ["<leader>gf"] = { "<cmd>GrugFar<CR>", "Open GrugFar buffer" },
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
      [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
      "Search and replace",
    },
    ["sa"] = { "G$Vgg" },
    ["<leader>ya"] = { "<cmd>%y<CR>" },
    ["<leader>da"] = { "G$Vgg_d" },
    ["<leader>yf"] = { "vi{joky" },
    ["<leader>ef"] = { "va{<ESC>" },

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

    ["<leader>ts"] = { "<cmd>set spell!<CR>", desc = "Toggle spell check" },
    ["<leader>env"] = { "<cmd>lua OpenEnvFile()<CR>", desc = "Open .env file" },
    ["<leader>fs"] = { "<cmd>Telescope aerial<CR>", desc = "Open .env file" },
  },

  v = {
    ["<leader>rv"] = {
      function()
        require("refactoring").debug.print_var()
      end,
      "Print variable for debugging",
    },
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
    ["<leader>rr"] = {
      function()
        require("telescope").extensions.refactoring.refactors()
      end,
      "Open refactoring options with Telescope",
    },

    ["<leader>rv"] = {
      function()
        require("refactoring").debug.print_var()
      end,
      "Print variable for debugging",
    },

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
