# TS LSP Hover Crash Fix (K mapping)

## Date
2026-07-04

## Symptoms
Pressing `K` on TypeScript files caused TS LSP crash (intermittent, GUI-specific).

## Root Cause

### 1. typescript-tools on_attach does NOT chain core LSP mappings
**File**: `lua/custom/configs/typescript-tools.lua`

The custom `M.on_attach` handles test files, inlay hints, and formatting but **never calls** `plugins.configs.lspconfig.on_attach`, which is responsible for loading buffer-local LSP keymaps via `utils.load_mappings("lspconfig", { buffer = bufnr })`.

Result: TypeScript buffers get **zero** buffer-local LSP mappings (no `gd`, `gi`, `gr`, buffer-local `K`, etc.).

### 2. K mapping is defined in M.general (global), not M.lspconfig
**File**: `lua/custom/mappings.lua:602-610`

`K` is defined in `M.general` section:
```lua
["K"] = {
  function()
    local winid = require("ufo").peekFoldedLinesUnderCursor()
    if not winid then
      vim.lsp.buf.hover()
    end
  end,
  "Peek Fold/Hover",
},
```

NvChad's `remove_disabled_keys` merge logic (`core/utils.lua:19-52`) removes keys from **all** default mapping sections if they exist in **any** custom mapping section. Since custom `M.general.n.K` exists, default `M.lspconfig.n.K` is removed.

### 3. tsgo is not involved
**Binary**: `/home/elhaam/.bun/bin/tsgo`

`tsgo` (`@typescript/native-preview`, TypeScript 7.0.0-dev) is a **Go-native TypeScript compiler**, not an LSP server. It has zero LSP capabilities. It is never referenced anywhere in the Neovim config. It was a red herring.

### 4. NvChad load sequence
`init.lua:9` calls `require("core.utils").load_mappings()` (no section arg), which loads **all** non-plugin mapping sections at startup — including `M.general` (global K mapping).

`M.lspconfig` has `plugin = true`, so it's only loaded buffer-local via `load_mappings("lspconfig", ...)` inside the core lspconfig on_attach. Since typescript-tools never calls this, TS buffers miss all buffer-local LSP maps.

## Fix Applied

**File**: `lua/custom/configs/typescript-tools.lua`

Added chaining of core NvChad LSP on_attach after formatting disable:

```lua
local core_on_attach = require("plugins.configs.lspconfig").on_attach
if core_on_attach then
  core_on_attach(client, bufnr)
end
```

This restores all buffer-local LSP mappings (`gd`, `gr`, `gi`, `K` in lspconfig section, etc.) for TypeScript buffers.

Since `M.lspconfig.n.K` was already removed by NvChad's merge logic (due to `M.general.n.K` existing), the buffer-local `K` is not loaded — so the global `K` mapping (ufo peek → hover fallback) remains active without conflict.

## Files Changed
- `lua/custom/configs/typescript-tools.lua` — Added core on_attach chaining

## Verification
- `stylua --check` — clean
- `nvim --headless +q` — no errors
- `nvim --headless +'lua require("custom.configs.typescript-tools")' +q` — module loads
