--- Markdown editing helpers: toggle wrapping markers (bold/italic/etc),
--- insert links, and toggle task checkboxes.
---
--- Used by the `M.markdown` section in `lua/custom/mappings.lua`.
--- Pure Lua, no plugin dependency; only acts in markdown-ish filetypes.

local M = {}

--- Filetypes where these helpers make sense. Mirrors the markdown pattern
--- used for syntax handling in `lua/custom/init.lua`.
local MARKDOWN_FILETYPES = { "markdown", "quarto", "rmd" }

---@return boolean
local function is_markdown()
  return vim.tbl_contains(MARKDOWN_FILETYPES, vim.bo.filetype)
end

---@param c string
---@return boolean whether `c` is part of a markdown word (like `iw`)
local function is_word_char(c)
  return c:find "[%w_]" ~= nil
end

--- Region of the word under the cursor (single line).
---@return integer|nil start_row, integer|nil start_col, integer|nil end_col 1-based inclusive
local function word_region()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]
  local line = vim.api.nvim_get_current_line()
  local col = math.min(cursor[2] + 1, #line)

  if col == 0 or not is_word_char(line:sub(col, col)) then
    return nil
  end

  local s, e = col, col
  while s > 1 and is_word_char(line:sub(s - 1, s - 1)) do
    s = s - 1
  end
  while e < #line and is_word_char(line:sub(e + 1, e + 1)) do
    e = e + 1
  end

  return row, s, e
end

--- Region of the current selection or word under the cursor.
---@return integer|nil start_row, integer|nil start_col, integer|nil end_row, integer|nil end_col (0-indexed, exclusive end)
local function get_region()
  local mode = vim.api.nvim_get_mode().mode
  if mode:find "[vV]" then
    local a = vim.fn.getpos "'<"
    local b = vim.fn.getpos "'>"
    return a[2] - 1, a[3] - 1, b[2] - 1, b[3]
  end

  local row, s, e = word_region()
  if not row then
    return nil
  end
  return row - 1, s - 1, row - 1, e
end

--- Wrapper around `nvim_buf_get_text` returning the joined string.
---@param start_row integer
---@param start_col integer
---@param end_row integer
---@param end_col integer
---@return string
local function get_region_text(start_row, start_col, end_row, end_col)
  return table.concat(vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {}), "\n")
end

--- Wrap the current selection (visual mode) or word under cursor (normal mode)
--- with `marker`. Toggles: strips the marker pair when already present,
--- including when the cursor sits on an already-wrapped word.
---@param marker string e.g. "**", "*", "~~", "`", "=="
function M.wrap(marker)
  if not is_markdown() then
    vim.notify("Markdown mapping only works in markdown buffers", vim.log.levels.INFO)
    return
  end

  local is_visual = vim.api.nvim_get_mode().mode:find "[vV]" ~= nil
  local start_row, start_col, end_row, end_col = get_region()
  if not start_row then
    vim.notify("Cursor is not on a word", vim.log.levels.INFO)
    return
  end
  local orig_cursor = vim.api.nvim_win_get_cursor(0)

  -- In normal mode, if the word is already wrapped, widen the region to
  -- include the adjacent markers so the toggle strips them.
  if not is_visual then
    local line = vim.api.nvim_get_current_line()
    local before = line:sub(1, start_col) -- cols are 0-indexed here
    local after = line:sub(end_col + 1)
    if before:sub(-#marker) == marker and after:sub(1, #marker) == marker then
      start_col = start_col - #marker
      end_col = end_col + #marker
    end
  end

  local text = get_region_text(start_row, start_col, end_row, end_col)
  if text == "" then
    vim.notify("No text selected", vim.log.levels.INFO)
    return
  end

  local is_wrapped = #text >= 2 * #marker and text:sub(1, #marker) == marker and text:sub(-#marker) == marker
  local inner = is_wrapped and text:sub(#marker + 1, -#marker - 1) or marker .. text .. marker

  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, vim.split(inner, "\n", { plain = true }))

  if is_visual then
    vim.cmd "normal! gv" -- keep the selection for repeated edits
  else
    -- Shift the cursor right by the marker length so it stays on the wrapped
    -- word (markers were inserted before it) -> pressing the key again toggles off.
    vim.api.nvim_win_set_cursor(0, { orig_cursor[1], orig_cursor[2] + #marker })
  end
end

--- Wrap the selection/word as a markdown link `[text](url)`.
--- Pre-fills the URL prompt with the clipboard contents when available.
function M.add_link()
  if not is_markdown() then
    vim.notify("Markdown mapping only works in markdown buffers", vim.log.levels.INFO)
    return
  end

  local is_visual = vim.api.nvim_get_mode().mode:find "[vV]" ~= nil
  local start_row, start_col, end_row, end_col = get_region()
  if not start_row then
    vim.notify("Cursor is not on a word", vim.log.levels.INFO)
    return
  end
  local orig_cursor = vim.api.nvim_win_get_cursor(0)

  local text = get_region_text(start_row, start_col, end_row, end_col)
  if text == "" then
    vim.notify("No text selected", vim.log.levels.INFO)
    return
  end

  local url = vim.fn.input("URL: ", vim.fn.getreg "+")
  if url == "" then
    return
  end

  vim.api.nvim_buf_set_text(0, start_row, start_col, end_row, end_col, { "[" .. text .. "](" .. url .. ")" })

  if is_visual then
    vim.cmd "normal! gv"
  else
    vim.api.nvim_win_set_cursor(0, orig_cursor)
  end
end

--- Toggle a task checkbox on the current line: `- [ ]` <-> `- [x]`,
--- or create one when the line is plain text. Handles `-`, `*` and `+` bullets.
function M.toggle_task()
  if not is_markdown() then
    vim.notify("Markdown mapping only works in markdown buffers", vim.log.levels.INFO)
    return
  end

  local line = vim.api.nvim_get_current_line()

  if line:match "^%s*[-*+] %[x%]" then
    line = line:gsub("^(%s*[-*+] %[)x(]%s*)", "%1 %2", 1)
  elseif line:match "^%s*[-*+] %[ %]" then
    line = line:gsub("^(%s*[-*+] %[) (]%s*)", "%1x%2", 1)
  elseif line:match "^%s*[-*+] " then
    line = line:gsub("^(%s*)([-*+] )(.*)$", "%1%2[ ] %3", 1)
  else
    line = "- [ ] " .. line
  end

  vim.api.nvim_set_current_line(line)
end

return M
