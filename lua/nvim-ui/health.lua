-- health.lua
local M = {}

-- Override the which-key health checks
vim.health = vim.health or {}
local health = vim.health

-- Store the original which-key health check
local original_which_key_health = require("which-key.health").check

-- Create a wrapper function that filters out specific warnings
function M.check()
    -- Temporarily redirect health messages
    local original_report = {
        start = health.start,
        ok = health.ok,
        warn = health.warn,
        error = health.error,
        info = health.info
    }

    local filtered_messages = {}
    health.warn = function(msg)
        -- Filter out specific warning messages
        if not msg:match("old version of the which%-key spec") and
           not msg:match("mini.icons") then
            original_report.warn(msg)
        end
    end

    -- Run the original health check
    original_which_key_health()

    -- Restore original health reporting functions
    health.start = original_report.start
    health.ok = original_report.ok
    health.warn = original_report.warn
    health.error = original_report.error
    health.info = original_report.info
end

return M
