local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_GenerateSequenceLazy = ____lualib.__K2L_GenerateSequenceLazy
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReverseOrder = ____lualib.__K2L_ReverseOrder
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Then = ____lualib.__K2L_Then
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Key = __K2L_Class("generics.containers.Key")

function Key:____init(name, default)
    if default == nil then
        default = nil
    end
    self.name = name
    self.default = default
end

function Key:toString()
    return "Key(" .. self.name .. ")"
end

local TypedMap = __K2L_Class("generics.containers.TypedMap")

function TypedMap:____init()
    self.values = __K2L_Map.new()
end

function TypedMap:set(key, value)
    local ____object = self.values
    ____object:set(key, value)
end

function TypedMap:get(key)
    return self.values:get(key) or key.default
end

function TypedMap:require(key)
    local ____value = self:get(key)
    if ____value == nil then
        error(__K2L_NoSuchElementException.new("missing " .. __K2L_Str(key)))
    end
    return ____value
end

function TypedMap:update(key, f)
    local ____value_1 = f(self:get(key))
    self:set(key, ____value_1)
    return ____value_1
end

function TypedMap:contains(key)
    return self.values:containsKey(key)
end

function TypedMap:getSize()
    return self.values.size
end

function TypedMap:toString()
    return self.values:getEntries():joinToString(", ", "{", "}", nil, nil, function(____destructured)
        local k, v = ____destructured.key, ____destructured.value
        return k.name .. "=" .. __K2L_Str(v)
    end)
end

local LruCache = __K2L_Class("generics.containers.LruCache")

function LruCache:____init(capacity, onEvict)
    if onEvict == nil then
        onEvict = function(_, _) end
    end
    self.capacity = capacity
    self.onEvict = onEvict
    self.map = __K2L_Map.new()
    self.hits = 0
    self.misses = 0
    if not (self.capacity > 0) then
        error(__K2L_IllegalArgumentException.new("capacity must be positive, was " .. self.capacity))
    end
end

function LruCache:get(key)
    local ____value_2 = self.map:remove(key)
    if ____value_2 == nil then
        local ____result
        self.misses = self.misses + 1
        return nil
    end
    local v = ____value_2
    self.hits = self.hits + 1
    local ____object_1 = self.map
    ____object_1:set(key, v)
    return v
end

function LruCache:set(key, value)
    self.map:remove(key)
    local ____object_2 = self.map
    ____object_2:set(key, value)
    while self.map.size > self.capacity do
        local eldest = self.map:getEntries():first()
        self.map:remove(eldest.key)
        self.onEvict(eldest.key, eldest.value)
    end
end

function LruCache:getOrPut(key, compute)
    local ____value_4 = self:get(key)
    if ____value_4 == nil then
        local ____value_3 = compute(key)
        self:set(key, ____value_3)
        ____value_4 = ____value_3
    end
    return ____value_4
end

function LruCache:getKeys()
    return self.map:getKeys():toList()
end

local ____lambda_1 = function(it)
    return __K2L_Str(it.key) .. ":" .. __K2L_Str(it.value)
end
function LruCache:toString()
    return "LRU" .. __K2L_Str(self.map:getEntries():map(____lambda_1)) .. " hits=" .. self.hits .. " misses=" .. self.misses
end

local BoundedQueue = __K2L_Class("generics.containers.BoundedQueue", __K2L_IterableBase)

function BoundedQueue:____init(limit, comparator)
    self.limit = limit
    self.comparator = comparator
    self.heap = __K2L_List.new()
end

function BoundedQueue:getSize()
    return self.heap.size
end

function BoundedQueue:offer(item)
    if self.heap.size < self.limit then
        self.heap:add(item)
        self:siftUp(self.heap.size - 1)
        return true
    end
    if self.comparator(item, self.heap:get(0)) <= 0 then
        return false
    end
    local ____object_3 = self.heap
    ____object_3:set(0, item)
    self:siftDown(0)
    return true
