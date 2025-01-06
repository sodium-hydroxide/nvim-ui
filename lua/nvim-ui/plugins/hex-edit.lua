
return {
    "RaafatTurki/hex.nvim",
    event = "BufReadPost",
    config = function()
        require("hex").setup({
            -- hex.nvim defaults:
            -- ascii_group = "Normal",
            -- hex_group = "Normal",
            -- dump_cmd = "xxd -g 1 -u",
            -- restore_cmd = "xxd -r",
        })
    end,
    -- Make sure xxd is available
    dependencies = {},
}
