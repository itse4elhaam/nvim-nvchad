local M = {
  filetype = {
    javascript = {
      require("formatter.filetypes.javascript").prettier
    },
    typescript= {
      require("formatter.filetypes.typescript").prettier
    },
    ["*"] = {

      require("formatter.filetypes.typescript").remove_trailing_whitespace
    }
  }
}

vim.api.nvim_create_augroup({"BugWritePost"},{
  command = "FormatWriteLock"
})

return M
