-- requires: Exceptions, InstanceOf, Jump
-- A caught Lua error as a Kotlin exception: Lua runtime errors become RuntimeExceptions, an overflow of the Lua or the C
-- stack a StackOverflowError (an Error, which `catch (e: Exception)` lets through).
-- A non-local jump out of a lambda (see Jump.lua) is not an exception: it is raised again.
local function __K2L_ToThrowable(err)
    if __K2L_IsJump(err) then
        error(err, 0)
    end
    if __K2L_InstanceOf(err, __K2L_Throwable) then
        return err
    end
    if type(err) == "string" and err:find("stack overflow$") then
        return __K2L_StackOverflowError.new()
    end
    return __K2L_RuntimeException.new(tostring(err))
end
