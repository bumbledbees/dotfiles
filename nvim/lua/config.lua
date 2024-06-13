require('util')


-- Configuration Options
local globals = {
    mapleader   = '_',
    --
    tex_flavor  = 'latex',
}
apply_table(globals, function(opt, val) vim.g[opt] = val end)

local options = {
    modeline        = true,
    autoindent      = true,
    number          = true,
    expandtab       = true,
    shiftwidth      = 4,
    tabstop         = 4,
 -- termguicolors   = true,
    background      = 'dark',
}
apply_table(options, function(opt, val) vim.opt[opt] = val end)


-- Keymaps
local normal_keymaps = {
    ['<leader>nh']  = ':noh<CR>',
    ['<leader>tr']  = ':terminal<CR>',
    ['<leader>kt']  = ':split<CR>\z
                       :terminal<CR>',
    ['<leader>jt']  = ':belowright split<CR>\z
                       :terminal<CR>',
    ['<leader>ht']  = ':vsplit<CR>\z
                       :terminal<CR>',
    ['<leader>lt']  = ':botright vsplit <CR>\z
                       :terminal<CR>',
    ['<leader>T']   = ':belowright split<CR>\z
                       :terminal<CR>\z
                       :exe "resize " . (&lines * 1/6)<CR>\z
                       :set winfixheight<CR>',
    ['<leader>wfh'] = cmd_toggle_setting('winfixheight'),
    ['<leader>wfw'] = cmd_toggle_setting('winfixwidth'),
    --
    ['<C-q>']       = '<Nop>',
    ['<C-q>h']      = ':tabp<CR>',
    ['<C-q>l']      = ':tabn<CR>',
    ['<C-q>n']      = ':tabnew<CR>',
    ['<C-q>x']      = ':tabclose<CR>',
    ['<CM-p>']      = '"+p',
}
for _, x in ipairs({'2', '3', '4', '5', '6', '8'}) do
    -- Maps <C-w>$n to resize the current split to be 1/$n the terminal height
    local v_key = string.format('<C-w>%s', x)
    local v_mapping = string.format(':exe "resize " . (&lines * 1/%s)<CR>', x)
    nmap(v_key, v_mapping)

    -- Maps <C-w>\$n to resize the current vsplit to be 1/$n the terminal width
    local h_key = string.format('<C-w>\\%s', x)
    local h_mapping = string.format(':exe "vertical resize " . ' ..
                                    '(&columns * 1/%s)<CR>', x)
    nmap(h_key, h_mapping)
end
apply_table(normal_keymaps, function(k, v) with_opts(nmap, k, v) end)

local terminal_keymaps = {
    ['<Esc>']   = {'<C-\\><C-n>', { noremap = false }},
    ['<C-]>']   = '<C-[>',  -- (Ctrl + [ sends Escape signal)
    ['<C-w>']   = {'<C-\\><C-n>', { noremap = false }},
    ['<CM-w>']  = '<C-w>',
    ['<C-q>h']  = {'<C-\\><C-n>:tabp<CR>', { noremap = false }},
    ['<C-q>l']  = {'<C-\\><C-n>:tabn<CR>', { noremap = false }},
    ['<C-q>n']  = {'<C-\\><C-n>:tabnew<CR>', { noremap = false }},
    ['<C-q>x']  = {'<C-\\><C-n>:tabclose<CR>', { noremap = false }},
    ['<CM-q>']  = '<C-q>',
}
apply_table(terminal_keymaps, function(k, v) with_opts(tmap, k, v) end)

local insert_keymaps = {
    ['<C-q>h']  = '<Esc>:tabp<CR>',
    ['<C-q>l']  = '<Esc>:tabn<CR>',
    ['<C-q>n']  = '<Esc>:tabnew<CR>',
    ['<C-q>x']  = '<Esc>:tabclose<CR>',
}
apply_table(insert_keymaps, function(k, v) with_opts(imap, k, v) end)

local visual_keymaps = {
    ['<CM-y>']  = '"+y',
    ['<CM-p>']  = '"+p',
}
apply_table(visual_keymaps, function(k, v) with_opts(vmap, k, v) end)


-- Custom Commands
vimcmd('ReloadConfig', 'source $MYVIMRC', 0, 'Reload Neovim config')


-- Autocommands
autocmd('TermOpen', '*', 'setlocal nonu nornu')
autocmd({'BufRead', 'BufNewFile'}, '*.qrc', 'set ft=xml')

local plaintext_filetypes = 'text,markdown,tex,rst'
local plaintext_autocmds = {
    {'FileType', plaintext_filetypes, 'setlocal wrap linebreak nolist'}
}

-- When in a plaintext buffer, make commands for navigating lines respect
-- word wrap by default. Normally, this is done by prefixing the movement
-- command with 'g'; these autocommands make it the default behavior, as well
-- as allowing default-style navigation when prefixing the command with 'g'
local line_commands = {'j', 'k', '$', '%', '^', '0'}
for _, ch in ipairs(line_commands) do
    local function cmd(command)
        return {'FileType', plaintext_filetypes, command}
    end
    table.insert(plaintext_autocmds,
                 cmd('nnoremap <buffer> ' .. ch .. ' g' .. ch))
    table.insert(plaintext_autocmds,
                 cmd('nnoremap <buffer> g' .. ch .. ' ' .. ch))
    table.insert(plaintext_autocmds,
                 cmd('vnoremap <buffer> ' .. ch .. ' g' .. ch))
    table.insert(plaintext_autocmds,
                 cmd('vnoremap <buffer> g' .. ch .. ' ' .. ch))
end
augroup('plaintext', true, plaintext_autocmds)
