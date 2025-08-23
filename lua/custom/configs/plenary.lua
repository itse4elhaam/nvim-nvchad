local config = function()
  -- Code to run after plenary.nvim is loaded
  local Job = require "plenary.job"
  local async = require "plenary.async"

  -- Path to wakatime-cli
  local wakatime_cli_path = os.getenv "HOME" .. "/.wakatime/wakatime-cli"

  -- Store reference to timer and job for proper cleanup
  local wakatime_timer = nil
  local current_job = nil

  -- Check if the wakatime-cli exists
  local function is_wakatime_cli_available()
    return vim.fn.filereadable(wakatime_cli_path) == 1
  end

  -- Kill any existing job before starting a new one to prevent zombie processes
  local function kill_existing_job()
    if current_job and current_job.is_shutdown == false then
      pcall(function()
        current_job:shutdown()
        current_job = nil
      end)
    end
  end

  -- Define an asynchronous function to get today's WakaTime usage
  local get_wakatime_time = async.void(function()
    -- Prevent multiple concurrent jobs
    kill_existing_job()

    if not is_wakatime_cli_available() then
      vim.notify("WakaTime CLI not found at " .. wakatime_cli_path, vim.log.levels.WARN)
      return
    end

    local tx, rx = async.control.channel.oneshot()
    local ok, job = pcall(Job.new, Job, {
      command = wakatime_cli_path,
      args = { "--today" },
      on_exit = function(j, _)
        tx(j:result()[1] or "No data")
      end,
    })
    if not ok then
      vim.notify("Failed to create WakaTime job: " .. job, vim.log.levels.ERROR)
      return
    end

    -- Store job reference for potential cleanup
    current_job = job

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

  -- Start a timer that runs every 15 minutes (900000 ms)
  -- This replaces the CursorHold approach which was causing high CPU usage
  local function start_wakatime_timer()
    -- Stop existing timer if running
    if wakatime_timer then
      wakatime_timer:stop()
    end

    -- Create new timer
    wakatime_timer = vim.loop.new_timer()
    if wakatime_timer then
      -- Run immediately on first start, then every 15 minutes
      wakatime_timer:start(
        0,
        900000,
        vim.schedule_wrap(function()
          async.run(get_wakatime_time)
        end)
      )
    end
  end

  -- Start the timer when config is loaded
  start_wakatime_timer()

  -- Restart timer when Neovim gains focus (to handle suspend/resume)
  vim.api.nvim_create_autocmd("FocusGained", {
    pattern = "*",
    callback = start_wakatime_timer,
    desc = "Restart WakaTime timer when Neovim gains focus",
  })

  -- Clean up timer and job when Neovim exits
  vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "*",
    callback = function()
      if current_job then
        kill_existing_job()
      end
      if wakatime_timer then
        wakatime_timer:stop()
        wakatime_timer:close()
      end
    end,
    desc = "Clean up WakaTime timer and job on exit",
  })
end

return config
