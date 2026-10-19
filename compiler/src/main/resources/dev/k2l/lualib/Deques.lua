-- requires: Class, Collections, Exceptions, IdentityHash
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
__K2L_Deque.____iteratorClass = __K2L_Class("java.util.ArrayDeque$DeqIterator", __K2L_CollectionIterator)
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

------------------------------------------------------------------ java.util.ArrayDeque
-- ArrayDeque(), ArrayDeque(numElements) or ArrayDeque(elements), which adds them with addLast.
function __K2L_Deque:____init(elements)
    __K2L_List.____init(self)
    if type(elements) == "table" then
        local arr, n = elements:____array()
        for i = 1, n do
            self:addLast(arr[i])
        end
    end
end

-- Its iterator counts the elements it has left when it starts and does not check for changes (it fails only on a slot
-- emptied under it): `for` loops over it go on.
function __K2L_Deque:____comodified()
    return false
end

local DeqIterator = __K2L_Deque.____iteratorClass

-- the JDK's DeqIterator starts from size(), which a subclass may override
function __K2L_Deque:iterator()
    if self.getSize ~= nil then
        self:getSize()
    end
    return __K2L_Iterable.iterator(self)
end

function DeqIterator:next()
    self.____expected = self.____source.____modCount
    return __K2L_CollectionIterator.next(self)
end

function DeqIterator:remove()
    self.____expected = self.____source.____modCount
    return __K2L_CollectionIterator.remove(self)
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
end

function __K2L_Deque:addLast(value)
    nullElement(value)
    putLast(self, value)
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

-- reads size before and after adding each element with addLast, as the JDK's does
function __K2L_Deque:addAll(elements)
    local before = self.size
    local arr, n = elements:____array()
    for i = 1, n do
        self:addLast(arr[i])
    end
    return self.size > before
end

__K2L_Deque.pollFirst = takeFirst
__K2L_Deque.pollLast = takeLast

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
