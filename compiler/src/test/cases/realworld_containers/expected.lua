local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IndexOutOfBoundsException = ____lualib.__K2L_IndexOutOfBoundsException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IsCharSequence = ____lualib.__K2L_IsCharSequence
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReverseOrder = ____lualib.__K2L_ReverseOrder
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Source = __K2L_Class("containers.Source", __K2L_IterableBase)

function Source:isEmpty()
    return self.size == 0
end

function Source:iterator()
    local ____this = self
    local ____object = __K2L_Class("containers.Source$iterator$1")
    function ____object:____init()
        self.i = 0
    end
    function ____object:hasNext()
        return self.i < ____this.size
    end
    function ____object:next()
        if self:hasNext() then
            local ____old = self.i
            self.i = self.i + 1
            return ____this:get(____old)
        else
            error(__K2L_NoSuchElementException.new("index " .. self.i .. " of " .. ____this.size))
        end
    end
    ____object:____init()
    return ____object
end

local Sink = __K2L_Class("containers.Sink")
local Vec = __K2L_Class("containers.Vec", nil, Source, Sink)

function Vec:____init(initialCapacity)
    if initialCapacity == nil then
        initialCapacity = 4
    end
    self.items = __K2L_ListOfSize(initialCapacity, nil, true)
    self.size = 0
    self.growths = 0
end

function Vec:get(index)
    if not (index >= 0 and index < self.size) then
        error(__K2L_IndexOutOfBoundsException.new("Index " .. index .. " out of bounds for length " .. self.size))
    end
    return self.items:get(index)
end

function Vec:set(index, value)
    self:get(index)
    local ____object_1 = self.items
    ____object_1:set(index, value)
end

function Vec:put(item)
    if self.size == self.items.size then
        self.items = self.items:copyOfSize(self.items.size * 2, nil)
        self.growths = self.growths + 1
    end
    local ____arg = self.items
    local ____old_1 = self.size
    self.size = self.size + 1
    local ____key = ____old_1
    ____arg:set(____key, item)
end

function Vec:plusAssign(item)
    self:put(item)
end

function Vec:contains(item)
    return self:indexOf(item) >= 0
end

function Vec:indexOf(item)
    for i = 0, self.size - 1 do
        if __K2L_Equals(self.items:get(i), item) then
            return i
        end
    end
    return -1
end

function Vec:removeAt(index)
    local old = self:get(index)
    for i = index, self.size - 1 - 1 do
        local ____object_2 = self.items
        ____object_2:set(i, self.items:get(i + 1))
    end
    local ____arg_1 = self.items
    self.size = self.size - 1
    local ____key_1 = self.size
    ____arg_1:set(____key_1, nil)
    return old
end

function Vec:mapTo(transform)
    local out = Vec.new(math.max(self.size, 1))
    local ____items, ____n = self:____array()
    for ____i = 1, ____n do
        local x = ____items[____i]
        out:put(transform(x))
    end
    return out
end

function Vec:toString()
    return self:joinToString(", ", "Vec[", "]")
end

function Vec:of(...)
    local xs = __K2L_ArrayOf(...)
    local ____value = Vec.new(math.max(xs.size, 1))
    for ____i_1 = 1, xs.size do
        local it = xs[____i_1]
        ____value:put(it)
    end
    return ____value
end

local function putAll(self, items)
    local ____items_1, ____n_1 = items:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        self:put(it)
    end
end

local function maxOrNull(____this_1)
    local best = nil
    local ____items_2, ____n_2 = ____this_1:____array()
    for ____i_3 = 1, ____n_2 do
        local x = ____items_2[____i_3]
        if best == nil or __K2L_Compare(x, best) > 0 then
            best = x
        end
    end
    return best
end

local function copy(from, to)
    local ____items_3, ____n_3 = from:____array()
    for ____i_4 = 1, ____n_3 do
        local x = ____items_3[____i_4]
        to:put(x)
    end
end

local Matrix = __K2L_Class("containers.Matrix")

