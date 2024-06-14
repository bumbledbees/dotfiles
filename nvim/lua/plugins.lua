require('util')


-- ==== Lightline ====
function window_size_lock_indicator()
    local indicators = {' ', ' '}
    if vim.o.winfixwidth then
        indicators[1] = 'w'
    end
    if vim.o.winfixheight then
        indicators[2] = 'h'
    end

    local indicator = table.concat(indicators)
    if indicator == '  ' then
        return ''
    else
        return ' : ' .. indicator
    end
end

vim.g.lightline = {
    active = {
        left = {
            {'mode', 'paste'},
            {'readonly', 'filename', 'modified'},
        },
        right = {
            {'lineinfo'},
            {'percent'},
            {'size_lock', 'fileformat', 'fileencoding', 'filetype'}
        }
    },
    component_function = {
        size_lock = 'v:lua.window_size_lock_indicator'
    }
}


-- ==== Neotree ====
neotree_config = {
    close_if_last_window = true,
    enable_git_status = true,
    enable_diagnostics = true,
    open_files_do_not_replace_types = {'terminal', 'qf'},
    sort_case_insensitive = false,
    
    commands = {},
    default_component_configs = {
        container = {enable_character_fade = false},
        indent = {
            indent_size = 2,
            padding = 1,
            -- indent guide settings
            with_markers = true,
            indent_marker = '│',
            last_indent_marker = '└',
            highlight = 'NeoTreeIndentMarker',
            -- expander settings
            with_expanders = true,
            expander_collapsed = '',
            expander_expanded = '',
            expander_highlight = 'NeoTreeExpander',
        },
        icon = {
            folder_closed = '',
            folder_open = '',
            folder_empty = '󰜌',
            default = '*',
            highlight = 'NeoTreeFileIcon',
        },
        modified = {symbol = '', highlight = 'NeoTreeModified'},
        name = {
            highlight = 'NeoTreeFileName',
            trailing_slash = false,
            use_git_status_colors = true
        },
        git_status = {
            symbols = {
                -- change type
                added = '',
                modified = '',
                deleted = '✖',
                renamed = '󰁕',
                -- status type
                conflict = '',
                ignored = '',
                unstaged = '󰄱',
                staged = '',
                untracked = ''
            }
        },
        -- UI columns
        file_size = {enabled = true, required_width = 64},
        type = {enabled = true, required_width = 122},
        last_modified = {enabled = true, required_width = 88},
        created = {enabled = true, required_width = 110},
        symlink_target = {enabled = false},
    },
    event_handlers = {
        { event = 'neo_tree_window_after_open',
          handler = function(_) vim.opt_local.number = false end }
    },
    filesystem = {
        filtered_items = {
            hide_dotfiles = true,
            hide_gitignored = false,
            hide_hidden = true,
            hide_by_pattern = {'*.egg-info', '*.egg'},
            hide_by_name = {'build', 'dist', 'dist-newstyle', 'node_modules'},
            always_show = {'.gitignore'},
            never_show = {'__pycache__'},
        },
        follow_current_file = {enabled = false},
        group_empty_dirs = false,
        hijack_netrw_behavior = 'open_default',
        use_libuv_file_watcher = true,
    },
    source_selector = {
        -- statusline = true
        winbar = true
    },
    window = {
        position = 'left',
        width = 32,
        mapping_options = {
            noremap = true,
            nowait = true
        },
        mappings = {
            ['<Esc>'] = 'cancel',
            ['q'] = 'close_window',  -- close the window containing neo-tree
            ['R'] = 'refresh',
            ['H'] = 'toggle_hidden',

            -- Navigation (:help neo-tree-navigation)
            ['z'] = 'close_all_nodes',
            -- [] = 'close_all_subnodes',
            ['.'] = 'close_node',
            -- [] = 'expand_all_nodes',
            ['u'] = 'navigate_up',  -- change directory to the parent directory
            ['o'] = 'open',    -- expand/collapse directory or nested file, or
            ['<CR>'] = 'open', -- open regular file in editor
            ['<2-LeftMouse>'] = 'open',  -- 2-LeftMouse = double-click
            ['s'] = 'open_split',
            ['t'] = 'open_tabnew',
            ['S'] = 'open_vsplit',
            ['w'] = 'open_with_window_picker',
            -- [] = 'split_with_window_picker',
            -- [] = 'vsplit_with_window_picker',
            ['C'] = 'set_root',  -- change directory to the selected directory
            ['<Space>'] = {'toggle_node',    -- expand/collapse a directory or
                           nowait = false},  -- nested file

            -- Source Navigation
            ['<'] = 'prev_source',
            ['>'] = 'next_source',

            -- Preview Mode Navigation (:help neo-tree-preview-mode)
            ['P'] = 'toggle_preview',
            ['l'] = 'focus_preview',
            ['<C-p>'] = {'scroll_preview', config = {direction = -10}},
            ['<C-n>'] = {'scroll_preview', config = {direction = 10}},
            ['<Esc>'] = 'revert_preview',

            -- File Actions (:help neo-tree-file-actions)
            ['n'] = 'add',  -- create a new file or directory
            ['N'] = 'add_directory',  -- create a new directory
            ['c'] = 'copy',  -- make a new copy of a file
            ['y'] = 'copy_to_clipboard',  -- mark file as "to be copied"
            ['x'] = 'cut_to_clipboard',  -- mark file as "to be moved"
            ['d'] = 'delete',
            ['m'] = 'move',
            ['p'] = 'paste_from_clipboard',  -- copy/move marked files
            ['r'] = 'rename',
            ['i'] = 'show_file_details',

            -- Fuzzy Finder (:help neo-tree-filter)
            ['<C-x>'] = 'clear_filter',
            ['f'] = 'filter_on_submit',
            ['/'] = 'fuzzy_finder',
            ['D'] = 'fuzzy_finder_directory',
            ['#'] = 'fuzzy_sorter',

            -- Sorting (:help neo-tree-view-changes)
            ['O'] = {'show_help', nowait = false,
                     config = {title = 'Order by', prefix_key = 'O'}},
            ['Oc'] = {'order_by_created', nowait = false},
            ['Od'] = {'order_by_diagnostics', nowait = false},
            ['Og'] = {'order_by_git_status', nowait = false},
            ['Om'] = {'order_by_modified', nowait = false},
            ['On'] = {'order_by_name', nowait = false},
            ['Os'] = {'order_by_size', nowait = false},
            ['Ot'] = {'order_by_type', nowait = false},

            -- Git Navigation
            ['[g'] = 'prev_git_modified',
            [']g'] = 'next_git_modified'
        },
        fuzzy_finder_mappings = {
            ['<C-p>'] = 'move_cursor_up',
            ['<C-n>'] = 'move_cursor_down'
        }
    }
}

