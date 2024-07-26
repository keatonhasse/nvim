return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "L3MON4D3/LuaSnip",
    },
    config = function()
        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP actions",
            group = vim.api.nvim_create_augroup("lsp", { clear = true }),
            callback = function(event)
                vim.api.nvim_create_autocmd("BufWritePre", {
                    buffer = event.buf,
                    callback = function()
                        vim.lsp.buf.format { async = false, id = event.data.client_id }
                    end,
                })

                local opts = { buffer = event.buf }

                vim.keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
                vim.keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
                vim.keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
                vim.keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
                vim.keymap.set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
                vim.keymap.set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
                vim.keymap.set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
                vim.keymap.set("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
                vim.keymap.set({ "n", "x" }, "<F3>", "<cmd>lua vim.lsp.buf.format({async = true})<cr>", opts)
                vim.keymap.set("n", "<F4>", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
            end
        })

        local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

        require("mason").setup()
        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                --"biome",
                "gopls",
                "pyright",
            },
            handlers = {
                function(server)
                    require("lspconfig")[server].setup({
                        capabilities = lsp_capabilities,
                    })
                end,
                lua_ls = function()
                    require("lspconfig").lua_ls.setup({
                        capabilities = lsp_capabilities,
                        settings = {
                            Lua = {
                                diagnostics = {
                                    globals = { "vim" },
                                }
                            }
                        }
                    })
                end,
            },
        })

        local cmp = require("cmp")
        local cmp_select = { behavior = cmp.SelectBehavior.Select }
        cmp.setup({
            sources = {
                { name = "nvim_lsp" },
            },
            mapping = cmp.mapping.preset.insert({
                ["<Up>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<Down>"] = cmp.mapping.select_next_item(cmp_select),
                ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
                ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
        })
    end
}
