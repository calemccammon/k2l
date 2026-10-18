-- requires: Class, Str, Equals, Hash, ToThrowable, CoPcall
-- kotlin.Result: `value` on success, `exception` on failure.
local __K2L_Result = __K2L_Class("kotlin.Result")

function __K2L_Result.success(value)
    return setmetatable({value = value}, __K2L_Result)
end

function __K2L_Result.failure(exception)
    return setmetatable({exception = exception}, __K2L_Result)
end

function __K2L_Result:isSuccess()
    return self.exception == nil
end

function __K2L_Result:isFailure()
    return self.exception ~= nil
end

function __K2L_Result:getOrNull()
    if self.exception == nil then
        return self.value
    end
    return nil
end

function __K2L_Result:exceptionOrNull()
    return self.exception
end

function __K2L_Result:getOrThrow()
    if self.exception ~= nil then
        error(self.exception, 0)
    end
    return self.value
end

function __K2L_Result:getOrDefault(defaultValue)
    if self.exception ~= nil then
        return defaultValue
    end
    return self.value
end

function __K2L_Result:getOrElse(onFailure)
    if self.exception ~= nil then
        return onFailure(self.exception)
    end
    return self.value
end

function __K2L_Result:fold(onSuccess, onFailure)
    if self.exception ~= nil then
        return onFailure(self.exception)
    end
    return onSuccess(self.value)
end

function __K2L_Result:onSuccess(action)
    if self.exception == nil then
        action(self.value)
    end
    return self
end

function __K2L_Result:onFailure(action)
    if self.exception ~= nil then
        action(self.exception)
    end
    return self
end

function __K2L_Result:map(transform)
    if self.exception ~= nil then
        return self
    end
    return __K2L_Result.success(transform(self.value))
end

function __K2L_Result:recover(transform)
    if self.exception == nil then
        return self
    end
    return __K2L_Result.success(transform(self.exception))
end

-- runCatching { } and receiver.runCatching { }: every Lua error becomes a failure.
local function __K2L_RunCatching(block, receiver)
    local ok, value = __K2L_CoPcall(function() return block(receiver) end)
    if ok then
        return __K2L_Result.success(value)
    end
    return __K2L_Result.failure(__K2L_ToThrowable(value))
end

function __K2L_Result:mapCatching(transform)
    if self.exception ~= nil then
        return self
    end
    return __K2L_RunCatching(transform, self.value)
end

function __K2L_Result:recoverCatching(transform)
    if self.exception == nil then
        return self
    end
    return __K2L_RunCatching(transform, self.exception)
end

function __K2L_Result:toString()
    if self.exception ~= nil then
        return "Failure(" .. __K2L_Str(self.exception) .. ")"
    end
    return "Success(" .. __K2L_Str(self.value) .. ")"
end

function __K2L_Result:equals(other)
    return getmetatable(other) == __K2L_Result and __K2L_Equals(self.value, other.value) and
        __K2L_Equals(self.exception, other.exception)
end

function __K2L_Result:hashCode()
    return __K2L_Hash(self.exception or self.value)
end
