-- Lua 5.1 cannot yield across pcall, and LuaJIT nests protected calls deeply: a plain pcall (see DeepPcall.lua).
local __K2L_DeepPcall = pcall

local function __K2L_DeepMain(main, ...)
    return main(...)
end
