---@class conform.setup.Config
local M = {
  format_on_save = {
    timeout_ms = 500,
    condition = function(buf)
      local filetype = vim.bo[buf].filetype
      local disabled_filetypes = { "sql", "tsx" }

      local is_disabled_filetype = vim.tbl_contains(disabled_filetypes, filetype)
      local line_count = vim.api.nvim_buf_line_count(buf)
      local block_large_file = vim.g.customBigFileOpt and line_count > 3500

      return not (is_disabled_filetype or block_large_file or vim.g.disableFormat)
    end,
  },
  lsp_format = "fallback",
  log_level = vim.log.levels.ERROR,
  notify_on_error = true,
  formatters_by_ft = {
    go = {
      "gofumpt",
      "goimports_reviser",
      "golines",
    },
    python = { "black" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    lua = { "stylua" },
    sql = { "sqlfmt" },
    javascript = { "biome", "prettier", stop_after_first = true },
    typescript = { "biome", "prettier", stop_after_first = true },
    typescriptreact = { "biome", "prettier", stop_after_first = true },
    javascriptreact = { "biome", "prettier", stop_after_first = true },
    json = { "biome", "prettier", stop_after_first = true },
    jsonc = { "biome", stop_after_first = true },
    yaml = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    scss = { "prettier" },
    less = { "prettier" },
    markdown = { "prettier" },
    graphql = { "prettier" },
  },
  formatters = {
    biome = {
      require_cwd = true,
      condition = function()
        return vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true })[1] ~= nil
      end,
    },
    prettier = {},
    gofumpt = {
      temp_dir = "/tmp",
    },
    goimports_reviser = {
      temp_dir = "/tmp",
    },
    golines = {
      temp_dir = "/tmp",
    },
    black = {
      prepend_args = { "--fast" },
    },
    clang_format = {
      style = "file",
    },
    stylua = {
      config = vim.fn.stdpath("config") .. "/stylua.toml",
    },
    sqlfmt = {},
  },
}

return M
