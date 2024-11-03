return {
    { 'lervag/vimtex', config = function()
        -- VimTeX configuration
        vim.g.vimtex_view_method = 'zathura'
        vim.g.vimtex_compiler_method = 'latexmk'

        -- Set xelatex as the LaTeX engine for Greek language support
        vim.g.vimtex_compiler_latexmk = {
            callback = 1,
            continuous = 1,
            executable = 'latexmk',
            options = {
                '-xelatex',  -- Use xelatex for Greek support
                '-shell-escape',
                '-verbose',
                '-file-line-error',
                '-synctex=1',
                '-interaction=nonstopmode',
            },
        }

        -- Automatically open the PDF viewer (Zathura) when opening the TeX file
        vim.g.vimtex_view_automatic = 1
    end }
}
