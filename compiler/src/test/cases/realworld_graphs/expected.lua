local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SortedMap = ____lualib.__K2L_SortedMap
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ThenByDescending = ____lualib.__K2L_ThenByDescending
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple

local Graph = __K2L_Class("Graph")

function Graph:____init(directed)
    self.directed = directed
    self.adj = __K2L_SortedMap.new()
end

function Graph:getNodes()
    return self.adj:getKeys()
end

local ____lambda_1 = function() return __K2L_ListOf() end
local ____lambda_2 = function() return __K2L_ListOf() end
function Graph:addEdge(from, to, weight)
    if weight == nil then
        weight = 1
    end
    self.adj:getOrPut(from, ____lambda_1):add(__K2L_Pair.new(to, weight))
    local back = self.adj:getOrPut(to, ____lambda_2)
    if not self.directed then
        back:add(__K2L_Pair.new(from, weight))
    end
end

function Graph:edges(from)
    return self.adj:get(from) or __K2L_ReadOnlyListOf()
end

function Graph:allEdges()
    local ____list = self.adj:flatMap(function(____destructured)
        local from, list = ____destructured.key, ____destructured.value
        local ____out = {}
        local ____count = 0
        local ____items, ____n = list:____array()
        for ____i = 1, ____n do
            local ____it = ____items[____i]
            local ____result
            do
                local to, w = ____it.first, ____it.second
                ____result = __K2L_Triple.new(from, to, w)
            end
            ____count = ____count + 1
            ____out[____count] = ____result
        end
        return __K2L_ListWrap(____out, ____count)
    end)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        if self.directed or __K2L_Compare(it.first, it.second) <= 0 then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    return __K2L_ListWrap(____out_1, ____count_1)
end

local ____lambda_3 = function(it) return __K2L_Str(it.first) end
function Graph:toString()
    return self.adj:getEntries():joinToString("; ", nil, nil, nil, nil, function(____destructured_1)
        local k, v = ____destructured_1.key, ____destructured_1.value
        return __K2L_Str(k) .. "->" .. v:joinToString(",", nil, nil, nil, nil, ____lambda_3)
    end)
end

local CycleException = __K2L_Class("CycleException", __K2L_Exception)

function CycleException:____init(cycle)
    __K2L_Exception.____init(self, "cycle: " .. cycle:joinToString(" -> "))
    self.cycle = cycle
end

local function topoSort(self)
    local state = __K2L_HashMap.new()
    local order = __K2L_ArrayDeque.new()
    local stack = __K2L_List.new()
    local function visit(n)
        local ____subject = state:get(n)
        if ____subject == 2 then
            return
        elseif ____subject == 1 then
            local ____list_1 = stack:subList(stack:indexOf(n), stack.size):plus(n)
            local ____out_2 = {}
            local ____count_2 = 0
            local ____items_2, ____n_2 = ____list_1:____array()
            for ____i_2 = 1, ____n_2 do
                local it = ____items_2[____i_2]
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = __K2L_Str(it)
            end
            error(CycleException.new(__K2L_ListWrap(____out_2, ____count_2)))
        end
        state:set(n, 1)
        stack:add(n)
        local ____list_2 = self:edges(n)
        local ____mod = ____list_2.____modCount
        for ____i_3 = 1, ____list_2.size do
            local ____it_1 = ____list_2[____i_3]
            do
                local m = ____it_1.first
                visit(m)
            end
            if ____list_2.____modCount ~= ____mod and ____list_2:____comodified(____i_3) then
                break
            end
        end
        stack:removeAt(stack.size - 1)
        state:set(n, 2)
        order:addFirst(n)
    end
    local ____collection = self:getNodes()
    local ____items_3, ____n_3 = ____collection:____array()
    local ____mod_1 = ____collection.____modCount
    for ____i_4 = 1, ____n_3 do
        local it = ____items_3[____i_4]
        visit(it)
        if ____collection.____modCount ~= ____mod_1 and ____collection:____comodified(____i_4, ____n_3) then
            break
        end
    end
    return order:toList()
end

local UnionFind = __K2L_Class("UnionFind")

local ____lambda_4 = function(it) return it end
function UnionFind:____init(n)
    self.parent = __K2L_ListOfSize(n, ____lambda_4, "[I")
    self.rank = __K2L_ListOfSize(n, 0, "[I")
    self.components = n
end

