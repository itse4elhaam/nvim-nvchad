local M = {}

local function vault_root()
  local ok, obsidian = pcall(require, "custom.configs.obsidian")
  if ok and obsidian.workspaces and obsidian.workspaces[1] and obsidian.workspaces[1].path then
    return vim.fn.expand(obsidian.workspaces[1].path)
  end

  return vim.fn.expand("~/vaults/obsidian-notes")
end

---@param path string
---@return boolean, string|nil
local function ensure_parent(path)
  local parent = vim.fn.fnamemodify(path, ":h")
  local result = vim.fn.mkdir(parent, "p")

  if result == 0 and vim.fn.isdirectory(parent) ~= 1 then
    return false, "Could not create directory: " .. parent
  end

  return true, nil
end

---@param path string
---@param lines string[]
---@return boolean, string|nil
local function write_if_missing(path, lines)
  if vim.fn.filereadable(path) == 1 then
    return true, nil
  end

  local ok, err = ensure_parent(path)
  if not ok then
    return false, err
  end

  local write_result = vim.fn.writefile(lines, path)
  if write_result ~= 0 then
    return false, "Could not write note: " .. path
  end

  return true, nil
end

---@param path string
local function edit(path)
  vim.cmd("edit " .. vim.fn.fnameescape(path))
end

---@param date string
---@return string[]
local function daily_template(date)
  return {
    "---",
    'id: "' .. date .. '"',
    "aliases: []",
    "tags:",
    "  - daily-notes",
    "---",
    "",
    "",
    "# Action Items",
    "",
    "## Must do",
    "",
    "## Should do",
    "",
    "## Could do",
    "",
    "# Notes",
    "",
  }
end

---@param week string
---@return string[]
local function weekly_template(week)
  return {
    "---",
    'id: "' .. week .. '"',
    "tags:",
    "  - weekly-review",
    "---",
    "",
    "# " .. week,
    "",
    "## Outcomes",
    "",
    "> Maximum 5 meaningful outcomes.",
    "",
    "- [ ]",
    "- [ ]",
    "- [ ]",
    "- [ ]",
    "- [ ]",
    "",
    "## Active Projects",
    "",
    "> Maximum 3 project-level priorities.",
    "",
    "1. ",
    "2. ",
    "3. ",
    "",
    "## Not This Week",
    "",
    "- ",
    "",
    "## Waiting",
    "",
    "- ",
    "",
    "## Review",
    "",
    "- What became irrelevant?",
    "- What is waiting on someone else?",
    "- What genuinely must move next week?",
    "- What am I deliberately not doing?",
    "- What needs calendar time?",
  }
end

---@return string
local function today_path()
  local date = vim.fn.strftime("%Y-%m-%d")
  return vault_root() .. "/Fleeting/daily/" .. date .. ".md"
end

---@return string
local function week_path()
  local week = vim.fn.strftime("%G-W%V")
  return vault_root() .. "/Fleeting/weekly/" .. week .. ".md"
end

---@return boolean, string|nil
local function ensure_today()
  local date = vim.fn.strftime("%Y-%m-%d")
  return write_if_missing(today_path(), daily_template(date))
end

---@return boolean, string|nil
local function ensure_week()
  local week = vim.fn.strftime("%G-W%V")
  return write_if_missing(week_path(), weekly_template(week))
end

function M.open_today()
  local ok, err = ensure_today()
  if not ok then
    vim.notify(err or "Could not open today's note", vim.log.levels.ERROR)
    return
  end

  edit(today_path())
end

function M.open_week()
  local ok, err = ensure_week()
  if not ok then
    vim.notify(err or "Could not open weekly note", vim.log.levels.ERROR)
    return
  end

  edit(week_path())
end

function M.open_tasks()
  edit(vault_root() .. "/Fleeting/tasks.md")
end

function M.open_someday()
  edit(vault_root() .. "/Fleeting/someday.md")
end

function M.open_system()
  edit(vault_root() .. "/Permanent/productivity-system.md")
end

function M.find_projects()
  local projects_root = vault_root() .. "/Projects"
  local ok, telescope = pcall(require, "telescope.builtin")

  if not ok then
    vim.notify("Telescope is required to browse projects", vim.log.levels.ERROR)
    return
  end

  telescope.find_files {
    cwd = projects_root,
    prompt_title = "Projects",
    hidden = false,
  }
end

function M.capture_to_today()
  local ok, err = ensure_today()
  if not ok then
    vim.notify(err or "Could not create today's note", vim.log.levels.ERROR)
    return
  end

  local text = vim.fn.input "Capture: "
  if text == nil or vim.trim(text) == "" then
    return
  end

  local path = today_path()
  local lines = vim.fn.readfile(path)
  local insert_at = nil

  for index, line in ipairs(lines) do
    if line == "## Inbox" then
      insert_at = index + 1
      while insert_at <= #lines and (lines[insert_at] == "" or vim.startswith(lines[insert_at], ">")) do
        insert_at = insert_at + 1
      end
      break
    end
  end

  local task = "- [ ] " .. vim.trim(text)

  if insert_at then
    table.insert(lines, insert_at, task)
  else
    vim.list_extend(lines, { "", "## Inbox", "", task })
  end

  local write_result = vim.fn.writefile(lines, path)
  if write_result ~= 0 then
    vim.notify("Could not capture into today's note", vim.log.levels.ERROR)
    return
  end

  vim.notify("Captured to today's Inbox", vim.log.levels.INFO)
end

function M.setup()
  if vim.g.productivity_system_loaded then
    return
  end

  vim.g.productivity_system_loaded = true

  local mappings = {
    { "<leader>ot", M.open_today, "Productivity: open today" },
    { "<leader>ow", M.open_week, "Productivity: open this week" },
    { "<leader>oa", M.open_tasks, "Productivity: open task warehouse" },
    { "<leader>os", M.open_someday, "Productivity: open someday" },
    { "<leader>op", M.find_projects, "Productivity: browse projects" },
    { "<leader>oi", M.capture_to_today, "Productivity: capture to today" },
    { "<leader>or", M.open_system, "Productivity: open system reference" },
  }

  for _, mapping in ipairs(mappings) do
    vim.keymap.set("n", mapping[1], mapping[2], { desc = mapping[3], silent = true })
  end

  vim.api.nvim_create_user_command("Today", M.open_today, {})
  vim.api.nvim_create_user_command("Week", M.open_week, {})
  vim.api.nvim_create_user_command("Tasks", M.open_tasks, {})
  vim.api.nvim_create_user_command("Someday", M.open_someday, {})
  vim.api.nvim_create_user_command("Projects", M.find_projects, {})
  vim.api.nvim_create_user_command("Capture", M.capture_to_today, {})
  vim.api.nvim_create_user_command("ProductivitySystem", M.open_system, {})
end

return M
