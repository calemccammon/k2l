-- A hand-written Lua module the Kotlin code binds to.
local M = {}

M.VERSION = "1.2"

function M.greet(name)
    return "hi " .. name
end

function M.divmod(a, b)
    return a // b, a % b
end

function M.each(items, f)
    for _, item in ipairs(items) do
        f(item)
    end
end

function M.makeCounter(start)
    local counter = {count = start}
    function counter:increment(by)
        self.count = self.count + by
    end
    function counter.describe(c)
        return "counter at " .. c.count
    end
    return counter
end

return M