local ____lambda_1 = function(_, _) return 0.0 end
function Matrix:____init(rows, cols, init)
    if init == nil then
        init = ____lambda_1
    end
    self.rows = rows
    self.cols = cols
    self.data = __K2L_ListOfSize(self.rows * self.cols, function(it)
        return init(it // self.cols, it % self.cols)
    end, true)
end

function Matrix:get(r, c)
    return self.data[r * self.cols + c + 1] or __K2L_IndexError(r * self.cols + c, self.data.size, "array")
end

function Matrix:set(r, c, v)
    local ____object_3 = self.data
    local ____key_2 = r * self.cols + c
    if ____key_2 < 0 or ____key_2 >= ____object_3.size then
        __K2L_IndexError(____key_2, ____object_3.size, "array")
    end
    ____object_3[____key_2 + 1] = v
end

function Matrix:times(o)
    if self.cols ~= o.rows then
        error(__K2L_IllegalArgumentException.new("shape mismatch " .. self.rows .. "x" .. self.cols .. " * " .. o.rows .. "x" .. o.cols))
    end
    return Matrix.new(self.rows, o.cols, function(r, c)
        return __K2L_IntRange.new(0, self.cols - 1):sumOf(function(it) return self:get(r, it) * o:get(it, c) end, 0.0)
    end)
end

function Matrix:invoke(r)
    return Matrix.Row.new(self, r)
end

Matrix.Row = __K2L_Class("containers.Matrix$Row", __K2L_IterableBase)

function Matrix.Row:____init(____outer, r)
    self.____outer = ____outer
    self.r = r
end

function Matrix.Row:iterator()
    return __K2L_IteratorOf(__K2L_IntRange.new(0, self.____outer.cols - 1):map(function(it) return self.____outer:get(self.r, it) end))
end

local ____lambda_2 = function(it) return string.format("%.1f", it) end
function Matrix.Row:toString()
    return self:joinToString(" ", "(", ")", nil, nil, ____lambda_2)
end

function Matrix:toString()
    return __K2L_IntRange.new(0, self.rows - 1):joinToString("\n", nil, nil, nil, nil, function(it) return self:invoke(it):toString() end)
end

local Cache = __K2L_Class("containers.Cache")

function Cache:____init(capacity, loader)
    self.capacity = capacity
    self.loader = loader
    self.entries = __K2L_Map.new()
    self.hits = 0
    self.misses = 0
end

function Cache:get(key)
    local ____receiver = self.entries:remove(key)
    if ____receiver ~= nil then
        local ____result
        do
            self.hits = self.hits + 1
            local ____object_4 = self.entries
            ____object_4:set(key, ____receiver)
            return ____receiver
        end
    end
    self.misses = self.misses + 1
    local value = self.loader(key)
    local ____object_5 = self.entries
    ____object_5:set(key, value)
    if self.entries.size > self.capacity then
        self.entries:remove(self.entries:getKeys():first())
    end
    return value
end

function Cache:getKeys()
    return self.entries:getKeys():toList()
end

local Graph = __K2L_Class("containers.Graph")

function Graph:____init()
    self.edges = __K2L_MapOf()
end

local ____lambda_3 = function() return __K2L_SetOf() end
local ____lambda_4 = function() return __K2L_SetOf() end
function Graph:edge(a, b)
    self.edges:getOrPut(a, ____lambda_3):add(b)
    self.edges:getOrPut(b, ____lambda_4)
end

function Graph:bfs(start)
    local seen = __K2L_SetOf(start)
    local queue = __K2L_ArrayDeque.new(__K2L_ListOf(start))
    while queue:isNotEmpty() do
        local n = queue:removeFirst()
        local ____collection = self.edges:get(n) or __K2L_SetOf()
        local ____items_4, ____n_4 = ____collection:____array()
        for ____i_5 = 1, ____n_4 do
            local m = ____items_4[____i_5]
            if seen:add(m) then
                queue:addLast(m)
            end
        end
    end
    return seen:toList()
end

local ____lambda_5 = function(it) return 0 end
local ____lambda_6 = function(it) return it == 0 end
function Graph:topo()
    local inDegree = self.edges:getKeys():associateWith(____lambda_5):toMutableMap()
    local ____list = self.edges:getValues():flatten()
    for ____i_6 = 1, ____list.size do
        local it = ____list[____i_6]
        inDegree:set(it, inDegree:getValue(it) + 1)
    end
    local ready = inDegree:filterValues(____lambda_6):getKeys():toMutableList()
    local out = __K2L_ListOf()
    while ready:isNotEmpty() do
        local n = ready:removeAt(0)
        out:add(n)
        local ____collection_1 = self.edges:getValue(n)
        local ____items_5, ____n_5 = ____collection_1:____array()
        for ____i_7 = 1, ____n_5 do
            local m = ____items_5[____i_7]
            inDegree:set(m, inDegree:getValue(m) - 1)
            if inDegree:get(m) == 0 then
                ready:add(m)
            end
        end
    end
    if out.size ~= self.edges.size then
        error(__K2L_IllegalStateException.new("cycle detected"))
    end
    return out
end

local Version = __K2L_Class("containers.Version")
Version.____comparable = true

function Version:____init(major, minor)
    self.major = major
    self.minor = minor
end

function Version.new(major, minor)
    return setmetatable({major = major, minor = minor}, Version)
end

local ____lambda_7 = function(receiver) return receiver.major end
local ____lambda_8 = function(receiver) return receiver.minor end
function Version:compareTo(other)
    return __K2L_CompareBy(__K2L_PropertyRef.new("major", "major@5176", ____lambda_7), __K2L_PropertyRef.new("minor", "minor@5192", ____lambda_8))(self, other)
end

function Version:toString()
    return self.major .. "." .. self.minor
end

function Version:hashCode()
    return (31 * self.major + self.minor + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Version:equals(other)
    return getmetatable(other) == Version and self.major == other.major and self.minor == other.minor
end

local ____lambda_9 = function(it) return it * 2 end
local ____lambda_10 = function(x) return math.type(x) == "integer" end
local ____lambda_11 = function(x) return __K2L_IsCharSequence(x) end
local ____lambda_12 = function(it) return type(it) == "string" end
local ____lambda_13 = function(r, c) return r * 3 + c + 0.0 end
local ____lambda_14 = function(r, c) return r == c and 1.0 or 0.0 end
local ____lambda_15 = function(____a, ____b)
    local ____x, ____y = ____a.minor, ____b.minor
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local function main()
    local v = Vec.new(1)
    putAll(v, __K2L_ListOf(5, 3, 8, 1))
    v:plusAssign(9)
    print(__K2L_Str(v) .. " size=" .. v.size .. " growths=" .. v.growths .. " max=" .. __K2L_Str(maxOrNull(v)) .. " has8=" .. tostring(v:contains(8)) .. " has4=" .. tostring(v:contains(4)))
    v:set(1, 30)
    print("removed " .. v:removeAt(0) .. " -> " .. __K2L_Str(v) .. ", doubled " .. __K2L_Str(v:mapTo(____lambda_9)))
    local ____ok, ____result_1 = pcall(function()
        v:get(10)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, __K2L_IndexOutOfBoundsException) then
            local e = ____error
            print(__K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local it = Vec:of("a"):iterator()
    it:next()
    print(__K2L_Str(__K2L_RunCatching(function() return it:next() end):exceptionOrNull()))
    local numbers = Vec:of(1, 2.5, 3)
    local anything = Vec.new()
    copy(numbers, anything)
    anything:put("text")
    local src = anything
    local ____arg_2 = src.size
    local ____result_2
    ____result_2 = anything:filter(____lambda_10)
    local ____arg_3 = __K2L_Str(____result_2)
    local ____result_3
    ____result_3 = anything:filter(____lambda_11)
    local ____arg_4 = __K2L_Str(____result_3)
    local ____result_4
    ____result_4 = src:count(____lambda_12)
    print(____arg_2 .. " ints=" .. ____arg_3 .. " texts=" .. ____arg_4 .. " strings=" .. ____result_4)
    print(__K2L_Str(maxOrNull(Vec:of(Version.new(1, 2), Version.new(1, 10), Version.new(0, 9)))))
    print(Vec.new():isEmpty() and maxOrNull(Vec.new()) == nil)
    local m = Matrix.new(2, 3, ____lambda_13)
    local id = Matrix.new(3, 3, ____lambda_14)
    id:set(0, 2, 2.0)
    print(__K2L_Str(m:times(id)))
    print(m:invoke(1):sum())
    local ____receiver_1 = __K2L_RunCatching(function() return m:times(m) end):exceptionOrNull()
    print(__K2L_Str(____receiver_1 and ____receiver_1.message))
    local loads = 0
    local cache = Cache.new(2, function(k)
        loads = loads + 1
        return "v" .. k
    end)
    print(__K2L_Str(__K2L_ListOf(1, 2, 1, 3, 2, 1):map(function(it) return cache:get(it) end)))
    print("hits=" .. cache.hits .. " misses=" .. cache.misses .. " loads=" .. loads .. " keys=" .. __K2L_Str(cache:getKeys()))
    local g = Graph.new()
    local ____list_1 = __K2L_ListOf(__K2L_Pair.new("shirt", "tie"), __K2L_Pair.new("tie", "jacket"), __K2L_Pair.new("pants", "shoes"), __K2L_Pair.new("pants", "belt"), __K2L_Pair.new("belt", "jacket"), __K2L_Pair.new("shirt", "belt"))
    for ____i_8 = 1, ____list_1.size do
        local ____it_3 = ____list_1[____i_8]
        do
            local a, b = ____it_3.first, ____it_3.second
            g:edge(a, b)
        end
    end
    print(__K2L_Str(g:bfs("shirt")))
    print(__K2L_Str(g:topo()))
    g:edge("jacket", "shirt")
    local ____receiver_2 = __K2L_RunCatching(function() return g:topo() end):exceptionOrNull()
    print(__K2L_Str(____receiver_2 and ____receiver_2.message))
    local comparators = __K2L_ListOf(__K2L_NaturalOrder, __K2L_ReverseOrder, ____lambda_15)
    local versions = __K2L_ListOf(Version.new(2, 0), Version.new(1, 5), Version.new(1, 12))
    for ____i_9 = 1, comparators.size do
        local it = comparators[____i_9]
        print(__K2L_Str(versions:sortedWith(it)))
    end
end

__K2L_RunMain(main)
return {Source = Source, Sink = Sink, Vec = Vec, putAll = putAll, maxOrNull = maxOrNull, copy = copy, Matrix = Matrix, Cache = Cache, Graph = Graph, Version = Version}