function UnionFind:find(x)
    local root = x
    while (self.parent[root + 1] or __K2L_IndexError(root, self.parent.size, "array")) ~= root do
        root = self.parent[root + 1] or __K2L_IndexError(root, self.parent.size, "array")
    end
    local cur = x
    while (self.parent[cur + 1] or __K2L_IndexError(cur, self.parent.size, "array")) ~= root do
        local ____next = self.parent[cur + 1] or __K2L_IndexError(cur, self.parent.size, "array")
        local ____object = self.parent
        local ____key = cur
        if ____key < 0 or ____key >= ____object.size then
            __K2L_IndexError(____key, ____object.size, "array")
        end
        ____object[____key + 1] = root
        cur = ____next
    end
    return root
end

function UnionFind:union(a, b)
    local ra = self:find(a)
    local rb = self:find(b)
    if ra == rb then
        return false
    end
    if (self.rank[ra + 1] or __K2L_IndexError(ra, self.rank.size, "array")) < (self.rank[rb + 1] or __K2L_IndexError(rb, self.rank.size, "array")) then
        local ____value = rb
        rb = ra
        ra = ____value
    end
    local ____object_1 = self.parent
    local ____key_1 = rb
    if ____key_1 < 0 or ____key_1 >= ____object_1.size then
        __K2L_IndexError(____key_1, ____object_1.size, "array")
    end
    ____object_1[____key_1 + 1] = ra
    if (self.rank[ra + 1] or __K2L_IndexError(ra, self.rank.size, "array")) == (self.rank[rb + 1] or __K2L_IndexError(rb, self.rank.size, "array")) then
        local ____object_2 = self.rank
        local ____key_2 = ra
        ____object_2[____key_2 + 1] = (____object_2[____key_2 + 1] or __K2L_IndexError(____key_2, ____object_2.size, "array")) + 1
    end
    self.components = self.components - 1
    return true
end

local ____lambda_5 = function(it) return it.third end
local ____lambda_6 = function(it) return it.first end
local ____lambda_7 = function(it) return it.second end
local function kruskal(____this)
    local index = ____this:getNodes():withIndex():associate(function(____destructured_2)
        local i, n = ____destructured_2.index, ____destructured_2.value
        return __K2L_Pair.new(n, i)
    end)
    local uf = UnionFind.new(index.size)
    local ____list_3 = ____this:allEdges():sortedWith(__K2L_CompareBy(____lambda_5, ____lambda_6, ____lambda_7))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_4, ____n_4 = ____list_3:____array()
    for ____i_5 = 1, ____n_4 do
        local ____it_3 = ____items_4[____i_5]
        local ____result_1
        do
            local a, b = ____it_3.first, ____it_3.second
            ____result_1 = uf:union(index:getValue(a), index:getValue(b))
        end
        if ____result_1 then
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = ____it_3
        end
    end
    return __K2L_ListWrap(____out_3, ____count_3)
end

local ____lambda_8 = function(it) return it.second end
local ____lambda_9 = function(it) return it.first end
local function dijkstra(____this_1, source)
    local dist = __K2L_MapOf(__K2L_Pair.new(source, 0))
    local prev = __K2L_MapOf()
    local queue = __K2L_PriorityQueue.new(__K2L_ThenBy(__K2L_CompareBy(____lambda_8), ____lambda_9))
    queue:add(__K2L_Pair.new(source, 0))
    while queue:isNotEmpty() do
        do
            local ____destructured_3 = queue:poll()
            local u, d = ____destructured_3.first, ____destructured_3.second
            if d > dist:getValue(u) then
                goto ____continue
            end
            local ____list_4 = ____this_1:edges(u)
            local ____mod_2 = ____list_4.____modCount
            for ____i_6 = 1, ____list_4.size do
                local ____item = ____list_4[____i_6]
                local v, w = ____item.first, ____item.second
                local nd = d + w
                if nd < (dist:get(v) or 2147483647) then
                    dist:set(v, nd)
                    prev:set(v, u)
                    queue:add(__K2L_Pair.new(v, nd))
                end
                if ____list_4.____modCount ~= ____mod_2 and ____list_4:____comodified(____i_6) then
                    break
                end
            end
        end
        ::____continue::
    end
    local ____list_5 = dist:getKeys():sorted()
    local ____result_2 = __K2L_Map.new()
    local ____items_5, ____n_5 = ____list_5:____array()
    for ____i_7 = 1, ____n_5 do
        local node = ____items_5[____i_7]
        local ____result_3
        do
            local path = __K2L_GenerateSequence(node, function(it) return prev:get(it) end):toList():asReversed()
            ____result_3 = __K2L_Pair.new(dist:getValue(node), path)
        end
        local ____value_1 = ____result_3
        ____result_2:put(node, ____value_1)
    end
    return ____result_2
end

