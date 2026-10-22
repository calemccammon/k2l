-- requires: Exceptions, InstanceOf, ToThrowable, ListWrap
-- Throwable.suppressedExceptions (a copy), and the close() of `use` after its block failed with `cause`:
-- an error of close() is added to the suppressed exceptions of the block's exception.
local function __K2L_Suppressed(e)
    local suppressed, copy = rawget(e, "____suppressed") or {}, {}
    for i = 1, #suppressed do
        copy[i] = suppressed[i]
    end
    return __K2L_ListWrap(copy, #copy)
end

local function __K2L_CloseAfter(resource, cause)
    local ok, e = pcall(resource.close, resource)
    if not ok and __K2L_InstanceOf(cause, __K2L_Throwable) then
        cause:addSuppressed(__K2L_ToThrowable(e))
    end
end
