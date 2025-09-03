return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        -- Import necessary plugins
        local lspconfig = require("lspconfig")
        local mason_lspconfig = require("mason-lspconfig")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- Set up key mappings for LSP actions
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }
                vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
                vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
                vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
                vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
            end,
        })

        -- Enable autocompletion capabilities
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Set diagnostic symbols in the sign column
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Configure LSP servers through mason-lspconfig
        mason_lspconfig.setup_handlers({
            -- Default handler for installed servers
            function(server_name)
                lspconfig[server_name].setup({
                    capabilities = capabilities,
                    cmd_env = {
                        PYRIGHT_PYTHON_PATH = "/Users/giorgoskir/miniconda3/envs/spyder/bin/python",
                    },
                })
            end,
            -- Lua language server with customized settings
            ["lua_ls"] = function()
                lspconfig["lua_ls"].setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            diagnostics = {
                                globals = { "vim" },
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                })
            end,
            -- TexLab configuration for LaTeX support
            ["texlab"] = function()
                lspconfig["texlab"].setup({
                    capabilities = capabilities,
                    settings = {
                        texlab = {
                            build = {
                                args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
                                command = "latexmk",
                                cwd = vim.fn.getcwd(),
                            },
                            forwardSearch = {
                                args = { "--synctex", "-forward-search", "%f", "%l" },
                                command = "zathura",
                            },
                            lint = {
                                onChange = true,
                                onSave = true,
                            },
                        },
                    },
                })
            end,
            -- Clangd configuration with SDL2 support and query-driver
            ["clangd"] = function()
                lspconfig["clangd"].setup({
                    capabilities = capabilities,
                    cmd = {
                        "clangd",
                        "--header-insertion=never",
                        "--clang-tidy",
                        "--completion-style=detailed",
                        "--compile-commands-dir=" .. vim.fn.getcwd(),
                        "--query-driver=/usr/bin/clang,/usr/bin/clang++,/opt/homebrew/bin/clang++",
                    },
                    settings = {
                        clangd = {
                            arguments = {
                                "-I/opt/homebrew/include/SDL2",
                            },
                        },
                    },
                })
            end,

            ["glslls"] = function()
                lspconfig["glslls"].setup({
                    capabilities = capabilities,
                    cmd = { "glslls", "--target-env=opengl" }, -- same idea
                    filetypes = {"vs", "fs", "gs" },
                })
            end,

            ["intelephense"] = function()
                lspconfig["intelephense"].setup({
                    capabilities = capabilities,
                    settings = {
                        intelephense = {
                            files = {
                                maxSize = 5000000; -- Adjust if working on large codebases
                            },
                            environment = {
                                includePaths = { "./vendor" } -- For Laravel or Composer projects
                            },
                        },
                    },
                })
            end,

            -- Python LSP (Pyright) configuration with cv2 in pkgExtensions
            ["pyright"] = function()
                lspconfig["pyright"].setup({
                    capabilities = capabilities,
                    settings = {
                        python = {
                            interpreterPath = "/Users/giorgoskir/miniconda3/envs/spyder/bin/python",
                            analysis = {
                                typeCheckingMode = "basic",  -- Change to "off" or "strict" as needed
                                extraPaths = {
                                    "/Users/giorgoskir/miniconda3/envs/spyder/lib/python3.x/site-packages", -- Adjust python3.x as needed
                                },
                                pkgExtensions = {
                                    "cv2",
                                },
                            },
                        },
                    },
                })
            end,
        })
    end,
}
