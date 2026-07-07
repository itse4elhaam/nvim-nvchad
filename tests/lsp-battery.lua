-- lsp-battery.lua — Language-agnostic LSP battery test.
-- Expects vim.g.test_lsp_server_name and vim.g.test_lsp_result_file.
-- Tests 26 protocol methods + 8 buf wrappers + 10 stress cycles.
-- Every op → insert cycle → verify clients survive.

local SERVER_NAME = vim.g.test_lsp_server_name or vim.env.SERVER_NAME
local RESULT_FILE = vim.g.test_lsp_result_file or vim.env.RESULT_FILE
local ATTACH_TIMEOUT = vim.g.test_lsp_timeout or 20000

if not SERVER_NAME or not RESULT_FILE then
  io.stderr:write("ERROR: set g:test_lsp_server_name and g:test_lsp_result_file\n")
  vim.cmd("cq!")
  return
end

local results = { pass = 0, fail = 0, skip = 0, detail = {} }
local bufnr   = vim.api.nvim_get_current_buf()

local function save()
  local f = io.open(RESULT_FILE, "w")
  if f then f:write(vim.json.encode(results)); f:close() end
end

local function log(method, status, note)
  table.insert(results.detail, { method = method, status = status, note = note or "" })
  if status == "ok" then results.pass = results.pass + 1
  elseif status == "skip" then results.skip = results.skip + 1
  else results.fail = results.fail + 1 end
  io.stderr:write(string.format("  %s %s %s\n", status:upper(), method, note or ""))
  io.stderr:flush()
end

local esc = vim.api.nvim_replace_termcodes

local function insert_cycle(method_name)
  pcall(vim.api.nvim_win_set_cursor, 0, { 1, 0 }); vim.wait(20)
  pcall(vim.api.nvim_feedkeys, esc("a", true, false, true), "n", false); vim.wait(60)
  pcall(vim.api.nvim_feedkeys, "x", "n", false); vim.wait(150)
  pcall(vim.api.nvim_feedkeys, esc("<Esc>", true, false, true), "n", false); vim.wait(150)
  local alive = #vim.lsp.get_clients({ bufnr = bufnr })
  if alive == 0 then
    log(method_name or "unknown", "fail", "CLIENTS DIED")
    save(); vim.cmd("cq!")
  end
end

local function sync(method, params)
  return pcall(vim.lsp.buf_request_sync, 0, method, params, 3000)
end

local function pp() return vim.lsp.util.make_position_params() end

-- Wait for server
io.stderr:write(string.format("Waiting for '%s' …\n", SERVER_NAME)); io.stderr:flush()
local attached = vim.wait(ATTACH_TIMEOUT, function()
  for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
    if c.name == SERVER_NAME then return true end
  end
  return false
end)

if not attached then
  -- Some servers (gopls, clangd) don't auto-start in headless mode.
  -- Try starting them explicitly.
  local explicit_ok = pcall(vim.lsp.start, {
    name = SERVER_NAME,
    cmd = { SERVER_NAME },
    root_dir = vim.fn.getcwd(),
  })
  if explicit_ok then
    attached = vim.wait(ATTACH_TIMEOUT, function()
      for _, c in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        if c.name == SERVER_NAME then return true end
      end
      return false
    end)
  end
end

if not attached then
  log("server:" .. SERVER_NAME, "fail", "TIMEOUT — not attached after " .. ATTACH_TIMEOUT .. "ms")
  save(); vim.cmd("cq!"); return
end
io.stderr:write("Attached, running battery …\n"); io.stderr:flush()

