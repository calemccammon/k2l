-- Lua 5.1 cannot yield across pcall, and LuaJIT nests protected calls deeply: a plain pcall (see DeepPcall.lua). On 5.1 a
-- coroutine.resume counts as a nested C call too (the coroutine starts from its resumer's count), so running the call in
-- a coroutine would fail at the same depth, and a yield to a driver cannot cross the C calls in between (the README's
-- "Other semantic differences" has the details).
local __K2L_DeepPcall = pcall

local function __K2L_DeepMain(main, ...)
    return main(...)
end
