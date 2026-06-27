-- Projects with split tsconfigs (main + test) exclude test files from the main
-- config.  The LSP then uses the main config, producing spurious diagnostics
-- for Jest globals in test files.  This detaches those clients from test-file
-- buffers and starts a dedicated server using the test tsconfig instead.

local M = {}

local function is_test_file(path)
  return path:match "__tests__" or path:match "%.test%.[jt]sx?$" or path:match "%.spec%.[jt]sx?$"
end

local function start_test_lsp(bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)

  local existing = vim.lsp.get_clients { bufnr = bufnr, name = "ts_ls_tests" }
  if #existing > 0 then
    return
  end

  local root_dir = vim.fs.dirname(vim.fs.find({
    "tsconfig.check-tests.json",
    "tsconfig.json",
    "package.json",
    ".git",
  }, { upward = true, path = path })[1])

  if not root_dir then
    return
  end

  vim.lsp.start({
    name = "ts_ls_tests",
    cmd = { "typescript-language-server", "--stdio" },
    root_dir = root_dir,
    init_options = {
      tsserver = {
        configFile = root_dir .. "/tsconfig.check-tests.json",
      },
    },
  }, { bufnr = bufnr })
end

M.on_attach = function(client, bufnr)
  local path = vim.api.nvim_buf_get_name(bufnr)

  -- Test files need their own LSP server using the test tsconfig (if one exists).
  if is_test_file(path) then
    vim.schedule(function()
      vim.lsp.buf_detach_client(bufnr, client.id)
      start_test_lsp(bufnr)
    end)
    return
  end

  -- Enable inlay hints if supported and feature flag is enabled
  if vim.g.enable_inlay_hints and client.server_capabilities.inlayHintProvider then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  -- Disable formatting to use a dedicated formatter (like conform.nvim or null-ls)
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false

  -- Disable semantic tokens for large files (prevents lag)
  -- TODO: check if you need this or not
  -- if vim.api.nvim_buf_line_count(bufnr) > 3500 then
  --   client.server_capabilities.semanticTokensProvider = nil
  -- end
end

M.settings = {
  publish_diagnostic_on = "insert_leave",
  separate_diagnostic_server = true,
  tsserver_disable_suggestions = true,
  tsserver_log_verbosity = "off",
  tsserver_file_preferences = {
    includeInlayParameterNameHints = "all",
    includeCompletionsForModuleExports = true,
    includeCompletionsWithInsertText = true,
  },
  tsserver_format_options = {}, -- Explicitly empty to disable formatting
  expose_as_code_action = {
    "fix_all",
    "add_missing_imports",
    "remove_unused",
    "remove_unused_imports",
    "organize_imports",
  },
  tsserver_max_memory = 8192, -- MB
  tsserver_fsa_use_browser_implementation = false,
}

return M
