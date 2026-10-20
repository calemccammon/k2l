-- requires: Class, Collections, Exceptions, IdentityHash, Equals
-- kotlin.collections.ArrayDeque, java.util.ArrayDeque and java.util.LinkedList: the ArrayList representation (elements in
-- the array part, `size`) with the JVM's classes, messages and internal calls. Like the JDK's, the convenience methods call
-- the public ones a subclass may override: an ArrayDeque's add, offer, addAll and its constructor call addLast, push calls
-- addFirst, removeFirst and pop call pollFirst; a LinkedList's offer calls add, addAll(elements) calls addAll(index,
-- elements), push calls addFirst and pop and remove() call removeFirst.
-- A java.util.ArrayDeque is not a List (`is List` is false, its equals is Object's): its class is a plain collection whose
-- missing members are ArrayList's. `is Queue` and `is Deque` test the interfaces below.
local __K2L_QueueInterface = __K2L_Class("java.util.Queue")
local __K2L_DequeInterface = __K2L_Class("java.util.Deque")
local __K2L_ArrayDeque = __K2L_Class("kotlin.collections.ArrayDeque", __K2L_List)
local __K2L_Deque = __K2L_Class("java.util.ArrayDeque", __K2L_Iterable)
local __K2L_LinkedList = __K2L_Class("java.util.LinkedList", __K2L_List)
setmetatable(__K2L_Deque, {__index = __K2L_List})
__K2L_Deque.____notList = true
for _, deque in ipairs({__K2L_Deque, __K2L_LinkedList}) do
    deque.____interfaces[__K2L_QueueInterface] = true
    deque.____interfaces[__K2L_DequeInterface] = true
end
__K2L_PriorityQueue.____interfaces[__K2L_QueueInterface] = true

__K2L_ArrayDeque.____iteratorClass = __K2L_Class("java.util.AbstractList$Itr", __K2L_ListItr)
__K2L_LinkedList.____iteratorClass = __K2L_Class("java.util.LinkedList$ListItr", __K2L_ListItr)
__K2L_ArrayDeque.____subListClass = __K2L_AbstractSubList
__K2L_Deque.____subListClass = __K2L_AbstractSubList
__K2L_LinkedList.____subListClass = __K2L_AbstractSubList

do

local function noSuchElement(message)
    error(__K2L_NoSuchElementException.new(message))
end

local function nullElement(value)
    if value == nil then
        error(__K2L_NullPointerException.new())
    end
end

-- The element at the front or back, removed, without any call (nil when empty).
local function takeFirst(self)
    local n = self.size
    if n == 0 then
        return nil
    end
    local value = self[1]
    for i = 1, n - 1 do
        self[i] = self[i + 1]
    end
    self[n] = nil
    self.size = n - 1
    self.____modCount = self.____modCount + 1
    return value
end

local function takeLast(self)
    local n = self.size
    if n == 0 then
        return nil
    end
    local value = self[n]
    self[n] = nil
    self.size = n - 1
    self.____modCount = self.____modCount + 1
    return value
end

local function putFirst(self, value)
    for i = self.size, 1, -1 do
        self[i + 1] = self[i]
    end
    self[1] = value
    self.size = self.size + 1
    self.____modCount = self.____modCount + 1
end

local function putLast(self, value)
    self.size = self.size + 1
    self[self.size] = value
    self.____modCount = self.____modCount + 1
end

------------------------------------------------------------------ kotlin.collections.ArrayDeque
-- ArrayDeque(), ArrayDeque(initialCapacity) or ArrayDeque(elements)
function __K2L_ArrayDeque:____init(elements)
    __K2L_List.____init(self, type(elements) == "table" and elements or nil)
end

local function emptyDeque(self)
    if self.size == 0 then
        noSuchElement("ArrayDeque is empty.")
    end
end

function __K2L_ArrayDeque:removeFirst()
    emptyDeque(self)
    return takeFirst(self)
end

function __K2L_ArrayDeque:removeLast()
    emptyDeque(self)
    return takeLast(self)
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

local function checkDequeIndex(self, index)
    if index < 0 or index >= self.size then
        error(__K2L_IndexOutOfBoundsException.new("index: " .. index .. ", size: " .. self.size))
    end
end

function __K2L_ArrayDeque:get(index)
    checkDequeIndex(self, index)
    return self[index + 1]
end

function __K2L_ArrayDeque:removeAt(index)
    checkDequeIndex(self, index)
    return __K2L_List.removeAt(self, index)
end

-- AbstractList.Itr.next() past the end wraps the IndexOutOfBoundsException of get(index) in its NoSuchElementException
local AbstractListItr = __K2L_ArrayDeque.____iteratorClass

function AbstractListItr:next()
    local list, i = self.____list, self.____cursor
    if i >= list.size and list.____modCount == self.____expected then
        noSuchElement("java.lang.IndexOutOfBoundsException: index: " .. i .. ", size: " .. list.size)
    end
    return __K2L_ListItr.next(self)
end

-- Kotlin's ArrayDeque counts a change (its modCount, which its AbstractList iterators check) only when it adds or removes
-- something: adding no elements and clearing an empty deque do not count, and neither do sorting and replaceAll, which
-- set the elements through a list iterator.
local function checkPositionIndex(self, index)
    if index < 0 or index > self.size then
        error(__K2L_IndexOutOfBoundsException.new("index: " .. index .. ", size: " .. self.size))
    end
end

function __K2L_ArrayDeque:addAt(index, value)
    checkPositionIndex(self, index)
    __K2L_List.addAt(self, index, value)
end

function __K2L_ArrayDeque:addAll(elements)
    if elements.size == 0 then
        return false
    end
    return __K2L_List.addAll(self, elements)
end

function __K2L_ArrayDeque:addAllAt(index, elements)
    checkPositionIndex(self, index)
    if elements.size == 0 then
        return false
    end
    return __K2L_List.addAllAt(self, index, elements)
end

function __K2L_ArrayDeque:clear()
    if self.size > 0 then
        __K2L_List.clear(self)
    end
end

for _, name in ipairs({"sort", "sortDescending", "sortBy", "sortByDescending", "sortWith", "replaceAll"}) do
    local method = __K2L_List[name]
    __K2L_ArrayDeque[name] = function(self, ...)
        local modCount = self.____modCount
        method(self, ...)
        self.____modCount = modCount
    end
end

------------------------------------------------------------------ java.util.ArrayDeque
-- The JDK's ArrayDeque keeps its elements in a circular array, and its iterators check no modCount: they count the
-- elements left when they start and read the array slot by slot, throwing ConcurrentModificationException only when the
-- slot they reach is empty. The elements here stay in the list representation (self[1..size]), while ____head and
-- ____capacity follow the JDK's head and elements.length: addFirst, addLast, poll*, remove, clear and growing move them
-- as the JDK's do, so an iterator finds the element (or the empty slot) at its position: slot `p` holds element
-- (p - head) mod capacity when that is below size.
local DeqIterator = __K2L_Class("java.util.ArrayDeque$DeqIterator")
local DescendingIterator = __K2L_Class("java.util.ArrayDeque$DescendingIterator", DeqIterator)
__K2L_Deque.____iteratorClass = DeqIterator

-- ArrayDeque.grow(needed): by half the capacity (by the capacity plus 2 below 64), or by `needed` when that is more; the
-- elements from head to the end of the array move to the end of the larger one when the deque wraps around (or is full).
local function grow(self, needed)
    local capacity, head, size = self.____capacity, self.____head, self.size
    local jump = capacity < 64 and capacity + 2 or math.floor(capacity / 2)
    local newCapacity = needed > jump and capacity + needed or capacity + jump
    local tail = (head + size) % capacity
    if tail < head or (tail == head and size > 0) then
        self.____head = head + newCapacity - capacity
    end
    self.____capacity = newCapacity
end

-- ArrayDeque(), ArrayDeque(numElements) or ArrayDeque(elements), which adds them with addLast.
function __K2L_Deque:____init(elements)
    __K2L_List.____init(self)
    self.____head, self.____capacity = 0, 17
    if type(elements) == "number" then
        self.____capacity = elements < 1 and 1 or elements + 1
    elseif type(elements) == "table" then
        local arr, n = elements:____array()
        self.____capacity = n < 1 and 1 or n + 1
        for i = 1, n do
            self:addLast(arr[i])
        end
    end
end

-- The element in slot `p` of the JDK's array, or ConcurrentModificationException for an empty slot.
local function elementAt(self, p)
    local i = (p - self.____head) % self.____capacity
    if i >= self.size then
        error(__K2L_ConcurrentModificationException.new())
    end
    return self[i + 1]
end

-- ArrayDeque.delete(slot): removes the element there by moving the shorter side of the deque over it (the front forward,
-- which moves head, or the back backward); whether the back moved.
local function delete(self, p)
    local i = (p - self.____head) % self.____capacity
    if i >= self.size then
        error(__K2L_ConcurrentModificationException.new())
    end
    local front, back = i, self.size - i - 1
    __K2L_List.removeAt(self, i)
    if front < back then
        self.____head = (self.____head + 1) % self.____capacity
        return false
    end
    return true
end

function __K2L_Deque:iterator()
    return DeqIterator.new(self)
end

function __K2L_Deque:descendingIterator()
    return DescendingIterator.new(self)
end

-- the JDK's DeqIterator starts from size(), which a subclass may override
function DeqIterator:____init(deque)
    self.____deque, self.____last = deque, -1
    self.____remaining = deque.getSize ~= nil and deque:getSize() or deque.size
    self.____cursor = self:____start(deque)
end

function DeqIterator:____start(deque)
    return deque.____head
end

function DeqIterator:____step(cursor, capacity)
    return (cursor + 1) % capacity
end

function DeqIterator:hasNext()
    return self.____remaining > 0
end

function DeqIterator:next()
    if self.____remaining <= 0 then
        noSuchElement()
    end
    local deque, cursor = self.____deque, self.____cursor
    local value = elementAt(deque, cursor)
    self.____last, self.____cursor = cursor, self:____step(cursor, deque.____capacity)
    self.____remaining = self.____remaining - 1
    return value
end

-- postDelete: when the back moved, the next element is one slot back
DeqIterator.____shifted, DeqIterator.____shiftStep = true, 1

function DeqIterator:remove()
    if self.____last < 0 then
        error(__K2L_IllegalStateException.new())
    end
    local deque = self.____deque
    if delete(deque, self.____last) == self.____shifted then
        self.____cursor = (self.____cursor - self.____shiftStep) % deque.____capacity
    end
    self.____last = -1
end

-- from the last element backwards; when the front moved, the next element is one slot further
function DescendingIterator:____start(deque)
    return (deque.____head + deque.size - 1) % deque.____capacity
end

function DescendingIterator:____step(cursor, capacity)
    return (cursor - 1) % capacity
end

DescendingIterator.____shifted, DescendingIterator.____shiftStep = false, -1

-- A `for` loop over a java.util.ArrayDeque goes through its iterator: the loop reads its elements one by one from this
-- table, as many as the deque had when it started, and the iterator throws (____comodified lets the loop go on).
function __K2L_Deque:____loopArray()
    if self.iterator ~= __K2L_Deque.iterator then
        return self:____array()
    end
    local iterator = DeqIterator.new(self)
    local items = setmetatable({}, {__index = function() return iterator:next() end})
    return items, iterator.____remaining
end

function __K2L_Deque:____comodified()
    return false
end

-- LinkedList.ListItr.hasNext() is nextIndex < size
function __K2L_LinkedList:____comodified(i)
    if i < self.size then
        __K2L_Comodification()
    end
    return true
end

-- Not a list: equal to itself only.
function __K2L_Deque:equals(other)
    return rawequal(self, other)
end

function __K2L_Deque:hashCode()
    return __K2L_IdentityHash(self)
end

function __K2L_Deque:addFirst(value)
    nullElement(value)
    putFirst(self, value)
    self.____head = (self.____head - 1) % self.____capacity
    if self.size == self.____capacity then
        grow(self, 1)
    end
end

function __K2L_Deque:addLast(value)
    nullElement(value)
    putLast(self, value)
    if self.size == self.____capacity then
        grow(self, 1)
    end
end

function __K2L_Deque:offerFirst(value)
    self:addFirst(value)
    return true
end

function __K2L_Deque:offerLast(value)
    self:addLast(value)
    return true
end

function __K2L_Deque:add(value)
    self:addLast(value)
    return true
end

function __K2L_Deque:offer(value)
    return self:offerLast(value)
end

function __K2L_Deque:push(value)
    self:addFirst(value)
end

-- reads size before and after adding each element with addLast, as the JDK's does (growing first for all of them)
function __K2L_Deque:addAll(elements)
    local before = self.size
    local arr, n = elements:____array()
    local needed = before + n + 1 - self.____capacity
    if needed > 0 then
        grow(self, needed)
    end
    for i = 1, n do
        self:addLast(arr[i])
    end
    return self.size > before
end

function __K2L_Deque:pollFirst()
    local value = takeFirst(self)
    if value ~= nil then
        self.____head = (self.____head + 1) % self.____capacity
    end
    return value
end

__K2L_Deque.pollLast = takeLast

-- remove(element) is removeFirstOccurrence: delete() at the first equal element
function __K2L_Deque:remove(value)
    for i = 1, self.size do
        if __K2L_Equals(self[i], value) then
            delete(self, (self.____head + i - 1) % self.____capacity)
            return true
        end
    end
    return false
end

function __K2L_Deque:clear()
    __K2L_List.clear(self)
    self.____head = 0
end

function __K2L_Deque:poll()
    return self:pollFirst()
end

function __K2L_Deque:removeFirst()
    local value = self:pollFirst()
    if value == nil then
        noSuchElement()
    end
    return value
end

function __K2L_Deque:removeLast()
    local value = self:pollLast()
    if value == nil then
        noSuchElement()
    end
    return value
end

function __K2L_Deque:pop()
    return self:removeFirst()
end

-- remove() takes the head with removeFirst
function __K2L_Deque:removeHead()
    return self:removeFirst()
end

function __K2L_Deque:peekFirst()
    return self[1]
end

function __K2L_Deque:peekLast()
    return self[self.size]
end

function __K2L_Deque:peek()
    return self:peekFirst()
end

function __K2L_Deque:getFirst()
    if self.size == 0 then
        noSuchElement()
    end
    return self[1]
end

function __K2L_Deque:getLast()
    if self.size == 0 then
        noSuchElement()
    end
    return self[self.size]
end

function __K2L_Deque:element()
    return self:getFirst()
end

------------------------------------------------------------------ java.util.LinkedList
-- LinkedList() or LinkedList(elements), which calls addAll(elements).
function __K2L_LinkedList:____init(elements)
    __K2L_List.____init(self)
    if type(elements) == "table" then
        self:addAll(elements)
    end
end

function __K2L_LinkedList:addAll(elements)
    return self:addAllAt(self.size, elements)
end

function __K2L_LinkedList:addFirst(value)
    putFirst(self, value)
end

function __K2L_LinkedList:addLast(value)
    putLast(self, value)
end

function __K2L_LinkedList:offer(value)
    return self:add(value)
end

function __K2L_LinkedList:offerFirst(value)
    self:addFirst(value)
    return true
end

function __K2L_LinkedList:offerLast(value)
    self:addLast(value)
    return true
end

function __K2L_LinkedList:push(value)
    self:addFirst(value)
end

function __K2L_LinkedList:removeFirst()
    if self.size == 0 then
        noSuchElement()
    end
    return takeFirst(self)
end

function __K2L_LinkedList:removeLast()
    if self.size == 0 then
        noSuchElement()
    end
    return takeLast(self)
end

function __K2L_LinkedList:pop()
    return self:removeFirst()
end

-- remove() takes the head with removeFirst
function __K2L_LinkedList:removeHead()
    return self:removeFirst()
end

__K2L_LinkedList.poll = takeFirst
__K2L_LinkedList.pollFirst = takeFirst
__K2L_LinkedList.pollLast = takeLast

function __K2L_LinkedList:getFirst()
    if self.size == 0 then
        noSuchElement()
    end
    return self[1]
end

function __K2L_LinkedList:getLast()
    if self.size == 0 then
        noSuchElement()
    end
    return self[self.size]
end

function __K2L_LinkedList:element()
    return self:getFirst()
end

local function checkElementIndex(self, index)
    if index < 0 or index >= self.size then
        error(__K2L_IndexOutOfBoundsException.new("Index: " .. index .. ", Size: " .. self.size))
    end
end

function __K2L_LinkedList:get(index)
    checkElementIndex(self, index)
    return self[index + 1]
end

function __K2L_LinkedList:removeAt(index)
    checkElementIndex(self, index)
    return __K2L_List.removeAt(self, index)
end

end
