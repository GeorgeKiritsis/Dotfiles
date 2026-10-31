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
                    filetypes = {"vs", "fs", "gs", "shader"},
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

            -- Python LSP (Pyright) with dynamic conda/venv detection
            ["pyright"] = function()
              local function get_python_path()
                local venv = vim.env.VIRTUAL_ENV or vim.env.CONDA_PREFIX
                if venv then
                  return venv .. "/bin/python"
                end
                local cwd = vim.fn.getcwd()
                local local_venv = cwd .. "/.venv/bin/python"
                if vim.fn.executable(local_venv) == 1 then
                  return local_venv
                end
                return "/Users/giorgoskir/miniconda3/envs/spyder/bin/python"
              end

              lspconfig["pyright"].setup({
                capabilities = capabilities,
                settings = {
                  python = {
                    pythonPath = get_python_path(),
                    analysis = {
                      autoSearchPaths = true,
                      useLibraryCodeForTypes = true,
                      typeCheckingMode = "basic",
                      diagnosticMode = "openFilesOnly",
                    },
                  },
                },
              })
            end,
        })

        -- Command to switch Python environment on the fly
        vim.api.nvim_create_user_command("PyrightSetEnv", function(opts)
          local path = opts.args
          local clients = vim.lsp.get_clients({ name = "pyright" })
          for _, client in ipairs(clients) do
            client.config.settings.python.pythonPath = path
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
          vim.notify("Pyright python path: " .. path)
        end, {
          nargs = 1,
          desc = "Set Pyright Python interpreter path",
        })
    end,
}
