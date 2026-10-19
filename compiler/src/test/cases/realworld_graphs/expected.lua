local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_GenerateSequence = ____lualib.__K2L_GenerateSequence
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
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

function Graph:addEdge(from, to, weight)
    if weight == nil then
        weight = 1
    end
    self.adj:getOrPut(from, function() return __K2L_ListOf() end):add(__K2L_Pair.new(to, weight))
    local back = self.adj:getOrPut(to, function() return __K2L_ListOf() end)
    if not self.directed then
        back:add(__K2L_Pair.new(from, weight))
    end
end

function Graph:edges(from)
    return self.adj:get(from) or __K2L_ListOf()
end

function Graph:allEdges()
    return self.adj:flatMap(function(____destructured)
        local from, list = ____destructured.key, ____destructured.value
        return list:map(function(____destructured_1)
            local to, w = ____destructured_1.first, ____destructured_1.second
            return __K2L_Triple.new(from, to, w)
        end)
    end):filter(function(it)
        return self.directed or __K2L_Compare(it.first, it.second) <= 0
    end)
end

function Graph:toString()
    return self.adj:getEntries():joinToString("; ", nil, nil, nil, nil, function(____destructured_2)
        local k, v = ____destructured_2.key, ____destructured_2.value
        return __K2L_Str(k) .. "->" .. v:joinToString(",", nil, nil, nil, nil, function(it) return __K2L_Str(it.first) end)
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
            error(CycleException.new(stack:subList(stack:indexOf(n), stack.size):plus(n):map(function(it) return __K2L_Str(it) end)))
        end
        state:set(n, 1)
        stack:add(n)
        local ____list = self:edges(n)
        for ____i = 1, ____list.size do
            local ____it = ____list[____i]
            do
                local m = ____it.first
                visit(m)
            end
        end
        stack:removeAt(stack.size - 1)
        state:set(n, 2)
        order:addFirst(n)
    end
    local ____list_1 = self:getNodes():toList()
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1]
        visit(it)
    end
    return order:toList()
end

local UnionFind = __K2L_Class("UnionFind")

function UnionFind:____init(n)
    self.parent = __K2L_ListOfSize(n, function(it) return it end, true)
    self.rank = __K2L_ListOfSize(n, 0, true)
    self.components = n
end

function UnionFind:find(x)
    local root = x
    while self.parent:get(root) ~= root do
        root = self.parent:get(root)
    end
    local cur = x
    while self.parent:get(cur) ~= root do
        local ____next = self.parent:get(cur)
        local ____object = self.parent
        local ____key = cur
        ____object:set(____key, root)
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
    if self.rank:get(ra) < self.rank:get(rb) then
        local ____value = rb
        rb = ra
        ra = ____value
    end
    local ____object_1 = self.parent
    local ____key_1 = rb
    ____object_1:set(____key_1, ra)
    if self.rank:get(ra) == self.rank:get(rb) then
        local ____object_2 = self.rank
        local ____key_2 = ra
        ____object_2:set(____key_2, ____object_2:get(____key_2) + 1)
    end
    self.components = self.components - 1
    return true
end

local function kruskal(____this)
    local index = ____this:getNodes():withIndex():associate(function(____destructured_3)
        local i, n = ____destructured_3.index, ____destructured_3.value
        return __K2L_Pair.new(n, i)
    end)
    local uf = UnionFind.new(index.size)
    return ____this:allEdges():sortedWith(__K2L_CompareBy(function(it) return it.third end, function(it) return it.first end, function(it) return it.second end)):filter(function(____destructured_4)
        local a, b = ____destructured_4.first, ____destructured_4.second
        return uf:union(index:getValue(a), index:getValue(b))
    end)
end

