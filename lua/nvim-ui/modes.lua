vim.api.nvim_create_user_command('MoveTopRight', function()
    vim.cmd('wincmd l | wincmd k')
    vim.cmd('stopinsert') -- h v
    vim.cmd([[normal! <C-[>]])
    vim.cmd('wincmd l')
end, {})

vim.api.nvim_create_user_command('ModeIDE', function()
    vim.cmd('NvimTreeToggle')
    vim.cmd('TermOpen horizontal')
    vim.cmd('MoveTopRight')
    vim.cmd('MoveTopRight')
end, {})

vim.api.nvim_create_user_command('ModePython', function()
    vim.cmd('ModeIDE')
    vim.cmd('wincmd j')
    vim.cmd('TermOpen horizontal cmd=ipython name=REPL-Python')
    vim.cmd('MoveTopRight')
end, {})

vim.api.nvim_create_user_command('ModeHaskell', function()
    vim.cmd('ModeIDE')
    vim.cmd('wincmd j')
    vim.cmd('TermOpen horizontal cmd=ghci name=REPL-Haskell')
    vim.cmd('TermOpen vertical cmd=ghcid')
    vim.cmd('MoveTopRight')
end, {})

vim.api.nvim_create_user_command('ModeR', function()
    vim.cmd('ModeIDE')
    vim.cmd('wincmd j')
    vim.cmd('TermOpen horizontal cmd=radian name=REPL-R')
    vim.cmd('MoveTopRight')
end, {})

vim.api.nvim_create_user_command('ModeC', function()
    vim.cmd('ModeIDE')
end, {})
