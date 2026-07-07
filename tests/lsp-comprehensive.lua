-- Comprehensive LSP regression test
-- Tests ALL protocol methods + buf wrappers + insert mode stress
-- Exits 0 if ALL pass, 1 if any fail
--
-- Run: nvim --headless -u ~/.config/nvim/init.lua
--        -c "cd <project>" -c "e <file.ts>"
--        -c "luafile tests/lsp-comprehensive.lua"
--
-- Every method is tested as: request → insert mode cycle → verify clients survive
-- This catches the WritingMode autocmd race condition where LSP float
-- windows with filetype=markdown trigger set_writing_mode(true) which
-- kills LSP clients on the main buffer.

local function say(m) io.stderr:write(m.."\n") io.stderr:flush() end
local bufnr = vim.api.nvim_get_current_buf()

vim.wait(5000)
local clients = vim.lsp.get_clients({ bufnr = bufnr })
if #clients == 0 then say("FAIL: no LSP clients"); os.exit(1) end
say(string.format("Clients: %d | File: %s", #clients, vim.api.nvim_buf_get_name(bufnr)))

local failed = 0
local total = 0
local function check(method, ok, detail)
  total = total + 1
  if ok then say(string.format("  OK  %s", method))
  else failed = failed + 1; say(string.format("  FAIL %s: %s", method, detail or "unknown")) end
end

local function insert_cycle()
  vim.api.nvim_win_set_cursor(0, {24, 10})
  vim.wait(30)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("a", true, false, true), "n", false)
  vim.wait(80)
  vim.api.nvim_feedkeys("xx", "n", false)
  vim.wait(200)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("\\<Esc>", true, false, true), "n", false)
  vim.wait(200)
  local c = vim.lsp.get_clients({ bufnr = bufnr })
  if #c == 0 then say(string.format("  !! CLIENTS DIED after %s", method)); os.exit(1) end
end

local function set_cursor()
  vim.api.nvim_win_set_cursor(0, { 13, 4 })
  vim.wait(30)
end

local function sync_req(method, params)
  local ok, result = pcall(vim.lsp.buf_request_sync, 0, method, params, 3000)
  return ok, result
end

say("\n-- textDocument/* protocol methods (via buf_request_sync) --")

set_cursor()
local ok, r = sync_req("textDocument/hover", vim.lsp.util.make_position_params())
check("textDocument/hover", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
local cp = vim.lsp.util.make_position_params(); cp.context = { triggerKind = 1 }
ok, r = sync_req("textDocument/completion", cp)
check("textDocument/completion", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/definition", vim.lsp.util.make_position_params())
check("textDocument/definition", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/declaration", vim.lsp.util.make_position_params())
check("textDocument/declaration", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/typeDefinition", vim.lsp.util.make_position_params())
check("textDocument/typeDefinition", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/implementation", vim.lsp.util.make_position_params())
check("textDocument/implementation", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
local rp = vim.lsp.util.make_position_params(); rp.context = { includeDeclaration = true }
ok, r = sync_req("textDocument/references", rp)
check("textDocument/references", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/signatureHelp", vim.lsp.util.make_position_params())
check("textDocument/signatureHelp", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/codeAction", {
  textDocument = { uri = vim.uri_from_bufnr(0) },
  range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 0 } },
  context = { diagnostics = {}, triggerKind = 2 },
})
check("textDocument/codeAction", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/documentHighlight", vim.lsp.util.make_position_params())
check("textDocument/documentHighlight", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/documentSymbol", { textDocument = { uri = vim.uri_from_bufnr(0) } })
check("textDocument/documentSymbol", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/foldingRange", { textDocument = { uri = vim.uri_from_bufnr(0) } })
check("textDocument/foldingRange", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/selectionRange", {
  textDocument = { uri = vim.uri_from_bufnr(0) },
  positions = { vim.lsp.util.make_position_params() },
})
check("textDocument/selectionRange", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/semanticTokens/full", { textDocument = { uri = vim.uri_from_bufnr(0) } })
check("textDocument/semanticTokens/full", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/prepareCallHierarchy", vim.lsp.util.make_position_params())
check("textDocument/prepareCallHierarchy", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/prepareTypeHierarchy", vim.lsp.util.make_position_params())
check("textDocument/prepareTypeHierarchy", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/documentLink", { textDocument = { uri = vim.uri_from_bufnr(0) } })
check("textDocument/documentLink", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/codeLens", { textDocument = { uri = vim.uri_from_bufnr(0) } })
check("textDocument/codeLens", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/inlayHint", {
  textDocument = { uri = vim.uri_from_bufnr(0) },
  range = { start = { line = 0, character = 0 }, ["end"] = { line = 100, character = 0 } },
})
check("textDocument/inlayHint", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/moniker", vim.lsp.util.make_position_params())
check("textDocument/moniker", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/linkedEditingRange", vim.lsp.util.make_position_params())
check("textDocument/linkedEditingRange", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/documentColor", { textDocument = { uri = vim.uri_from_bufnr(0) } })
check("textDocument/documentColor", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/formatting", {
  textDocument = { uri = vim.uri_from_bufnr(0) }, options = { tabSize = 2, insertSpaces = true },
})
check("textDocument/formatting", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/rangeFormatting", {
  textDocument = { uri = vim.uri_from_bufnr(0) },
  range = { start = { line = 0, character = 0 }, ["end"] = { line = 10, character = 0 } },
  options = { tabSize = 2, insertSpaces = true },
})
check("textDocument/rangeFormatting", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
ok, r = sync_req("textDocument/onTypeFormatting", {
  textDocument = { uri = vim.uri_from_bufnr(0) },
  position = vim.lsp.util.make_position_params(), ch = "}",
  options = { tabSize = 2, insertSpaces = true },
})
check("textDocument/onTypeFormatting", ok, r and "responded" or "nil"); insert_cycle()

set_cursor()
local ok_prep, prep_result = sync_req("textDocument/prepareRename", vim.lsp.util.make_position_params())
check("textDocument/prepareRename", ok_prep, prep_result and "responded" or "nil")
insert_cycle()
if ok_prep and prep_result then
  ok, r = sync_req("textDocument/rename", {
    textDocument = { uri = vim.uri_from_bufnr(0) },
    position = vim.lsp.util.make_position_params(), newName = "testRename",
  })
  check("textDocument/rename", ok, r and "responded" or "nil")
  insert_cycle()
else
  check("textDocument/rename (skipped)", true, "prepare returned nil")
end

say("\n-- vim.lsp.buf.* wrapper functions --")
for _, fn in ipairs({ "hover", "declaration", "definition", "type_definition",
                       "implementation", "signature_help", "references",
                       "document_highlight" }) do
  set_cursor()
  pcall(vim.lsp.buf[fn])
  if fn == "document_highlight" then
    insert_cycle(); check("buf." .. fn, true, "")
    pcall(vim.lsp.buf.clear_references); check("buf.clear_references", true, "")
  else
    insert_cycle(); check("buf." .. fn, true, "")
  end
end

say("\n-- Repeated stress test (20x hover + insert) --")
for i = 1, 20 do
  set_cursor()
  pcall(vim.lsp.buf.hover)
  vim.wait(100)
  insert_cycle()
  if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
    say(string.format("FAIL at stress cycle %d", i)); os.exit(1)
  end
end
check("20x hover + insert stress", true, "")

say(string.format("\nTotal: %d | Passed: %d | Failed: %d", total, total - failed, failed))
os.exit(failed > 0 and 1 or 0)