local function dijkstra(____this_1, source)
    local dist = __K2L_MapOf(__K2L_Pair.new(source, 0))
    local prev = __K2L_MapOf()
    local queue = __K2L_PriorityQueue.new(__K2L_ThenBy(__K2L_CompareBy(function(it) return it.second end), function(it) return it.first end))
    queue:add(__K2L_Pair.new(source, 0))
    while queue:isNotEmpty() do
        do
            local ____destructured_5 = queue:poll()
            local u, d = ____destructured_5.first, ____destructured_5.second
            if d > dist:getValue(u) then
                goto ____continue
            end
            local ____list_2 = ____this_1:edges(u)
            for ____i_2 = 1, ____list_2.size do
                local ____item = ____list_2[____i_2]
                local v, w = ____item.first, ____item.second
                local nd = d + w
                if nd < (dist:get(v) or 2147483647) then
                    dist:set(v, nd)
                    prev:set(v, u)
                    queue:add(__K2L_Pair.new(v, nd))
                end
            end
        end
        ::____continue::
    end
    return dist:getKeys():sorted():associateWith(function(node)
        local path = __K2L_GenerateSequence(node, function(it) return prev:get(it) end):toList():asReversed()
        return __K2L_Pair.new(dist:getValue(node), path)
    end)
end

local function floydWarshall(n, edges)
    local inf = __K2L_IDiv(9223372036854775807, 4)
    local d = __K2L_ListOfSize(n, function(i)
        return __K2L_ListOfSize(n, function(j) return i == j and 0 or inf end, true)
    end, true)
    for ____i_3 = 1, edges.size do
        local ____item_1 = edges[____i_3]
        local a, b, w = ____item_1.first, ____item_1.second, ____item_1.third
        local ____object_3 = d:get(a)
        ____object_3:set(b, math.min(d:get(a):get(b), w))
    end
    for k = 0, n - 1 do
        for i = 0, n - 1 do
            for j = 0, n - 1 do
                if d:get(i):get(k) + d:get(k):get(j) < d:get(i):get(j) then
                    local ____object_4 = d:get(i)
                    ____object_4:set(j, d:get(i):get(k) + d:get(k):get(j))
                end
            end
        end
    end
    return d
end

local function tarjan(n, edges)
    local adj = __K2L_ListOfSize(n, function(it) return __K2L_ListOf() end)
    for ____i_4 = 1, edges.size do
        local ____it_2 = edges[____i_4]
        do
            local a, b = ____it_2.first, ____it_2.second
            adj:get(a):add(b)
        end
    end
    local counter = 0
    local index = __K2L_ListOfSize(n, function(it) return -1 end, true)
    local low = __K2L_ListOfSize(n, 0, true)
    local onStack = __K2L_ListOfSize(n, false, true)
    local stack = __K2L_ArrayDeque.new()
    local result = __K2L_ListOf()
    local function strong(v)
        index:set(v, counter)
        low:set(v, counter)
        counter = counter + 1
        stack:addLast(v)
        onStack:set(v, true)
        local ____list_3 = adj:get(v)
        for ____i_5 = 1, ____list_3.size do
            local w = ____list_3[____i_5]
            if index:get(w) == -1 then
                strong(w)
                low:set(v, math.min(low:get(v), low:get(w)))
            elseif onStack:get(w) then
                low:set(v, math.min(low:get(v), index:get(w)))
            end
        end
        if low:get(v) == index:get(v) then
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
        if index:get(v) == -1 then
            strong(v)
        end
    end
    return result:sortedBy(function(it) return it:first() end)
end

local TASKS = __K2L_Text.trimIndent("\n    wake -> shower\n    wake -> coffee\n    coffee -> breakfast\n    shower -> dress\n    dress -> leave\n    breakfast -> leave\n    leave -> commute\n")
local ROADS = "\n    A-B 7, A-D 5, B-C 8, B-D 9, B-E 7, C-E 5,\n    D-E 15, D-F 6, E-F 8, E-G 9, F-G 11\n"

