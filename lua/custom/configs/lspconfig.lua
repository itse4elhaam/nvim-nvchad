local M = {}

local on_attach = require("plugins.configs.lspconfig").on_attach
local on_init = require("plugins.configs.lspconfig").on_init
local preDefinedCapabilities = require("plugins.configs.lspconfig").capabilities
local capabilities = require("blink.cmp").get_lsp_capabilities(preDefinedCapabilities)

capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}

-- Disable formatting for tailwindcss and cssls
local function disable_formatting(client)
  if client.name == "tailwindcss" or client.name == "cssls" then
    client.server_capabilities.documentFormattingProvider = false
  end
end

local function on_attach_custom(client, bufnr)
  disable_formatting(client)
  on_attach(client, bufnr)
end

local servers = {
  "bashls",
  "clangd",
  "cssls",
  "emmet_language_server",
  "gopls",
  "jsonls",
  "marksman",
  "pyright",
  "sqls",
  "svelte",
  "tailwindcss",
  "asm_lsp",
  "lua_ls",
}

local util = require "lspconfig/util"

local server_configs = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
            [vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types"] = true,
            [vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy"] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  },
  gopls = {
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
  },
  marksman = {
    filetypes = { "markdown" },
  },
  bashls = {
    filetypes = { "sh", "bash", ".zshrc", ".bashrc" },
  },
  pyright = {
    filetypes = { "python" },
  },
  emmet_language_server = {
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
  },
  clangd = {
    on_attach = function(client, bufnr)
      client.server_capabilities_signatureHelpProvider = false
      on_attach_custom(client, bufnr)
    end,
  },
  jsonls = {
    on_new_config = function(new_config)
      new_config.settings.json.schemas = new_config.settings.json.schemas or {}
      vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
    end,
    settings = {
      json = {
        format = {
          enable = true,
        },
        validate = {
          enable = true,
        },
      },
    },
  },
  sqls = {
    cmd = { "sqls" },
    filetypes = { "sql", "mysql", "plsql" },
    settings = {
      sqls = {},
    },
  },
  svelte = {
    cmd = { "svelteserver", "--stdio" },
    filetypes = { "svelte" },
    root_dir = util.root_pattern("package.json", ".git"),
  },
  cssls = {
    filetypes = { "css", "html", "less", "sass", "scss", "pug" },
  },
  tailwindcss = {
    filetypes = { "css", "html", "javascriptreact", "less", "sass", "scss", "pug", "svelte" },
  },
  asm_lsp = {
    filetypes = { "asm", "s", "S" },
  },
}

for _, server in ipairs(servers) do
  local config = {
    on_attach = on_attach_custom,
    on_init = on_init,
    capabilities = capabilities,
  }
  if server_configs[server] then
    config = vim.tbl_deep_extend("force", config, server_configs[server])
  end
  vim.lsp.config(server, config)
  vim.lsp.enable(server)
end

-- vim.notify("LSP servers configured using native API!", vim.log.levels.INFO)

return M
