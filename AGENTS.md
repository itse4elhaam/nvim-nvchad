# Agent Guidelines for Neovim Config

## Commands
- **Lint**: `stylua .` - Format all Lua files
- **Test**: No automated tests configured

## Code Style
- **Formatting**: 120 char width, 2-space indents, Unix line endings, double quotes preferred
- **Naming**: Use `snake_case` for variables/functions/modules (e.g., `update_wakatime`, `M.multiGrep`)
- **Imports**: `require` at top, grouped by: standard → third-party → local
- **Functions**: Prefix module exports with `M.` (e.g., `M.addDirective`), use `local function` for private helpers
- **Error Handling**: Use `pcall`/`xpcall` for fallible operations, return `nil, error_msg` on failure
- **Type Annotations**: Use LuaLS annotations (`---@type`, `---@param`, `---@return`) for public APIs
- **Tables**: Use named tables for plugin configs, return tables from config functions

## Plugin Architecture
- **Structure**: `lua/custom/plugins.lua` contains categorized plugin groups (AI, editing, LSP, UI, etc.)
- **Config Files**: Each plugin config in `lua/custom/configs/<plugin>.lua` with `opts`, `config`, or `dependencies`
- **Lazy Loading**: Use `lazy`, `event`, `cmd`, `keys`, `ft` for deferred loading
- **Dependencies**: Declare explicitly with `dependencies` array, ensure load order

## Key Patterns
- **Autocommands**: Use `api.nvim_create_augroup` with `clear = true`, wrap in `augroup()` helper
- **Mappings**: Load via `load_mappings` helper from `core.utils`, define in `custom/mappings.lua`
- **LSP Config**: Use `vim.lsp.config()` + `vim.lsp.enable()` for LSP setup, extend capabilities with blink.cmp