local function main()
    local tasks = Graph.new(true)
    local ____list_4 = __K2L_StringLines(TASKS):map(function(it) return __K2L_StringSplit(it, " -> ") end)
    for ____i_6 = 1, ____list_4.size do
        local ____it_3 = ____list_4[____i_6]
        do
            local a, b = ____it_3[1], ____it_3[2]
            tasks:addEdge(a, b)
        end
    end
    print("tasks: " .. __K2L_Str(tasks))
    print("order: " .. __K2L_Str(topoSort(tasks)))
    tasks:addEdge("commute", "wake")
    local ____ok, ____result = pcall(function()
        topoSort(tasks)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, CycleException) then
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
            local ____destructured_6 = m.destructured
            local a, b, w = ____destructured_6[1], ____destructured_6[2], ____destructured_6[3]
            roads:addEdge(__K2L_Text.single(a), __K2L_Text.single(b), __K2L_StringToInt(w))
        end
    end
    print("roads: " .. roads:allEdges().size .. " edges between " .. __K2L_Str(roads:getNodes()))
    local mst = kruskal(roads)
    print("mst: " .. mst:joinToString(nil, nil, nil, nil, nil, function(____destructured_7)
        local a, b, w = ____destructured_7.first, ____destructured_7.second, ____destructured_7.third
        return a .. b .. "(" .. w .. ")"
    end) .. " total=" .. mst:sumOf(function(it) return it.third end))
    local routes = dijkstra(roads, "A")
    for node, info in routes:iter() do
        local dist, path = info.first, info.second
        print("  A to " .. node .. ": " .. __K2L_StringPadStart(tostring(dist), 2) .. " via " .. path:joinToString(""))
    end
    local farthest = routes:getEntries():maxWith(__K2L_ThenByDescending(__K2L_CompareBy(function(it) return it.value.first end), function(it) return it.key end))
    print("farthest from A: " .. farthest.key .. " at " .. farthest.value.first)
    local fwEdges = __K2L_ReadOnlyListOf(__K2L_Triple.new(0, 1, 3), __K2L_Triple.new(1, 2, 1), __K2L_Triple.new(2, 0, 2), __K2L_Triple.new(2, 3, 7), __K2L_Triple.new(3, 4, 1), __K2L_Triple.new(0, 3, 15))
    local d = floydWarshall(5, fwEdges)
    for ____i_7 = 1, d.size do
        local row = d[____i_7]
        print(row:joinToString(" ", nil, nil, nil, nil, function(it)
            return it >= __K2L_IDiv(9223372036854775807, 4) and "  ∞" or __K2L_StringPadStart(tostring(it), 3)
        end))
    end
    local reachable = d:getIndices():associateWith(function(i)
        return d:get(i):getIndices():count(function(j)
            return d:get(i):get(j) < __K2L_IDiv(9223372036854775807, 4)
        end)
    end)
    print("reachable counts: " .. __K2L_Str(reachable))
    local sccEdges = __K2L_ReadOnlyListOf(__K2L_Pair.new(0, 1), __K2L_Pair.new(1, 2), __K2L_Pair.new(2, 0), __K2L_Pair.new(2, 3), __K2L_Pair.new(3, 4), __K2L_Pair.new(4, 5), __K2L_Pair.new(5, 3), __K2L_Pair.new(6, 5), __K2L_Pair.new(6, 7), __K2L_Pair.new(7, 6), __K2L_Pair.new(8, 8))
    local sccs = tarjan(9, sccEdges)
    print("sccs: " .. __K2L_Str(sccs) .. " (" .. sccs:count(function(it) return it.size > 1 end) .. " non-trivial)")
    local uf = UnionFind.new(10)
    local ____list_5 = __K2L_ReadOnlyListOf(__K2L_Pair.new(1, 2), __K2L_Pair.new(3, 4), __K2L_Pair.new(2, 3), __K2L_Pair.new(5, 6), __K2L_Pair.new(7, 7), __K2L_Pair.new(9, 0), __K2L_Pair.new(4, 1))
    for ____i_8 = 1, ____list_5.size do
        local ____it_4 = ____list_5[____i_8]
        do
            local a, b = ____it_4.first, ____it_4.second
            local merged = uf:union(a, b)
            if not merged then
                print("  " .. a .. " and " .. b .. " already connected")
            end
        end
    end
    local groups = __K2L_IntRange.new(0, 10 - 1):groupBy(function(...) return uf:find(...) end):getValues():map(function(it) return it:sorted() end):sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it.size end), function(it) return it:first() end))
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
    print("grid distances: " .. __K2L_Str(gr:mapValues(function(it) return it.value.first end)))
    print("path to 8: " .. __K2L_Str(gr:getValue(8).second))
    local degrees = grid:getNodes():associateWith(function(it) return grid:edges(it).size end):getEntries():groupBy(function(it) return it.value end, function(it) return it.key end):toSortedMap()
    print("nodes by degree: " .. __K2L_Str(degrees))
end

main()
return {Graph = Graph, CycleException = CycleException, topoSort = topoSort, UnionFind = UnionFind, kruskal = kruskal, dijkstra = dijkstra, floydWarshall = floydWarshall, tarjan = tarjan, TASKS = TASKS, ROADS = ROADS}
