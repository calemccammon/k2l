-- requires: Class, Exceptions
-- list.listIterator() and list.listIterator(index): a cursor over the list's elements that can also step back, and
-- remove, set and add through the list's own removeAt, set and addAt.
local ListIterator = __K2L_Class("kotlin.collections.ListIterator")

function ListIterator:____init(list, cursor)
    self.list, self.cursor, self.lastReturned = list, cursor, -1
end

function ListIterator:hasNext()
    return self.cursor < self.list.size
end

function ListIterator:next()
    local i = self.cursor
    if i >= self.list.size then
        error(__K2L_NoSuchElementException.new())
    end
    self.cursor, self.lastReturned = i + 1, i
    return self.list[i + 1]
end

function ListIterator:hasPrevious()
    return self.cursor > 0
end

function ListIterator:previous()
    local i = self.cursor - 1
    if i < 0 then
        error(__K2L_NoSuchElementException.new())
    end
    self.cursor, self.lastReturned = i, i
    return self.list[i + 1]
end

function ListIterator:nextIndex()
    return self.cursor
end

function ListIterator:previousIndex()
    return self.cursor - 1
end

function ListIterator:remove()
    if self.lastReturned < 0 then
        error(__K2L_IllegalStateException.new())
    end
    self.list:removeAt(self.lastReturned)
    self.cursor, self.lastReturned = self.lastReturned, -1
end

function ListIterator:set(value)
    if self.lastReturned < 0 then
        error(__K2L_IllegalStateException.new())
    end
    self.list:set(self.lastReturned, value)
end

function ListIterator:add(value)
    self.list:addAt(self.cursor, value)
    self.cursor, self.lastReturned = self.cursor + 1, -1
end

local function __K2L_ListIterator(list, index)
    index = index or 0
    if index < 0 or index > list.size then
        error(__K2L_IndexOutOfBoundsException.new("Index: " .. index .. ", Size: " .. list.size))
    end
    return ListIterator.new(list, index)
end
