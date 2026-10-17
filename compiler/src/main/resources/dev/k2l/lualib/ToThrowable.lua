-- requires: Exceptions, InstanceOf
-- A caught Lua error as a Kotlin exception: Lua runtime errors become RuntimeExceptions.
local function __K2L_ToThrowable(err)
    if __K2L_InstanceOf(err, __K2L_Throwable) then
        return err
    end
    return __K2L_RuntimeException.new(tostring(err))
end
