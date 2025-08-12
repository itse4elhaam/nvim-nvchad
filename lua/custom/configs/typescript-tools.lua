return {
  on_attach = function(client, bufnr)
    -- Disable formatting to use a dedicated formatter (like conform.nvim or null-ls)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false

    -- Disable semantic tokens for large files (prevents lag)
    -- TODO: check if you need this or not
    -- if vim.api.nvim_buf_line_count(bufnr) > 3500 then
    --   client.server_capabilities.semanticTokensProvider = nil
    -- end
  end,
  settings = {
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
  },
}