local function floydWarshall(n, edges)
    local inf = __K2L_IDiv(9223372036854775807, 4)
    local d = __K2L_ListOfSize(n, function(i)
        return __K2L_ListOfSize(n, function(j) return i == j and 0 or inf end, "[J")
    end, "[[J")
    local ____mod_3 = edges.____modCount
    for ____i_8 = 1, edges.size do
        local ____item_1 = edges[____i_8]
        local a, b, w = ____item_1.first, ____item_1.second, ____item_1.third
        local ____object_3 = d:get(a)
        local ____value_2 = math.min(d:get(a):get(b), w)
        if b < 0 or b >= ____object_3.size then
            __K2L_IndexError(b, ____object_3.size, "array")
        end
        ____object_3[b + 1] = ____value_2
        if edges.____modCount ~= ____mod_3 and edges:____comodified(____i_8) then
            break
        end
    end
    for k = 0, n - 1 do
        for i = 0, n - 1 do
            for j = 0, n - 1 do
                if d:get(i):get(k) + d:get(k):get(j) < d:get(i):get(j) then
                    local ____object_4 = d:get(i)
                    local ____value_3 = d:get(i):get(k) + d:get(k):get(j)
                    if j < 0 or j >= ____object_4.size then
                        __K2L_IndexError(j, ____object_4.size, "array")
                    end
                    ____object_4[j + 1] = ____value_3
                end
            end
        end
    end
    return d
end

local ____lambda_10 = function(it) return __K2L_ListOf() end
local ____lambda_11 = function(it) return -1 end
local ____lambda_12 = function(it) return it:first() end
local function tarjan(n, edges)
    local adj = __K2L_ListOfSize(n, ____lambda_10)
    local ____mod_4 = edges.____modCount
    for ____i_9 = 1, edges.size do
        local ____it_4 = edges[____i_9]
        do
            local a, b = ____it_4.first, ____it_4.second
            adj:get(a):add(b)
        end
        if edges.____modCount ~= ____mod_4 and edges:____comodified(____i_9) then
            break
        end
    end
    local counter = 0
    local index = __K2L_ListOfSize(n, ____lambda_11, "[I")
    local low = __K2L_ListOfSize(n, 0, "[I")
    local onStack = __K2L_ListOfSize(n, false, "[Z")
    local stack = __K2L_ArrayDeque.new()
    local result = __K2L_ListOf()
    local function strong(v)
        if v < 0 or v >= index.size then
            __K2L_IndexError(v, index.size, "array")
        end
        index[v + 1] = counter
        if v < 0 or v >= low.size then
            __K2L_IndexError(v, low.size, "array")
        end
        low[v + 1] = counter
        counter = counter + 1
        stack:addLast(v)
        onStack:set(v, true)
        local ____list_6 = adj:get(v)
        local ____mod_5 = ____list_6.____modCount
        for ____i_10 = 1, ____list_6.size do
            local w = ____list_6[____i_10]
            if (index[w + 1] or __K2L_IndexError(w, index.size, "array")) == -1 then
                strong(w)
                local ____value_4 = math.min(low[v + 1] or __K2L_IndexError(v, low.size, "array"), low[w + 1] or __K2L_IndexError(w, low.size, "array"))
                if v < 0 or v >= low.size then
                    __K2L_IndexError(v, low.size, "array")
                end
                low[v + 1] = ____value_4
            elseif onStack:get(w) then
                local ____value_5 = math.min(low[v + 1] or __K2L_IndexError(v, low.size, "array"), index[w + 1] or __K2L_IndexError(w, index.size, "array"))
                if v < 0 or v >= low.size then
                    __K2L_IndexError(v, low.size, "array")
                end
                low[v + 1] = ____value_5
            end
            if ____list_6.____modCount ~= ____mod_5 and ____list_6:____comodified(____i_10) then
                break
            end
        end
        if (low[v + 1] or __K2L_IndexError(v, low.size, "array")) == (index[v + 1] or __K2L_IndexError(v, index.size, "array")) then
            local comp = __K2L_ListOf()
            repeat
                local w = stack:removeLast()
                onStack:set(w, false)
                comp:add(w)
            until w == v
            result:add(comp:sorted())
        end
    end
    for v = 0, n - 1 do
        if (index[v + 1] or __K2L_IndexError(v, index.size, "array")) == -1 then
            strong(v)
        end
    end
    return result:sortedBy(____lambda_12)
end

