local config = function()
  -- Code to run after plenary.nvim is loaded
  local Job = require "plenary.job"
  local async = require "plenary.async"

  -- Define an asynchronous function to get today's WakaTime usage
  -- TODO: need to do this without the wakatime cli
  local get_wakatime_time = async.void(function()
    local tx, rx = async.control.channel.oneshot()
    local ok, job = pcall(Job.new, Job, {
      command = os.getenv "HOME" .. "/.wakatime/wakatime-cli",
      args = { "--today" },
      on_exit = function(j, _)
        tx(j:result()[1] or "No data")
      end,
    })
    if not ok then
      vim.notify("Failed to create WakaTime job: " .. job, "error")
      return
    end

    job:start()
    local result = rx()
    if result then
      print(result) -- Print the result to Neovim's command line
    end
  end)

  -- Define a command to execute the async function
  vim.api.nvim_create_user_command("FetchWakaTime", function()
    async.run(get_wakatime_time)
  end, {})

  -- Optional: Set an autocommand to fetch WakaTime data on a regular basis
  vim.api.nvim_create_autocmd("CursorHold", {
    pattern = "*",
    callback = function()
      async.run(get_wakatime_time)
    end,
    desc = "Fetch WakaTime data when the cursor is held in place",
  })
end

return config
