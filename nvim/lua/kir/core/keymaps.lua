-- set leader key to space
vim.g.mapleader = " "


local keymap = vim.keymap -- for conciseness
-- ysiw to surround word

---------------------
-- General Keymaps -------------------


-- use sw to surround word
-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- increment/decrement numbers
keymap.set("n", "<leader>+", "<C-a>", { desc = "Increment number" }) -- increment
keymap.set("n", "<leader>-", "<C-x>", { desc = "Decrement number" }) -- decrement

-- window management
keymap.set("n", "<leader>sv", "<C-w>v", { desc = "Split window vertically" }) -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s", { desc = "Split window horizontally" }) -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=", { desc = "Make splits equal size" }) -- make split windows equal width & height
keymap.set("n", "<leader>sx", "<cmd>close<CR>", { desc = "Close current split" }) -- close current split window

keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" }) -- open new tab
keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" }) --  go to next tab
keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" }) --  go to previous tab
keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" }) --  move current buffer to new tab

--Open Terminals (Mainly For Zathura)
keymap.set("n", "<leader>stv", ":vsplit<CR>:terminal<CR>", { desc = "Split window vertically and open terminal" })
keymap.set("n", "<leader>sth", ":split<CR>:terminal<CR>", { desc = "Split window horizontally and open terminal" })

-- Exit terminal mode
keymap.set("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Move current line up
keymap.set("n", "<C-[>", ":m .-2<CR>==", { noremap = true, silent = true })

-- Move current line down
keymap.set("n", "<C-]>", ":m .+1<CR>==", { noremap = true, silent = true })

vim.opt.wrap = true


-- Markdown Files

keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>",{desc = "Open Markdown Preview" }) -- increment

-- Undo Tree

keymap.set("n", "<leader>u", "<cmd>UndotreeToggle<CR>", {desc = "Toggle Undo Tree"})

-- Toggle Term

keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<CR>", {desc = "Toggle Terminal"})

-- VimTeX configuration for real-time compilation and auto-open Zathura

-- Enable Zathura as the PDF viewer
vim.g.vimtex_view_method = 'zathura'

-- Set latexmk as the continuous compiler
vim.g.vimtex_compiler_method = 'latexmk'

-- Automatically open the PDF viewer (Zathura) on opening the TeX file
vim.g.vimtex_view_automatic = 1

-- Automatically start compilation when editing a .tex file
vim.g.vimtex_compiler_latexmk = {
  callback = 1,
  continuous = 1, -- Enable continuous mode for auto-recompilation on save
  executable = 'latexmk',
  options = {
    '-shell-escape', -- Add extra options if needed
    '-verbose',
    '-file-line-error',
    '-synctex=1',
    '-interaction=nonstopmode',
  },
}

-- Optional: disable quickfix window if you prefer not to see it on error
vim.g.vimtex_quickfix_mode = 0
