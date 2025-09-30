local on_attach = require("plugins.configs.lspconfig").on_attach
local preDefinedCapabilities = require("plugins.configs.lspconfig").capabilities
local capabilities = require("blink.cmp").get_lsp_capabilities(preDefinedCapabilities)

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

local lspconfig = require "lspconfig"
local util = require "lspconfig/util"

-- Try to load schemastore, fallback if not available
local schemastore = {}
local ok, store = pcall(require, "schemastore")
if ok then
  schemastore = store
end

-- Disable formatting for tailwindcss and cssls
local function disable_formatting(client)
  if client.name == "tailwindcss" or client.name == "cssls" then
    client.server_capabilities.documentFormattingProvider = false
  end
end

lspconfig.gopls.setup {
  on_attach = function(client, bufnr)
    disable_formatting(client) -- Disable formatting for specific servers
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      completeUnimported = true,
      usePlaceholders = true,
      analyses = {
        unusedparams = true,
      },
    },
  },
}

lspconfig.marksman.setup {
  on_attach = function(client, bufnr)
    disable_formatting(client) -- Disable formatting for specific servers
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  filetypes = { "markdown" },
}

lspconfig.bashls.setup {
  on_attach = function(client, bufnr)
    disable_formatting(client) -- Disable formatting for specific servers
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  filetypes = { "sh", "bash", ".zshrc", ".bashrc" },
}

lspconfig.pyright.setup {
  on_attach = function(client, bufnr)
    disable_formatting(client) -- Disable formatting for specific servers
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  filetypes = { "python" },
}

lspconfig.emmet_language_server.setup {
  filetypes = { "css", "html", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact", "svelte" },
  init_options = {
    includeLanguages = {},
    excludeLanguages = {},
    extensionsPath = {},
    preferences = {},
    showAbbreviationSuggestions = true,
    showExpandedAbbreviation = "always",
    showSuggestionsAsSnippets = false,
    syntaxProfiles = {},
    variables = {},
  },
}

lspconfig.clangd.setup {
  on_attach = function(client, bufnr)
    client.server_capabilities_signatureHelpProvider = false
    disable_formatting(client) -- Disable formatting for specific servers
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

lspconfig.jsonls.setup {
  on_attach = function(client, bufnr)
    disable_formatting(client) -- Disable formatting for specific servers
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  on_new_config = function(new_config)
    new_config.settings.json.schemas = new_config.settings.json.schemas or {}
    if schemastore.json then
      vim.list_extend(new_config.settings.json.schemas, schemastore.json.schemas())
    end
  end,
  settings = {
    json = {
      format = {
        enable = true, -- Enable JSON formatting
      },
      validate = {
        enable = true, -- Enable JSON validation
      },
    },
  },
}

lspconfig.sqls.setup {
  on_attach = function(client, bufnr)
    disable_formatting(client)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  cmd = { "sqls" },
  filetypes = { "sql", "mysql", "plsql" },
  settings = {
    sqls = {},
  },
}

lspconfig.svelte.setup {
  cmd = { "svelteserver", "--stdio" },
  filetypes = { "svelte" },
  root_dir = util.root_pattern("package.json", ".git"),
}

-- lspconfig.denols.setup {
--   on_attach = on_attach,
--   root_dir = util.root_pattern("deno.json", "deno.jsonc"),
-- }

lspconfig.cssls.setup {
  filetypes = { "css", "html", "less", "sass", "scss", "pug" },
  on_attach = function(client, bufnr)
    disable_formatting(client) -- Disable formatting for specific servers
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

lspconfig.tailwindcss.setup {
  -- filetypes = { "css", "html", "javascriptreact", "less", "sass", "scss", "pug", "typescriptreact", "svelte" },
  filetypes = { "css", "html", "javascriptreact", "less", "sass", "scss", "pug", "svelte" },
  on_attach = function(client, bufnr)
    disable_formatting(client)
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
}

lspconfig.asm_lsp.setup {
  on_attach = function(client, bufnr)
    disable_formatting(client) -- Disable formatting if desired
    on_attach(client, bufnr)
  end,
  capabilities = capabilities,
  filetypes = { "asm", "s", "S" }, -- Common assembly file extensions
}

-- Load copilot LSP configuration in a deferred way
vim.defer_fn(function()
  local ok, copilot_config = pcall(require, "custom.configs.copilot")
  if not ok then
    vim.notify("Failed to load copilot configuration: " .. tostring(copilot_config), vim.log.levels.ERROR)
  end
end, 100) -- Delay by 100ms to ensure everything is loaded