function neotree_setup()
    nmap('<leader>\\', ':Neotree<CR>')
    nmap('<leader>nt', ':Neotree<CR>')
    nmap('<leader>cfg',
         ':tabnew<CR>:Neotree dir=' .. vim.fn.stdpath('config') .. '<CR>')
    augroup('neo-tree', true, {{'VimEnter', '*', 'Neotree action=show'}})
    require('neo-tree').setup(neotree_config)
end


-- ==== Python ====
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


-- ==== Theme ====
local colorscheme = 'gruvbox'
local status_ok, _ = pcall(vim.cmd, 'colorscheme ' .. colorscheme)
if status_ok then
    vim.g.lightline.colorscheme = 'gruvbox'
end


-- ==== Load Packages ====
function packages(use)
    use('wbthomason/packer.nvim')
    -- UI
    use({'nvim-neo-tree/neo-tree.nvim',
         branch = 'v3.x',
         requires = {'nvim-lua/plenary.nvim',
                     'nvim-tree/nvim-web-devicons',
                     'MunifTanjim/nui.nvim'},
         config = neotree_setup})
    use('gruvbox-community/gruvbox')
    use('itchyny/lightline.vim')
    -- Git
    use('tpope/vim-fugitive')
    use('airblade/vim-gitgutter')
    use({'lewis6991/gitsigns.nvim',
         config = function() require('gitsigns').setup() end})
    -- Language Support
    use('udalov/kotlin-vim')
    use('vim-python/python-syntax')
end

local packer_status, packer = pcall(require, 'packer')
if not packer_status then
    vim.notify('Could not load plugins (packer.nvim not installed)')
else
    return packer.startup(packages)
end
