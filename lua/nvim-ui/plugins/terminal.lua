return {
    'akinsho/toggleterm.nvim',
    version = "*",
    opts = {
        size = function(term)
            if term.direction == "horizontal" then
                return math.floor(vim.o.lines * 0.3)
            elseif term.direction == "vertical" then
                return math.floor(vim.o.columns * 0.8)
            end
            return 20
        end,
        open_mapping = [[<c-\>]],
        shade_terminals = true,
        start_in_insert = true,
        direction = 'float',
        float_opts = {
            border = "curved",
            width = math.floor(vim.o.columns * 0.85),
            height = math.floor(vim.o.lines * 0.85),
        },
    },
    config = function()
        local toggleterm = require('toggleterm')
        local Terminal = require('toggleterm.terminal').Terminal

        -- Store active terminals
        local active_terminals = {}

        -- Function to parse command arguments
        local function parse_args(args_str)
            local parts = vim.split(args_str, ' ')
            local result = {
                direction = parts[1] or 'float'
            }

            local i = 2
            while i <= #parts do
                local part = parts[i]
                local key, value = part:match("(%w+)=(.+)")
                if key then
                    result[key] = value
                end
                i = i + 1
            end

            return result
        end

        -- Function to get or create terminal
        local function get_or_create_terminal(cmd, dir, direction, name)
            local key = name or string.format(
                "%s:%s:%s",
                cmd or "shell",
                dir or vim.fn.getcwd(),
                direction or "float"
            )

            if not active_terminals[key] then
                active_terminals[key] = Terminal:new({
                    cmd = cmd,
                    dir = dir,
                    direction = direction,
                    close_on_exit = false,
                    name = name,
                })
            end

            return active_terminals[key]
        end

        -- Predefined terminals with custom names
        local terminals = {
            ipython = {
                cmd = "ipython",
                direction = "float",
                name = "IPython-REPL",
            },
            radian = {
                cmd = "radian",
                direction = "float",
                name = "R-REPL",
            },
        }

        -- Create predefined terminals
        for name, config in pairs(terminals) do
            active_terminals[name] = Terminal:new(config)
        end

        -- Register commands with flag support
        vim.api.nvim_create_user_command('TermOpen', function(opts)
            local args = parse_args(opts.args)
            local term = get_or_create_terminal(
                args.cmd,
                args.dir or vim.fn.getcwd(),
                args.direction,
                args.name
            )
            term:open()
        end, {
            nargs = '*',
            complete = function(_, line, _)
                local words = vim.split(line, ' ')
                if #words <= 2 then
                    return {'horizontal', 'vertical', 'float'}
                end
                -- Provide completion for flags
                return {
                    'cmd=',
                    'dir=',
                    'name='
                }
            end
        })

        vim.api.nvim_create_user_command('TermToggle', function(opts)
            local args = parse_args(opts.args)
            local term = get_or_create_terminal(
                args.cmd,
                args.dir or vim.fn.getcwd(),
                args.direction,
                args.name
            )
            term:toggle()
        end, {
            nargs = '*',
            complete = function(_, line, _)
                local words = vim.split(line, ' ')
                if #words <= 2 then
                    return {'horizontal', 'vertical', 'float'}
                end
                -- Provide completion for flags
                return {
                    'cmd=',
                    'dir=',
                    'name='
                }
            end
        })
        -- Register predefined terminal commands
        for name, _ in pairs(terminals) do
            vim.api.nvim_create_user_command(
                'Term' .. name:gsub("^%l", string.upper),
                function()
                    active_terminals[name]:toggle()
                end,
                {}
            )
        end

        -- Keymaps
        local mappings = {
            ['<leader>tf'] = 'float',       -- toggle float term
            ['<leader>tv'] = 'vertical',    -- toggle vertical term
            ['<leader>th'] = 'horizontal'   -- toggle horizontal term
        }

        -- Implement the mappings
        for keymap, direction in pairs(mappings) do
            vim.keymap.set('n', keymap, function()
                local term = get_or_create_terminal(nil, nil, direction)
                term:toggle()
            end, { desc = 'Toggle ' .. direction .. ' terminal' })
        end

        -- Terminal navigation
        vim.api.nvim_create_autocmd("TermOpen", {
            pattern = "term://*",
            callback = function()
                local opts = {buffer = 0}
                local term_maps = {
                    ['<esc><esc>'] = [[<C-\><C-n>]],  -- Double ESC to go to normal mode
                    ['<C-h>'] = [[<Cmd>wincmd h<CR>]], -- Move to left window
                    ['<C-j>'] = [[<Cmd>wincmd j<CR>]], -- Move to bottom window
                    ['<C-k>'] = [[<Cmd>wincmd k<CR>]], -- Move to top window
                    ['<C-l>'] = [[<Cmd>wincmd l<CR>]], -- Move to right window
                }
                for k, v in pairs(term_maps) do
                    vim.keymap.set('t', k, v, opts)
                end
            end,
        })

        -- Add normal mode terminal navigation
        local normal_maps = {
            ['<C-h>'] = [[<C-w>h]],
            ['<C-j>'] = [[<C-w>j]],
            ['<C-k>'] = [[<C-w>k]],
            ['<C-l>'] = [[<C-w>l]],
        }
        for k, v in pairs(normal_maps) do
            vim.keymap.set('n', k, v, { silent = true })
        end
    end
}

