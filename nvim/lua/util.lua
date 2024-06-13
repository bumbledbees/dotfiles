function apply_table(table, func)
    for key, value in pairs(table) do
        func(key, value)
    end
end

function with_opts(func, lhs, rhs)
    if type(rhs) == 'table' then
        func(lhs, unpack(rhs))
    else
        func(lhs, rhs)
    end
end

function cmd_toggle_setting(setting)
    return (':if &' .. setting .. ' | set no' .. setting .. ' | else | set ' ..
            setting .. ' | endif<CR>')
end

function keymap(mode, lhs, rhs, opts)
    local options = { noremap = true, silent = true }
    if opts then
        options = vim.tbl_extend('force', options, opts)
    end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end
function nmap(lhs, rhs, opts) keymap('n', lhs, rhs, opts) end
function tmap(lhs, rhs, opts) keymap('t', lhs, rhs, opts) end
function imap(lhs, rhs, opts) keymap('i', lhs, rhs, opts) end
function vmap(lhs, rhs, opts) keymap('v', lhs, rhs, opts) end

function keyunmap(mode, lhs)
    vim.api.nvim_del_keymap(mode, lhs)
end

function augroup(name, clear, cmds)
    vim.api.nvim_create_augroup(name, { clear = clear })
    for _, cmd in ipairs(cmds) do
        triggers, patterns, vim_cmd, callback = unpack(cmd)
        autocmd(triggers, patterns, vim_cmd, callback, name)
    end
end

function autocmd(triggers, patterns, vim_cmd, callback, group)
    vim.api.nvim_create_autocmd(
        triggers,
        { pattern = patterns,
          command = vim_cmd,
          callback = callback,
          group = group }
    )
end

function vimcmd(name, action, nargs, desc)
    vim.api.nvim_create_user_command(
        name,
        action,
        { nargs = nargs,
          desc = desc }
    )
end