end

function BoundedQueue:peek()
    return self.heap:firstOrNull()
end

function BoundedQueue:poll()
    if self.heap:isEmpty() then
        return nil
    end
    local top = self.heap:get(0)
    local last = self.heap:removeAt(self.heap.size - 1)
    if self.heap:isNotEmpty() then
        local ____object_4 = self.heap
        ____object_4:set(0, last)
        self:siftDown(0)
    end
    return top
end

function BoundedQueue:siftUp(start)
    local i = start
    while i > 0 do
        local parent = (i - 1) // 2
        if self.comparator(self.heap:get(i), self.heap:get(parent)) >= 0 then
            break
        end
        local ____object_5 = self.heap
        local ____key = i
        local ____value_5 = self.heap:get(parent)
        do
            local ____object_6 = self.heap
            ____object_6:set(parent, self.heap:get(i))
        end
        ____object_5:set(____key, ____value_5)
        i = parent
    end
end

function BoundedQueue:siftDown(start)
    local i = start
    while true do
        local l = 2 * i + 1
        local r = l + 1
        local smallest = i
        if l < self.heap.size and self.comparator(self.heap:get(l), self.heap:get(smallest)) < 0 then
            smallest = l
        end
        if r < self.heap.size and self.comparator(self.heap:get(r), self.heap:get(smallest)) < 0 then
            smallest = r
        end
        if smallest == i then
            return
        end
        local ____object_7 = self.heap
        local ____key_1 = i
        local ____value_6 = self.heap:get(smallest)
        do
            local ____object_8 = self.heap
            local ____key_2 = smallest
            ____object_8:set(____key_2, self.heap:get(i))
        end
        ____object_7:set(____key_1, ____value_6)
        i = smallest
    end
end

function BoundedQueue:drainDescending()
    return __K2L_GenerateSequenceLazy(function() return self:poll() end):toList():asReversed()
end

function BoundedQueue:iterator()
    return __K2L_IteratorOf(self.heap:sortedWith(self.comparator))
end

local Trie = __K2L_Class("generics.containers.Trie")

function Trie:____init()
    self.root = Trie.Node.new()
    self.size = 0
end

Trie.Node = __K2L_Class("generics.containers.Trie$Node")

function Trie.Node:____init()
    self.children = __K2L_SortedMapOf(nil)
    self.value = nil
    self.terminal = false
end

local ____lambda_2 = function() return Trie.Node.new() end
function Trie:set(word, value)
    local node = self.root
    for ____i = 1, #word do
        local c = word:sub(____i, ____i)
        node = node.children:getOrPut(c, ____lambda_2)
    end
    if not node.terminal then
        self.size = self.size + 1
    end
    local ____object_9 = node
    ____object_9.terminal = true
    local ____object_10 = node
    ____object_10.value = value
end

function Trie:get(word)
    local ____receiver = self:find(word)
    local ____receiver_1 = ____receiver and (____receiver.terminal and ____receiver or nil)
    return ____receiver_1 and ____receiver_1.value
end

function Trie:find(prefix)
    local node = self.root
    for ____i_1 = 1, #prefix do
        local c = prefix:sub(____i_1, ____i_1)
        local ____value_7 = node.children:get(c)
        if ____value_7 == nil then
            return nil
        end
        node = ____value_7
    end
    return node
end

function Trie:withPrefix(prefix)
    local out = __K2L_ListOf()
    local function walk(node, path)
        if node.terminal then
            out:add(__K2L_Pair.new(path:toString(), node.value))
        end
        local ____map = node.children
        local ____keys, ____values, ____n = ____map:____arrays()
        for ____i_2 = 1, ____n do
            local c, child = ____keys[____i_2], ____values[____i_2]
            path:append(__K2L_Str(c))
            walk(child, path)
            path:setLength(path:getLength() - 1)
        end
    end
    local ____receiver_2 = self:find(prefix)
    if ____receiver_2 ~= nil then
        walk(____receiver_2, __K2L_StringBuilder.new(prefix))
    end
    return out
