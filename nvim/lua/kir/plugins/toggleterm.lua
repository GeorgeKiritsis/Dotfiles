return {
  -- amongst your other plugins
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    config = function()
      require('toggleterm').setup{
        direction = 'float',
        size = 15,
        open_mapping = [[<c-\>]],
        hide_numbers = true,
        shade_filetypes = {},
        shade_terminals = true,
        shading_factor = 2,
        start_in_insert = true,
        insert_mappings = true,
        terminal_mappings = true,
        persist_size = true,
        close_on_exit = true,
        shell = vim.o.shell,
        auto_scroll = true,
        float_opts = {
          border = 'curved', -- 'single', 'double', 'shadow', 'curved', etc.
          title_pos = 'center' -- 'left', 'center', 'right'
        },
        winbar = {
          enabled = true,
          name_formatter = function(term) -- term: Terminal
            return term.name
          end
        },
      }
    end
  }
}

