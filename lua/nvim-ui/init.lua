local M = {}

function M.setup(opts)
    vim.g.mapleader = opts.leader or " "
    vim.g.maplocalleader = opts.localleader or "\\"
    vim.g.theme_choice = opts.theme or "github_light"
    vim.opt.termguicolors = true

    -- Core Options
    require('nvim-ui.options.ui')
    require('nvim-ui.options.whitespace')
    require('nvim-ui.options.diagnostics')
    require('nvim-ui.options.navigation')

    require('nvim-ui.modes')

    -- Plugin specifications for lazy.nvim-ui
    return {
        -- Core dependencies that multiple plugins might need
        { "nvim-tree/nvim-web-devicons" },
        { "nvim-lua/plenary.nvim" },

        -- Your configured plugins
        require('nvim-ui.plugins.theme'),
        require('nvim-ui.plugins.filetree'),
        require('nvim-ui.plugins.terminal'),
        require('nvim-ui.plugins.hex-edit'),
        {
            "kevinhwang91/nvim-ufo",
            dependencies = {
                "kevinhwang91/promise-async",
            },
            config = function()
                require('my-nvim-config.plugins.fold').config()
            end
        },
        {
            "nvim-lualine/lualine.nvim",
            dependencies = {
                "nvim-tree/nvim-web-devicons"
            },
            config = function()
                require('my-nvim-config.plugins.status').config()
            end
        },
        {
            "folke/which-key.nvim",
            config = function()
                require('my-nvim-config.plugins.keybindings').config()
            end
        },
        {
            'akinsho/bufferline.nvim',
            dependencies = {
                "nvim-tree/nvim-web-devicons"
            },
            config = function()
                require('my-nvim-config.plugins.buffers').config()
            end
        },
    }

end

return M

