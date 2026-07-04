local languages = {
    'arduino', 'asm', 'awk', 'bash', 'c', 'cmake', 'cpp', 'css', 'csv',
    'desktop', 'diff', 'disassembly', 'dockerfile', 'fish', 'git_config',
    'git_rebase', 'gitattributes', 'gitcommit', 'gitignore', 'go',
    'haskell', 'html', 'java', 'javadoc', 'javascript', 'jinja',
    'jinja_inline', 'jq', 'jsdoc', 'json', 'json5', 'jsx', 'kconfig',
    'kitty', 'kotlin', 'latex', 'llvm', 'lua', 'luadoc', 'make',
    'markdown', 'markdown_inline', 'meson', 'muttrc', 'meson', 'nginx',
    'ninja', 'nix', 'objdump', 'ocaml', 'ocaml_interface', 'passwd', 'pem',
    'perl', 'php', 'phpdoc', 'powershell', 'printf', 'python', 'r',
    'racket', 'readline', 'regex', 'requirements', 'rst', 'ruby', 'rust',
    'slint', 'sql', 'ssh_config', 'strace', 'tmux', 'todotxt', 'toml',
    'tsv', 'tsx', 'typescript', 'udev', 'vim', 'vimdoc', 'xml',
    'xresources', 'yaml', 'zig', 'zsh'
}

return {
{
    'nvim-treesitter/nvim-treesitter',
    lazy = 'true',
    ft = languages,
    branch = 'main',
    opts = { install_dir = vim.fn.stdpath('data') .. '/site' },
    init = function ()
        require('nvim-treesitter').install(languages)
        for _, lang in ipairs(languages) do
            vim.api.nvim_create_autocmd('FileType', {
                pattern = { lang },
                callback = function()
                    vim.treesitter.start()
                    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end
    end
}
}
