local opt = vim.opt

opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99

opt.relativenumber = true

-- look into this later
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     -- Delay the execution to ensure all startup processes are complete
--     local fn = require("custom.utils")
--     vim.defer_fn(fn.open_nvim_tree_if_no_buffers, 100)
--   end
-- })
