local ok, productivity = pcall(require, "custom.productivity")

if not ok then
  vim.schedule(function()
    vim.notify("Could not load productivity system", vim.log.levels.ERROR)
  end)
  return
end

productivity.setup()
