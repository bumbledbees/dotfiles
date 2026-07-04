require('util')

return {
{
    'neovimhaskell/haskell-vim',
    lazy = true,
    ft = 'haskell',
    init = function()
        local haskell_opts = {
            enable_quantification   = 1,
            enable_recursivedo      = 1,
            enable_arrowsyntax      = 1,
            enable_pattern_synonyms = 1,
            enable_typeroles        = 1,
            enable_static_pointers  = 1,
            backpack                = 1
        }
        apply_table(haskell_opts, function(k, v) vim.g['haskell_' .. k] = v end)
    end
},
{
    'vim-python/python-syntax',
    lazy = true,
    ft = 'python',
    init = function()
        local python_opts = {
            highlight_builtins              = true,
            highlight_builtins_funcs_kwarg  = false,
            highlight_class_vars            = true,
            highlight_exceptions            = true,
            highlight_indent_errors         = true,
            highlight_operators             = true,
            highlight_space_errors          = true,
            highlight_string_formatting     = true,
            highlight_string_format         = true,
            highlight_string_templates      = true,
        }
        apply_table(python_opts, function(k, v) vim.g['python_' .. k] = v end)
    end
},
{
    'udalov/kotlin-vim',
    lazy = true,
    ft = 'kotlin',
},
{
    'charlespascoe/vim-go-syntax',
    lazy = true,
    ft = 'go',
}
}
