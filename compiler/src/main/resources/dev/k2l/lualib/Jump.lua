-- A non-local `return`, `break` or `continue` out of a lambda that stays a Lua function (one passed to an inline
-- library function k2l does not expand): the lambda raises the token of the call it was passed to, after storing which
-- jump to make and the returned value in it, and the call, run in a pcall, makes the jump. Every runtime function that
-- catches errors (__K2L_ToThrowable) raises a token again, so catch blocks and runCatching do not see it.
local JumpToken = {}

local function __K2L_NewJump()
    return setmetatable({}, JumpToken)
end

local function __K2L_Jump(token, code, value)
    token.code = code
    token.value = value
    error(token, 0)
end

local function __K2L_IsJump(err)
    return getmetatable(err) == JumpToken
end
