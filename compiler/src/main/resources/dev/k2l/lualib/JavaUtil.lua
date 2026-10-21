-- requires: Class, Str, Exceptions
-- java.util.Stack (a list with push/pop/peek/empty/search), java.util.StringJoiner, and statics of java.util.Objects and
-- java.lang.Boolean and Character.
local __K2L_StringJoiner = __K2L_Class("java.util.StringJoiner")
local __K2L_JavaUtil = {}

------------------------------------------------------------------ Stack

function __K2L_JavaUtil.push(stack, item)
    stack:add(item)
    return item
end

function __K2L_JavaUtil.peek(stack)
    if stack.size == 0 then
        error(__K2L_EmptyStackException.new())
    end
    return stack:get(stack.size - 1)
end

function __K2L_JavaUtil.pop(stack)
    local item = __K2L_JavaUtil.peek(stack)
    stack:removeAt(stack.size - 1)
    return item
end

-- the 1-based distance from the top of the stack, -1 when absent
function __K2L_JavaUtil.search(stack, item)
    local i = stack:lastIndexOf(item)
    return i >= 0 and stack.size - i or -1
end

------------------------------------------------------------------ StringJoiner

function __K2L_StringJoiner:____init(delimiter, prefix, suffix)
    self.delimiter = __K2L_Str(delimiter)
    self.prefix = prefix ~= nil and __K2L_Str(prefix) or ""
    self.suffix = suffix ~= nil and __K2L_Str(suffix) or ""
    self.parts = {}
end

function __K2L_StringJoiner:add(part)
    self.parts[#self.parts + 1] = __K2L_Str(part)
    return self
end

function __K2L_StringJoiner:setEmptyValue(value)
    self.emptyValue = __K2L_Str(value)
    return self
end

-- adds the other joiner's parts, joined with its delimiter, as one part (when it has any)
function __K2L_StringJoiner:merge(other)
    if #other.parts > 0 then
        self:add(table.concat(other.parts, other.delimiter))
    end
    return self
end

function __K2L_StringJoiner:toString()
    if #self.parts == 0 and self.emptyValue ~= nil then
        return self.emptyValue
    end
    return self.prefix .. table.concat(self.parts, self.delimiter) .. self.suffix
end

function __K2L_StringJoiner:length()
    return #self:toString()
end

------------------------------------------------------------------ Objects, Boolean, Character

-- Objects.requireNonNull(value[, message or message supplier])
function __K2L_JavaUtil.requireNonNull(value, message)
    if value == nil then
        if type(message) == "table" and message.get ~= nil then
            message = message:get()
        elseif type(message) ~= "string" and message ~= nil then
            message = message()
        end
        error(__K2L_NullPointerException.new(message))
    end
    return value
end

function __K2L_JavaUtil.requireNonNullElse(value, default)
    if value ~= nil then
        return value
    end
    return __K2L_JavaUtil.requireNonNull(default, "defaultObj")
end

function __K2L_JavaUtil.toStringOr(value, default)
    if value == nil then
        return default
    end
    return __K2L_Str(value)
end

function __K2L_JavaUtil.checkIndex(index, length)
    if index < 0 or index >= length then
        error(__K2L_IndexOutOfBoundsException.new("Index " .. index .. " out of bounds for length " .. length))
    end
    return index
end

-- Objects.compare(a, b, comparator): 0 for the same object, else the comparator's answer
function __K2L_JavaUtil.compare(a, b, comparator)
    if rawequal(a, b) then
        return 0
    end
    if type(comparator) == "table" and comparator.compare ~= nil then
        return comparator:compare(a, b)
    end
    return comparator(a, b)
end

-- Boolean's non-short-circuit and, or (the operands are evaluated as arguments) and Boolean.compare
function __K2L_JavaUtil.logicalAnd(a, b)
    return a and b
end

function __K2L_JavaUtil.logicalOr(a, b)
    return a or b
end

function __K2L_JavaUtil.compareBooleans(a, b)
    if a == b then
        return 0
    end
    return a and 1 or -1
end

-- Character.forDigit(digit, radix): the code of the lowercase digit, 0 when there is none
function __K2L_JavaUtil.forDigit(digit, radix)
    if radix < 2 or radix > 36 or digit < 0 or digit >= radix then
        return 0
    end
    return digit < 10 and 48 + digit or 87 + digit
end
