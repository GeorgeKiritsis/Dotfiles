return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    dependencies = {
      "3rd/image.nvim",
    },
    lazy = false,
    build = ":UpdateRemotePlugins",
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
      vim.g.molten_image_provider = "image.nvim"
    end,
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<CR>", desc = "Molten Init" },
      { "<leader>je", "<cmd>MoltenEvaluateOperator<CR>", desc = "Molten Eval Operator" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<CR>", desc = "Molten Eval Line" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<CR>", desc = "Molten Re-eval Cell" },
      { "<leader>jd", "<cmd>MoltenDelete<CR>", desc = "Molten Delete Cell" },
      { "<leader>jh", "<cmd>MoltenHideOutput<CR>", desc = "Molten Hide Output" },
      { "<leader>jo", "<cmd>MoltenShowOutput<CR>", desc = "Molten Show Output" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<CR>gv", mode = "v", desc = "Molten Eval Visual" },
      {
        "<leader>jc",
        function()
          -- Find the start and end of the current code block (``` fences)
          local start_line = vim.fn.search("^```", "bnW")
          local end_line = vim.fn.search("^```", "nW")
          if start_line == 0 or end_line == 0 then
            vim.notify("No code block found", vim.log.levels.WARN)
            return
          end
          -- Evaluate the lines between the fences
          vim.fn.MoltenEvaluateRange(start_line + 1, end_line - 1)
        end,
        desc = "Molten Eval Cell",
      },
    },
  },
  {
    "3rd/image.nvim",
    opts = {
      backend = "kitty",
      max_width = 100,
      max_height = 12,
      integrations = {
        markdown = { enabled = true },
      },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    config = true,
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {},
    ft = { "markdown" },
    config = function()
      local otter = require("otter")
      otter.setup({
        lsp = {
          diagnostic_update_events = { "BufWritePost" },
        },
        buffers = {
          set_filetype = true,
        },
      })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function()
          otter.activate({ "python" }, true, true, nil)
        end,
      })
    end,
  },
}
