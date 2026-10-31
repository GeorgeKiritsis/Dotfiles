--formatters.lua
return {
  "stevearc/conform.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    formatters_by_ft = {
      php = { "php-cs-fixer" },
      python = { "isort", "black" },
    },
    -- Format only on manual :w, not on auto-save writes
    format_on_save = function()
      if vim.g.autosave_in_progress then
        return
      end
      return { lsp_fallback = true, timeout_ms = 1000 }
    end,
    formatters = {
      ["php-cs-fixer"] = {
        command = "php-cs-fixer",
        args = {
          "fix",
          "--rules=@PSR12", -- Formatting preset. Other presets are available, see the php-cs-fixer docs.
          "$FILENAME",
        },
        stdin = false,
      },
    },
    notify_on_error = true,
  },
}
