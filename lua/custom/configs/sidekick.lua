return {
  opts = {
    jump = {
      jumplist = true, -- add an entry to the jumplist
    },
    signs = {
      enabled = true, -- enable signs by default
      icon = " ", -- nerd font icon for sidekick
    },
    nes = {
      enabled = function(buf)
        return vim.g.sidekick_nes ~= false and vim.b.sidekick_nes ~= false
      end,
      debounce = 100,
      trigger = {
        -- events that trigger sidekick next edit suggestions
        events = { "InsertLeave", "TextChanged", "User SidekickNesDone" },
      },
      clear = {
        -- events that clear the current next edit suggestion
        events = { "TextChangedI", "BufWritePre", "InsertEnter" },
        esc = true, -- clear next edit suggestions when pressing <Esc>
      },
      diff = {
        inline = "words", -- Enable word-level inline diffs
      },
    },
    -- Work with AI cli tools directly from within Neovim
    cli = {
      watch = true, -- notify Neovim of file changes done by AI CLI tools
      win = {
        wo = {},
        bo = {},
        width = 80,
        height = 20,
        layout = "vertical",
        position = "right",
        -- CLI Tool Keymaps
        keys = {
          stopinsert = { "<esc><esc>", "stopinsert", mode = "t" }, -- enter normal mode
          hide_n = { "q", "hide", mode = "n" }, -- hide from normal mode
          hide_t = { "<c-q>", "hide" }, -- hide from terminal mode
          win_p = { "<c-w>p", "blur" }, -- leave the cli window
          blur = { "<c-o>", "blur" }, -- leave the cli window
          prompt = { "<c-p>", "prompt" }, -- insert prompt or context
        },
      },
      mux = {
        backend = "tmux", -- Use tmux since user has tmux integration
        enabled = true,
      },
      -- Configure available AI CLI tools
      tools = {
        claude = { cmd = { "claude" }, url = "https://github.com/anthropics/claude-code" },
        copilot = { cmd = { "copilot", "--banner" }, url = "https://github.com/github/copilot-cli" },
        gemini = { cmd = { "gemini" }, url = "https://github.com/google-gemini/gemini-cli" },
        grok = { cmd = { "grok" }, url = "https://github.com/superagent-ai/grok-cli" },
      },
      -- Pre-defined prompts for common tasks
      prompts = {
        explain = "Explain this code",
        diagnostics = {
          msg = "What do the diagnostics in this file mean?",
          diagnostics = true,
        },
        diagnostics_all = {
          msg = "Can you help me fix these issues?",
          diagnostics = { all = true },
        },
        fix = {
          msg = "Can you fix the issues in this code?",
          diagnostics = true,
        },
        review = {
          msg = "Can you review this code for any issues or improvements?",
          diagnostics = true,
        },
        optimize = "How can this code be optimized?",
        tests = "Can you write tests for this code?",
        refactor = "Can you refactor this code to be cleaner and more maintainable?",
        document = "Can you add comprehensive documentation to this code?",
      },
    },
    debug = false, -- enable debug logging if needed
  },
  config = function(_, opts)
    require("sidekick").setup(opts)
  end,
}