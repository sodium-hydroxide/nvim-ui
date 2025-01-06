
return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    config = function()
        local colors = {
            bg       = '#202328',
            fg       = '#bbc2cf',
            yellow   = '#ECBE7B',
            cyan     = '#008080',
            darkblue = '#081633',
            green    = '#98be65',
            orange   = '#FF8800',
            violet   = '#a9a1e1',
            magenta  = '#c678dd',
            blue     = '#51afef',
            red      = '#ec5f67'
        }

        local conditions = {
            buffer_not_empty = function()
                return vim.fn.empty(vim.fn.expand('%:t')) ~= 1
            end,
            hide_in_width = function()
                return vim.fn.winwidth(0) > 80
            end
        }

        local config = {
            options = {
                component_separators = '',
                section_separators = '',
                theme = {
                    normal = {
                        a = { fg = colors.fg, bg = colors.bg },
                        b = { fg = colors.fg, bg = colors.bg },
                        c = { fg = colors.fg, bg = colors.bg },
                        z = { fg = colors.fg, bg = colors.bg },
                    },
                    inactive = {
                        a = { fg = colors.fg, bg = colors.bg },
                        b = { fg = colors.fg, bg = colors.bg },
                        c = { fg = colors.fg, bg = colors.bg },
                    },
                }
            },
            sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        'filename',
                        cond = conditions.buffer_not_empty,
                        color = { fg = colors.magenta, gui = 'bold' },
                    },
                    {
                        'filesize',
                        cond = conditions.buffer_not_empty,
                    },
                    {
                        'location'
                    },
                    {
                        'progress',
                        color = { fg = colors.fg, gui = 'bold' },
                    },
                    {
                        'diagnostics',
                        sources = { 'nvim_diagnostic' },
                        symbols = { error = ' ', warn = ' ', info = ' ' },
                        diagnostics_color = {
                            color_error = { fg = colors.red },
                            color_warn = { fg = colors.yellow },
                            color_info = { fg = colors.cyan },
                        },
                    },
                },
                lualine_x = {
                    {
                        'branch',
                        icon = '',
                        color = { fg = colors.violet, gui = 'bold' },
                    },
                    {
                        'diff',
                        symbols = { added = ' ', modified = '柳', removed = ' ' },
                        diff_color = {
                            added = { fg = colors.green },
                            modified = { fg = colors.orange },
                            removed = { fg = colors.red },
                        },
                        cond = conditions.hide_in_width,
                    },
                },
                lualine_y = {
                    {
                        'filetype',
                        colored = true,
                        icon_only = true,
                    },
                },
                lualine_z = {
                    {
                        function()
                            return ' ' .. os.date('%R')
                        end,
                        color = { fg = colors.blue, gui = 'bold' },
                    },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    {
                        'filename',
                        color = { fg = colors.fg, gui = 'bold' },
                    },
                },
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            extensions = { 'nvim-tree', 'toggleterm' },
        }

        require('lualine').setup(config)
    end
}

