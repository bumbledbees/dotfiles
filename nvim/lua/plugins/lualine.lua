local function size_lock()
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
        -- return ' : ' .. indicator
        return ' : ' .. indicator
    end
end
return {
{
    'nvim-lualine/lualine.nvim',
    opts = {
        options = {
            icons_enabled = false,
            component_separators = { left = '|', right = '|'},
            section_separators = { left = '', right = ''},

        },
        sections = {
            lualine_a = {'mode'},
            lualine_b = {'filename'},
            lualine_c = {'diagnostics'},
            lualine_x = {
                size_lock,
                "fileformat",
                "encoding",
                "filetype"
            },
            lualine_y = {'progress'},
            lualine_z = {'location'}
        },
        inactive_sections = {
            lualine_x = {'progress'},
            lualine_y = {'location'}
        }
    }
}
}
