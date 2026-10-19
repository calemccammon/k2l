-- requires: Exceptions, InstanceOf, Jump
-- A caught Lua error as a Kotlin exception: Lua runtime errors become RuntimeExceptions.
-- A non-local jump out of a lambda (see Jump.lua) is not an exception: it is raised again.
local function __K2L_ToThrowable(err)
    if __K2L_IsJump(err) then
        error(err, 0)
    end
    if __K2L_InstanceOf(err, __K2L_Throwable) then
        return err
    end
    return __K2L_RuntimeException.new(tostring(err))
end