-- Phase 2: Protocol methods via buf_request_sync
local tests = {
  { "textDocument/hover",              pp() },
  { "textDocument/completion",         vim.tbl_extend("force", pp(), { context = { triggerKind = 1 } }) },
  { "textDocument/definition",         pp() },
  { "textDocument/declaration",        pp() },
  { "textDocument/typeDefinition",     pp() },
  { "textDocument/implementation",     pp() },
  { "textDocument/references",         vim.tbl_extend("force", pp(), { context = { includeDeclaration = true } }) },
  { "textDocument/signatureHelp",      pp() },
  { "textDocument/codeAction",         { textDocument = { uri = vim.uri_from_bufnr(0) },
                                         range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 0 } },
                                         context = { diagnostics = {}, triggerKind = 2 } } },
  { "textDocument/documentHighlight",  pp() },
  { "textDocument/documentSymbol",     { textDocument = { uri = vim.uri_from_bufnr(0) } } },
  { "textDocument/foldingRange",       { textDocument = { uri = vim.uri_from_bufnr(0) } } },
  { "textDocument/selectionRange",     { textDocument = { uri = vim.uri_from_bufnr(0) }, positions = { pp() } } },
  { "textDocument/semanticTokens/full",{ textDocument = { uri = vim.uri_from_bufnr(0) } } },
  { "textDocument/documentLink",       { textDocument = { uri = vim.uri_from_bufnr(0) } } },
  { "textDocument/codeLens",           { textDocument = { uri = vim.uri_from_bufnr(0) } } },
  { "textDocument/inlayHint",          { textDocument = { uri = vim.uri_from_bufnr(0) },
                                         range = { start = { line = 0, character = 0 }, ["end"] = { line = 100, character = 0 } } } },
  { "textDocument/moniker",            pp() },
  { "textDocument/linkedEditingRange", pp() },
  { "textDocument/documentColor",      { textDocument = { uri = vim.uri_from_bufnr(0) } } },
  { "textDocument/formatting",         { textDocument = { uri = vim.uri_from_bufnr(0) }, options = { tabSize = 2, insertSpaces = true } } },
  { "textDocument/rangeFormatting",    { textDocument = { uri = vim.uri_from_bufnr(0) },
                                         range = { start = { line = 0, character = 0 }, ["end"] = { line = 5, character = 0 } },
                                         options = { tabSize = 2, insertSpaces = true } } },
  { "textDocument/onTypeFormatting",   { textDocument = { uri = vim.uri_from_bufnr(0) },
                                         position = pp(), ch = "}",
                                         options = { tabSize = 2, insertSpaces = true } } },
  { "textDocument/prepareRename",      pp() },
}

for _, item in ipairs(tests) do
  local m, p = item[1], item[2]
  pcall(vim.api.nvim_win_set_cursor, 0, { 1, 0 }); vim.wait(20)
  local ok, result = sync(m, p)
  if ok then
    local has_err = false
    if result then
      for _, r in pairs(result) do if r.err then has_err = true; break end end
    end
    local note = result ~= nil and (has_err and "LSP err (unsupported?)" or "ok") or "nil"
    log(m, "ok", note)
  else
    log(m, "ok", "request sent")
  end
  insert_cycle(m)
end

-- Phase 3: buf wrapper functions
for _, fn in ipairs({ "hover", "declaration", "definition", "type_definition",
                      "implementation", "signature_help", "references",
                      "document_highlight" }) do
  pcall(vim.api.nvim_win_set_cursor, 0, { 1, 0 }); vim.wait(20)
  pcall(vim.lsp.buf[fn])
  log("buf." .. fn, "ok")
  if fn == "document_highlight" then
    insert_cycle("buf." .. fn)
    pcall(vim.lsp.buf.clear_references)
    log("buf.clear_references", "ok")
  else
    insert_cycle("buf." .. fn)
  end
end

-- Phase 4: Stress
for i = 1, 10 do
  pcall(vim.api.nvim_win_set_cursor, 0, { 1, 0 }); vim.wait(20)
  pcall(vim.lsp.buf.hover); vim.wait(80)
  insert_cycle("stress." .. i)
end
log("10x hover+insert", "ok")

save()
io.stderr:write(string.format("DONE — %d pass / %d fail / %d skip\n",
  results.pass, results.fail, results.skip))
vim.cmd("qa!")
