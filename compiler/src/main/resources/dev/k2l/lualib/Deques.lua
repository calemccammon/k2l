-- requires: Class, Collections, Exceptions
-- kotlin.collections.ArrayDeque: a list (elements in the array part, `size`) whose removeFirst/removeLast, first and
-- last fail with the stdlib's message on an empty deque. addFirst/addLast and the rest are the list's.
local __K2L_ArrayDeque = __K2L_Class("kotlin.collections.ArrayDeque", __K2L_List)

do

local function emptyDeque(self)
    if self.size == 0 then
        error(__K2L_NoSuchElementException.new("ArrayDeque is empty."))
    end
end

-- ArrayDeque(), ArrayDeque(initialCapacity) or ArrayDeque(elements)
function __K2L_ArrayDeque:____init(elements)
    __K2L_List.____init(self, type(elements) == "table" and elements or nil)
end

function __K2L_ArrayDeque:removeFirst()
    emptyDeque(self)
    return __K2L_List.removeAt(self, 0)
end

function __K2L_ArrayDeque:removeLast()
    emptyDeque(self)
    return __K2L_List.removeAt(self, self.size - 1)
end

function __K2L_ArrayDeque:first(predicate)
    if predicate ~= nil then
        return __K2L_List.first(self, predicate)
    end
    emptyDeque(self)
    return self[1]
end

function __K2L_ArrayDeque:last(predicate)
    if predicate ~= nil then
        return __K2L_List.last(self, predicate)
    end
    emptyDeque(self)
    return self[self.size]
end

end
