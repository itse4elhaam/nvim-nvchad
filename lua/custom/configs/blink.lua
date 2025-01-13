local opts = {
  completion = {
    accept = {
      -- experimental auto-brackets support
      auto_brackets = {
        enabled = true,
      },
    },
    menu = {
      scrollbar = false,
      border = "rounded",
      draw = {
        columns = { { "label", "label_description", gap = 1 }, { "kind_icon", "kind", gap = 1 } },
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
  },
  keymap = {
    preset = "super-tab",
    ["<CR>"] = { "accept", "fallback" },
    -- TODO: replace with a loop
    ["<A-1>"] = {
      function(cmp)
        cmp.accept { index = 1 }
      end,
    },
    ["<A-2>"] = {
      function(cmp)
        cmp.accept { index = 2 }
      end,
    },
    ["<A-3>"] = {
      function(cmp)
        cmp.accept { index = 3 }
      end,
    },
    ["<A-4>"] = {
      function(cmp)
        cmp.accept { index = 4 }
      end,
    },
    ["<A-5>"] = {
      function(cmp)
        cmp.accept { index = 5 }
      end,
    },
    ["<A-6>"] = {
      function(cmp)
        cmp.accept { index = 6 }
      end,
    },
    ["<A-7>"] = {
      function(cmp)
        cmp.accept { index = 7 }
      end,
    },
    ["<A-8>"] = {
      function(cmp)
        cmp.accept { index = 8 }
      end,
    },
    ["<A-9>"] = {
      function(cmp)
        cmp.accept { index = 9 }
      end,
    },
  },
  appearance = {
    nerd_font_variant = "mono",
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },

  signature = { enabled = false },
}

return opts
