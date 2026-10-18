-- Lua 5.1 cannot yield across pcall, so a suspension point (a coroutine suspending, or `yield` in a
-- sequence builder) inside try/catch runs the protected function in its own coroutine and passes
-- each yield on to the enclosing coroutine, resuming the function with whatever comes back.
local function __K2L_CoPcall(f)
    local co = coroutine.create(f)
    local function step(ok, ...)
        if not ok then
            return false, ...
        elseif coroutine.status(co) == "dead" then
            return true, ...
        end
        return step(coroutine.resume(co, coroutine.yield(...)))
    end
    return step(coroutine.resume(co))
end
