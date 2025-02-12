return {
    "joshdick/onedark.vim",  -- Using One Dark Pro instead of Gruvbox
    priority = 1000,
    config = function()
        -- Set the style for One Dark Pro (dark, darker, light)
        vim.g.onedark_style = "dark"  -- You can also try "darker" or "light"
        vim.g.onedark_term_colors = true  -- Enable terminal colors
        vim.g.onedark_wide_gaps = true  -- Optional: Adds wide gaps between windows

        -- Optional: Custom overrides to adjust the background and other colors
        vim.g.onedark_transparent_background = true  -- Enable transparency
        vim.g.onedark_italic_comments = true  -- Italicize comments (default: true)

        -- Customizing colors further if needed (example with palette overrides)
        vim.g.onedark_palette = {
            dark0_hard = "#21242a",  -- Much darker background (set to #21242a)
            dark1 = "#1a1a1a",  -- Slightly lighter dark background
            dark2 = "#262626",  -- Even lighter, but still dark
            dark3 = "#3b3b3b",  -- Dark background for text areas
            dark4 = "#4f4f4f",  -- Dark shade for the more subtle areas
            light0 = "#f2e5bc",  -- Adjust light colors for contrast
            light1 = "#f0e1a1",
            light2 = "#e8d67c",
        }

        -- Override specific elements to make the background #21242a
        vim.cmd([[highlight Normal guibg=#21242a]])  -- Set the Normal background to #21242a
        vim.cmd([[highlight StatusLine guibg=#21242a]])  -- Darken the status line background
        vim.cmd([[highlight LineNr guifg=#928374]])  -- Adjust line numbers color
        vim.cmd([[highlight CursorLineNr guifg=#d79921]])  -- Highlight the cursor line number

        -- Apply the One Dark colorscheme
        vim.cmd([[colorscheme onedark]])
    end,
}
