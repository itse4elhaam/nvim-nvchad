local function run()
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "line 1", "line 2", "line 3" })
  vim.api.nvim_win_set_cursor(0, { 2, 0 })

  local ok, err = pcall(require("custom.utils").insert_separator_below)
  if not ok then
    error("insert_separator_below() threw: " .. tostring(err))
  end

  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

  assert(lines[1] == "line 1", "expected 'line 1', got '" .. (lines[1] or "nil") .. "'")
  assert(lines[2] == "line 2", "expected 'line 2', got '" .. (lines[2] or "nil") .. "'")
  assert(lines[3] == "---", "expected '---', got '" .. (lines[3] or "nil") .. "'")
  assert(lines[4] == "line 3", "expected 'line 3', got '" .. (lines[4] or "nil") .. "'")
  assert(#lines == 4, "expected 4 lines, got " .. #lines)

  local cursor = vim.api.nvim_win_get_cursor(0)
  assert(cursor[1] == 4, "expected cursor line 4, got " .. cursor[1])
  assert(cursor[2] == 0, "expected cursor column 0, got " .. cursor[2])

  print("PASS")
end

local ok, err = pcall(run)
if ok then
  vim.cmd "q!"
else
  io.stderr:write("FAIL: " .. tostring(err) .. "\n")
  vim.cmd "cquit!"
end