local TASKS = __K2L_Text.trimIndent("\n    wake -> shower\n    wake -> coffee\n    coffee -> breakfast\n    shower -> dress\n    dress -> leave\n    breakfast -> leave\n    leave -> commute\n")
local ROADS = "\n    A-B 7, A-D 5, B-C 8, B-D 9, B-E 7, C-E 5,\n    D-E 15, D-F 6, E-F 8, E-G 9, F-G 11\n"

local ____lambda_13 = function(it) return it.value.first end
local ____lambda_14 = function(it) return it.key end
local ____lambda_15 = function(it)
    return it >= __K2L_IDiv(9223372036854775807, 4) and "  ∞" or __K2L_StringPadStart(tostring(it), 3)
end
local ____lambda_16 = function(it) return it.size end
local ____lambda_17 = function(it) return it:first() end
local ____lambda_18 = function(it) return it.value.first end
local function main()
    local tasks = Graph.new(true)
    local ____list_7 = __K2L_StringLines(TASKS)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_6, ____n_6 = ____list_7:____array()
    for ____i_11 = 1, ____n_6 do
        local it = ____items_6[____i_11]
        ____count_4 = ____count_4 + 1
        ____out_4[____count_4] = __K2L_StringSplit(it, " -> ")
    end
    local ____list_8 = __K2L_ListWrap(____out_4, ____count_4)
    local ____mod_6 = ____list_8.____modCount
    for ____i_12 = 1, ____list_8.size do
        local ____it_5 = ____list_8[____i_12]
        do
            local a, b = ____it_5[1], ____it_5[2]
            tasks:addEdge(a, b)
        end
        if ____list_8.____modCount ~= ____mod_6 and ____list_8:____comodified(____i_12) then
            break
        end
    end
    print("tasks: " .. __K2L_Str(tasks))
    print("order: " .. __K2L_Str(topoSort(tasks)))
    tasks:addEdge("commute", "wake")
    local ____ok, ____result_4 = __K2L_DeepPcall(function()
        topoSort(tasks)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_4)
        if getmetatable(____error) == CycleException then
            local e = ____error
            print("caught " .. __K2L_Str(e.message) .. " (" .. e.cycle.size - 1 .. " edges)")
        else
            error(____error, 0)
        end
    end
    local roads = Graph.new(false)
    local edgePattern = __K2L_Regex.new("([A-Z])-([A-Z]) (\\d+)")
    for _, m in __K2L_Sequence.new(edgePattern:findAllFactory(ROADS)):iter() do
        do
            local ____destructured_4 = m.destructured
            local a, b, w = ____destructured_4[1], ____destructured_4[2], ____destructured_4[3]
            roads:addEdge(__K2L_Text.single(a), __K2L_Text.single(b), __K2L_StringToInt(w))
        end
    end
    print("roads: " .. roads:allEdges().size .. " edges between " .. __K2L_Str(roads:getNodes()))
    local mst = kruskal(roads)
    local ____arg = mst:joinToString(nil, nil, nil, nil, nil, function(____destructured_5)
        local a, b, w = ____destructured_5.first, ____destructured_5.second, ____destructured_5.third
        return a .. b .. "(" .. w .. ")"
    end)
    local ____sum = 0
    local ____items_7, ____n_7 = mst:____array()
    for ____i_13 = 1, ____n_7 do
        local it = ____items_7[____i_13]
        ____sum = ____sum + it.third
    end
    print("mst: " .. ____arg .. " total=" .. ____sum)
    local routes = dijkstra(roads, "A")
    local ____keys, ____values, ____n_8 = routes:____arrays()
    local ____mod_7 = routes.____modCount
    for ____i_14 = 1, ____n_8 do
        local node, info = ____keys[____i_14], ____values[____i_14]
        local dist, path = info.first, info.second
        print("  A to " .. node .. ": " .. __K2L_StringPadStart(tostring(dist), 2) .. " via " .. path:joinToString(""))
        if routes.____modCount ~= ____mod_7 and routes:____comodified(____i_14, ____n_8) then
            break
        end
    end
    local farthest = routes:getEntries():maxWith(__K2L_ThenByDescending(__K2L_CompareBy(____lambda_13), ____lambda_14))
    print("farthest from A: " .. farthest.key .. " at " .. farthest.value.first)
    local fwEdges = __K2L_ReadOnlyListOf(__K2L_Triple.new(0, 1, 3), __K2L_Triple.new(1, 2, 1), __K2L_Triple.new(2, 0, 2), __K2L_Triple.new(2, 3, 7), __K2L_Triple.new(3, 4, 1), __K2L_Triple.new(0, 3, 15))
    local d = floydWarshall(5, fwEdges)
    for ____i_15 = 1, d.size do
        local row = d[____i_15]
        print(row:joinToString(" ", nil, nil, nil, nil, ____lambda_15))
    end
    local reachable = d:getIndices():associateWith(function(i)
        return d:get(i):getIndices():count(function(j)
            return d:get(i):get(j) < __K2L_IDiv(9223372036854775807, 4)
        end)
    end)
    print("reachable counts: " .. __K2L_Str(reachable))
    local sccEdges = __K2L_ReadOnlyListOf(__K2L_Pair.new(0, 1), __K2L_Pair.new(1, 2), __K2L_Pair.new(2, 0), __K2L_Pair.new(2, 3), __K2L_Pair.new(3, 4), __K2L_Pair.new(4, 5), __K2L_Pair.new(5, 3), __K2L_Pair.new(6, 5), __K2L_Pair.new(6, 7), __K2L_Pair.new(7, 6), __K2L_Pair.new(8, 8))
    local sccs = tarjan(9, sccEdges)
    local ____arg_1 = __K2L_Str(sccs)
    local ____result_5 = 0
    local ____items_8, ____n_9 = sccs:____array()
    for ____i_16 = 1, ____n_9 do
        local it = ____items_8[____i_16]
        if it.size > 1 then
            ____result_5 = ____result_5 + 1
        end
    end
    print("sccs: " .. ____arg_1 .. " (" .. ____result_5 .. " non-trivial)")
    local uf = UnionFind.new(10)
    local ____list_9 = __K2L_ReadOnlyListOf(__K2L_Pair.new(1, 2), __K2L_Pair.new(3, 4), __K2L_Pair.new(2, 3), __K2L_Pair.new(5, 6), __K2L_Pair.new(7, 7), __K2L_Pair.new(9, 0), __K2L_Pair.new(4, 1))
    local ____mod_8 = ____list_9.____modCount
    for ____i_17 = 1, ____list_9.size do
        local ____it_6 = ____list_9[____i_17]
        do
            local a, b = ____it_6.first, ____it_6.second
            local merged = uf:union(a, b)
            if not merged then
                print("  " .. a .. " and " .. b .. " already connected")
            end
        end
        if ____list_9.____modCount ~= ____mod_8 and ____list_9:____comodified(____i_17) then
            break
        end
    end
    local ____list_10 = __K2L_IntRange.new(0, 10 - 1):groupBy(function(...) return uf:find(...) end):getValues()
    local ____out_5 = {}
    local ____count_5 = 0
    local ____items_9, ____n_10 = ____list_10:____array()
    for ____i_18 = 1, ____n_10 do
        local it = ____items_9[____i_18]
        ____count_5 = ____count_5 + 1
        ____out_5[____count_5] = it:sorted()
    end
    local groups = __K2L_ListWrap(____out_5, ____count_5):sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(____lambda_16), ____lambda_17))
    print("components=" .. uf.components .. " groups=" .. __K2L_Str(groups))
    local grid = Graph.new(false)
    for r = 0, 2 do
        for c = 0, 2 do
            local id = r * 3 + c
            if c < 2 then
                grid:addEdge(id, id + 1, (r + 1) * (c + 2))
            end
            if r < 2 then
                grid:addEdge(id, id + 3, (c + 1) * (r + 2))
            end
        end
    end
    local gr = dijkstra(grid, 0)
    print("grid distances: " .. __K2L_Str(gr:mapValues(____lambda_18)))
    print("path to 8: " .. __K2L_Str(gr:getValue(8).second))
    local ____list_11 = grid:getNodes()
    local ____result_6 = __K2L_Map.new()
    local ____items_10, ____n_11 = ____list_11:____array()
    for ____i_19 = 1, ____n_11 do
        local it = ____items_10[____i_19]
        local ____value_6 = grid:edges(it).size
        ____result_6:put(it, ____value_6)
    end
    local ____list_12 = ____result_6:getEntries()
    local ____result_7 = __K2L_Map.new()
    local ____items_11, ____n_12 = ____list_12:____array()
    for ____i_20 = 1, ____n_12 do
        local it = ____items_11[____i_20]
        local ____value_7 = it.value
        local ____group = ____result_7:get(____value_7)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_7:put(____value_7, ____group)
        end
        ____group:add(it.key)
    end
    local degrees = ____result_7:toSortedMap()
    print("nodes by degree: " .. __K2L_Str(degrees))
end

__K2L_DeepMain(main)
return {Graph = Graph, CycleException = CycleException, topoSort = topoSort, UnionFind = UnionFind, kruskal = kruskal, dijkstra = dijkstra, floydWarshall = floydWarshall, tarjan = tarjan, TASKS = TASKS, ROADS = ROADS}
