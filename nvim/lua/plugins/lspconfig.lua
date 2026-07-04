local languages = {
    'python', 'rust', 'slint'
}
return {
{
    'neovim/nvim-lspconfig',
    lazy = true,
    ft = languages,
    init = function ()
        local capabilities = require('cmp_nvim_lsp').default_capabilities()
        local servers = {'pylsp', 'rust_analyzer', 'slint_lsp'}
        for _, lsp in ipairs(servers) do
            vim.lsp.config(lsp, {
                capabilities = capabilities,
            })
            vim.lsp.enable(lsp)
        end
        nmap('<leader>?', ':lua vim.diagnostic.open_float()<CR>', { silent = true })
    end
},
{ 'hrsh7th/cmp-nvim-lsp' , lazy = true },
{
    'hrsh7th/nvim-cmp',
    lazy = true,
    ft = languages,
    init = function ()
        local cmp = require('cmp')
        local opts = {
            snippet = {
                expand = function(args) require('luasnip').lsp_expand(args.body) end,
            },
            mapping = cmp.mapping.preset.insert({
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-CR>'] = cmp.mapping.confirm(),
                ['<C-c>'] = cmp.mapping.abort(),
            }),
            window = {
                -- completion = cmp.config.window.bordered(),
                -- documentation = cmp.config.window.bordered(),
            },
            sources = cmp.config.sources({
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
            }, {
                { name = 'buffer' },
            })
        }
        cmp.setup(opts)
    end
},
{ 'L3MON4D3/LuaSnip' , lazy = true },
{ 'saadparwaiz1/cmp_luasnip' , lazy = true },
}