end

function Trie:longestPrefixOf(text)
    local node = self.root
    local best = nil
    local ____collection = __K2L_StringToList(text):withIndex()
    local ____items, ____n_1 = ____collection:____array()
    for ____i_3 = 1, ____n_1 do
        local ____item = ____items[____i_3]
        local i, c = ____item.index, ____item.value
        local ____value_8 = node.children:get(c)
        if ____value_8 == nil then
            break
        end
        node = ____value_8
        if node.terminal then
            best = __K2L_Text.substring(text, 0, i + 1)
        end
    end
    return best
end

local Task = __K2L_Class("generics.containers.Task")

function Task:____init(name, priority, cost)
    self.name = name
    self.priority = priority
    self.cost = cost
end

function Task.new(name, priority, cost)
    return setmetatable({name = name, priority = priority, cost = cost}, Task)
end

function Task:toString()
    return "Task(name=" .. self.name .. ", priority=" .. self.priority .. ", cost=" .. self.cost .. ")"
end

function Task:hashCode()
    return (31 * (31 * __K2L_Hash(self.name) + self.priority) + __K2L_Hash(self.cost) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Task:equals(other)
    return getmetatable(other) == Task and self.name == other.name and self.priority == other.priority and self.cost == other.cost
end

local PORT = Key.new("port", 8080)
local HOST = Key.new("host")
local TAGS = Key.new("tags")
local RETRIES = Key.new("retries", 3)

local ____lambda_3 = function(it) return (it or 0) + 1 end
local ____lambda_4 = function(it) return __K2L_NotNull(it) * 10 end
local ____lambda_5 = function(it) return #it end
local ____lambda_6 = function(____a, ____b)
    local ____x_1, ____y_1 = ____a.priority, ____b.priority
    if ____x_1 ~= ____y_1 then
        return ____x_1 < ____y_1 and -1 or 1
    end
    return __K2L_CompareValues(____b.cost, ____a.cost)
end
local ____lambda_7 = function(it) return it.name end
local ____lambda_8 = function(it) return it.name .. "(" .. it.priority .. ")" end
local ____lambda_9 = function(____p1) return #____p1 end
local function main()
    print("== typed map")
    local config = TypedMap.new()
    print("port=" .. __K2L_Str(config:get(PORT)) .. " host=" .. __K2L_Str(config:get(HOST)) .. " size=" .. config:getSize())
    local ____key_3 = HOST
    config:set(____key_3, "localhost")
    local ____key_4 = TAGS
    config:set(____key_4, __K2L_ListOf("web", "api"))
    local ____key_5 = PORT
    config:set(____key_5, 9000)
    local ____arg = #config:require(HOST)
    local ____receiver_3 = config:get(TAGS)
    print("host length=" .. ____arg .. " tags=" .. __K2L_Str(____receiver_3 and ____receiver_3:joinToString("|")))
    print("retries=" .. config:update(RETRIES, ____lambda_3) .. " then " .. config:update(RETRIES, ____lambda_4))
    print("contains HOST=" .. tostring(config:contains(HOST)) .. " contains Key(host)=" .. tostring(config:contains(Key.new("host"))))
    print(__K2L_Str(config))
    local ____ok, ____result_1 = pcall(function()
        config:require(Key.new("timeout"))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print("== lru")
    local evicted = __K2L_ListOf()
    local cache = LruCache.new(3, function(k, v)
        evicted:add(k .. "=" .. v)
    end)
    local ____list = __K2L_StringSplit("the quick brown fox jumps over the lazy dog the end", " ")
    for ____i_4 = 1, ____list.size do
        local w = ____list[____i_4]
        cache:getOrPut(w, ____lambda_5)
    end
    print(__K2L_Str(cache))
    print("evicted: " .. __K2L_Str(evicted))
    print("keys=" .. __K2L_Str(cache:getKeys()) .. " get(the)=" .. __K2L_Str(cache:get("the")) .. " get(fox)=" .. __K2L_Str(cache:get("fox")))
    local ____ok_1, ____result_2 = pcall(function()
        LruCache.new(0)
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    print("== bounded queue")
    local tasks = __K2L_ListOf(Task.new("deploy", 5, 2.5), Task.new("lint", 1, 0.25), Task.new("test", 4, 7.0), Task.new("docs", 2, 1.0), Task.new("bench", 4, 12.0), Task.new("release", 5, 0.5), Task.new("audit", 3, 3.25))
    local top = BoundedQueue.new(3, ____lambda_6)
    local accepted = tasks:map(function(t)
        return t.name .. ":" .. (top:offer(t) and "+" or "-")
    end)
    print(accepted:joinToString(" "))
    local ____receiver_4 = top:peek()
    print("peek=" .. __K2L_Str(____receiver_4 and ____receiver_4.name) .. " ordered=" .. __K2L_Str(top:map(____lambda_7)))
    print("drained=" .. __K2L_Str(top:drainDescending():map(____lambda_8)) .. " empty=" .. __K2L_Str(top:poll()))
    local words = BoundedQueue.new(4, __K2L_Then(__K2L_CompareBy(____lambda_9), __K2L_ReverseOrder))
    local ____list_1 = __K2L_StringSplit("kotlin lua generic variance bound star projection reified", " ")
    for ____i_5 = 1, ____list_1.size do
        local it = ____list_1[____i_5]
        words:offer(it)
    end
    print("longest=" .. __K2L_Str(words:toList()))
    print("== trie")
    local trie = Trie.new()
    local ____list_2 = __K2L_ListOf("car", "card", "care", "cart", "cat", "dog", "do")
    for ____i_6 = 1, ____list_2.size do
        local w = ____list_2[____i_6]
        local i = ____i_6 - 1
        trie:set(w, i * 10)
    end
    trie:set("car", -1)
    print("size=" .. trie.size .. " car=" .. __K2L_Str(trie:get("car")) .. " ca=" .. __K2L_Str(trie:get("ca")) .. " dog=" .. __K2L_Str(trie:get("dog")))
    print("car*: " .. __K2L_Str(trie:withPrefix("car")))
    print("d*: " .. __K2L_Str(trie:withPrefix("d"):map(function(____destructured_1)
        local w, v = ____destructured_1.first, ____destructured_1.second
        return w .. "/" .. v
    end)))
    print("x*: " .. __K2L_Str(trie:withPrefix("x")))
    print("longest prefix of 'cartography'=" .. __K2L_Str(trie:longestPrefixOf("cartography")) .. " of 'dots'=" .. __K2L_Str(trie:longestPrefixOf("dots")))
    local counts = Trie.new()
    local ____list_3 = __K2L_Text.windowed("abracadabra", 3)
    for ____i_7 = 1, ____list_3.size do
        local gram = ____list_3[____i_7]
        local i = ____i_7 - 1
        do
            local ____value_10 = counts:get(gram)
            if ____value_10 == nil then
                local ____value_9 = __K2L_ListOf()
                counts:set(gram, ____value_9)
                ____value_10 = ____value_9
            end
            ____value_10:add(i)
        end
    end
    print("trigrams: " .. counts:withPrefix(""):joinToString(nil, nil, nil, nil, nil, function(____destructured_2)
        local g, at = ____destructured_2.first, ____destructured_2.second
        return g .. "@" .. __K2L_Str(at)
    end))
end

__K2L_RunMain(main)
return {Key = Key, TypedMap = TypedMap, LruCache = LruCache, BoundedQueue = BoundedQueue, Trie = Trie, Task = Task, PORT = PORT, HOST = HOST, TAGS = TAGS, RETRIES = RETRIES}
