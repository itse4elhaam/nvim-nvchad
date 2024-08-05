local opt = vim.opt

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99

opt.relativenumber = true
vim.g.lazyvim_prettier_needs_config = false
