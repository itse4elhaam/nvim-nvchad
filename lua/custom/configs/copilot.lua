-- Copilot LSP configuration that manually starts the language server
local M = {}

-- Function to setup copilot LSP manually
function M.setup()
  -- Check if copilot-language-server is available
  if vim.fn.executable("copilot-language-server") == 0 then
    vim.notify("copilot-language-server not found in PATH. Please install it with: npm install -g @github/copilot-language-server", vim.log.levels.ERROR)
    return
  end

  -- Get capabilities and on_attach from NvChad if available
  local on_attach, capabilities
  local nvchad_ok, nvchad_lsp = pcall(require, "plugins.configs.lspconfig")
  if nvchad_ok then
    on_attach = nvchad_lsp.on_attach
    capabilities = nvchad_lsp.capabilities
    
    -- Enhance capabilities with blink.cmp if available
    local blink_ok, blink = pcall(require, "blink.cmp")
    if blink_ok then
      capabilities = blink.get_lsp_capabilities(capabilities)
    end
  else
    -- Fallback if NvChad isn't loaded
    on_attach = function(client, bufnr)
      -- Basic on_attach functionality
      if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = bufnr,
          group = "lsp_document_highlight",
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd("CursorMoved", {
          buffer = bufnr,
          group = "lsp_document_highlight",
          callback = vim.lsp.buf.clear_references,
        })
      end
    end
    
    capabilities = vim.lsp.protocol.make_client_capabilities()
  end

  -- Create copilot LSP client configuration
  local copilot_config = {
    name = "copilot",
    cmd = { "copilot-language-server", "--stdio" },
    filetypes = {
      "gitcommit",
      "gitrebase", 
      "yaml",
      "markdown",
      "help",
      "javascript",
      "typescript",
      "javascriptreact",
      "typescriptreact",
      "python",
      "go",
      "rust",
      "lua",
      "c",
      "cpp",
      "java",
      "html",
      "css",
      "scss",
      "sass",
      "json",
      "jsonc",
      "sql",
      "bash",
      "sh",
      "zsh",
      "fish",
    },
    root_dir = function()
      return vim.fn.getcwd()
    end,
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      -- Copilot configuration settings
      advanced = {
        listCount = 10,
        inlineSuggestCount = 3,
      },
    },
    init_options = {
      editorInfo = {
        name = "neovim",
        version = vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
      },
      editorPluginInfo = {
        name = "nvchad-sidekick-integration",
        version = "1.0.0",
      },
    },
  }

  -- Use lspconfig if available, otherwise use vim.lsp.start_client
  local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
  if lspconfig_ok then
    -- Try to use lspconfig's copilot config if it exists
    if lspconfig.copilot then
      lspconfig.copilot.setup(copilot_config)
      vim.notify("Copilot LSP configured via lspconfig", vim.log.levels.INFO)
    else
      -- Manual configuration using lspconfig's utilities
      local util = require("lspconfig.util")
      local configs = require("lspconfig.configs")
      
      if not configs.copilot then
        configs.copilot = {
          default_config = {
            cmd = copilot_config.cmd,
            filetypes = copilot_config.filetypes,
            root_dir = util.find_git_ancestor,
            single_file_support = true,
            settings = copilot_config.settings,
            init_options = copilot_config.init_options,
          },
        }
      end
      
      lspconfig.copilot.setup({
        on_attach = copilot_config.on_attach,
        capabilities = copilot_config.capabilities,
      })
      vim.notify("Copilot LSP configured manually via lspconfig", vim.log.levels.INFO)
    end
  else
    -- Fallback to vim.lsp.start_client if lspconfig is not available
    vim.api.nvim_create_autocmd("FileType", {
      pattern = copilot_config.filetypes,
      callback = function()
        if not vim.lsp.get_clients({ name = "copilot" })[1] then
          vim.lsp.start({
            name = copilot_config.name,
            cmd = copilot_config.cmd,
            root_dir = copilot_config.root_dir(),
            on_attach = copilot_config.on_attach,
            capabilities = copilot_config.capabilities,
            settings = copilot_config.settings,
            init_options = copilot_config.init_options,
          })
        end
      end,
    })
    vim.notify("Copilot LSP configured via vim.lsp.start", vim.log.levels.INFO)
  end
end

-- Auto-setup if called as a module
M.setup()

return M