-- Calls the Kotlin handler's function with `.`, as Lua code that knows nothing of self would.
local M = {}

function M.callTwice(handler, value)
    return handler.handle(value) .. "," .. handler.handle(value + 1)
end

return M
