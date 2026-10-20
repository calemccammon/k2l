-- requires: Exceptions
-- An index out of range of a list, array or string that generated code reads or writes in place (`a[i + 1]`,
-- `s:sub(i + 1, i + 1)`, with the check inline): throws what `__K2L_List:get` throws, or for `kind` "array"
-- `__K2L_Array:get`, for "string" `__K2L_StringCharAt`. An index in range reads a null element (an unfilled
-- `arrayOfNulls<T>(n) as Array<T>`): it returns nil, as the read does on the JVM.
local function __K2L_IndexError(index, size, kind)
    if index >= 0 and index < size then
        return nil
    end
    local cls = __K2L_IndexOutOfBoundsException
    if kind == "array" then
        cls = __K2L_ArrayIndexOutOfBoundsException
    elseif kind == "string" then
        cls = __K2L_StringIndexOutOfBoundsException
    end
    error(cls.new("Index " .. index .. " out of bounds for length " .. size))
end
