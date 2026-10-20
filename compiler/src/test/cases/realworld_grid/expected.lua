local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareValues = ____lualib.__K2L_CompareValues
local __K2L_EnumValues = ____lualib.__K2L_EnumValues
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_HashSet = ____lualib.__K2L_HashSet
local __K2L_IRem = ____lualib.__K2L_IRem
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_Text = ____lualib.__K2L_Text

local Dir
local Pos = __K2L_Class("Pos")

function Pos:____init(row, col)
    self.row = row
    self.col = col
end

function Pos.new(row, col)
    return setmetatable({row = row, col = col}, Pos)
end

function Pos:plus(d)
    return Pos.new(self.row + d.dr, self.col + d.dc)
end

function Pos:manhattan(other)
    return math.abs(self.row - other.row) + math.abs(self.col - other.col)
end

function Pos:toString()
    return "(" .. self.row .. "," .. self.col .. ")"
end

function Pos:hashCode()
    return (31 * self.row + self.col + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Pos:equals(other)
    return getmetatable(other) == Pos and self.row == other.row and self.col == other.col
end

Dir = __K2L_Class("Dir")

function Dir:____init(name, ordinal, dr, dc, symbol)
    self.name = name
    self.ordinal = ordinal
    self.dr = dr
    self.dc = dc
    self.symbol = symbol
end

function Dir:turnRight()
    local ____values = Dir.____values
    local ____index = __K2L_IRem(self.ordinal + 1, __K2L_EnumValues(Dir).size)
    return ____values[____index + 1] or __K2L_IndexError(____index, #____values)
end

function Dir:turnLeft()
    local ____values_1 = Dir.____values
    local ____index_1 = __K2L_IRem(self.ordinal + 3, __K2L_EnumValues(Dir).size)
    return ____values_1[____index_1 + 1] or __K2L_IndexError(____index_1, #____values_1)
end

function Dir:toString()
    return self.name
end

function Dir:compareTo(other)
    return self.ordinal - other.ordinal
end

Dir.UP = Dir.new("UP", 0, -1, 0, "^")
Dir.RIGHT = Dir.new("RIGHT", 1, 0, 1, ">")
Dir.DOWN = Dir.new("DOWN", 2, 1, 0, "v")
Dir.LEFT = Dir.new("LEFT", 3, 0, -1, "<")
Dir.____values = {Dir.UP, Dir.RIGHT, Dir.DOWN, Dir.LEFT}
Dir.____companion = true

function Dir:of(c)
    local ____values_2 = Dir.____values
    local ____result
    for ____i = 1, #____values_2 do
        local it = ____values_2[____i]
        if it.symbol == c then
            ____result = it
            break
        end
    end
    return ____result
end

local Grid = __K2L_Class("Grid")

function Grid:____init(cells)
    self.cells = cells
end

function Grid.new(cells)
    return setmetatable({cells = cells}, Grid)
end

function Grid:getHeight()
    return self.cells.size
end

function Grid:getWidth()
    return self.cells:get(0).size
end

function Grid:get(p)
    local ____receiver = self.cells:getOrNull(p.row)
    return ____receiver and ____receiver:getOrNull(p.col)
end

function Grid:set(p, c)
    local ____object = self.cells:get(p.row)
    local ____key = p.col
    if ____key < 0 or ____key >= ____object.size then
        __K2L_IndexError(____key, ____object.size, "array")
    end
    ____object[____key + 1] = c
end

function Grid:contains(p)
    local ____bound = self:getHeight()
    local ____value = p.row
    local ____cond = ____value >= 0 and ____value < ____bound
    if ____cond then
        local ____bound_1 = self:getWidth()
        local ____value_1 = p.col
        ____cond = ____value_1 >= 0 and ____value_1 < ____bound_1
    end
    return ____cond
end

function Grid:positions()
    return __K2L_SequenceBuilder(function(____this)
        for r = 0, self:getHeight() - 1 do
            for c = 0, self:getWidth() - 1 do
                ____this:yield(Pos.new(r, c))
            end
        end
    end)
end

function Grid:find(c)
    return self:positions():first(function(it) return self:get(it) == c end)
end

function Grid:neighbours(p)
    local ____values_3 = Dir.____values
    local ____out = {}
    local ____count = 0
    for ____i_1 = 1, #____values_3 do
        local it = ____values_3[____i_1]
        ____count = ____count + 1
        ____out[____count] = p:plus(it)
    end
    local ____list = __K2L_ListWrap(____out, ____count)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items, ____n = ____list:____array()
    for ____i_2 = 1, ____n do
        local it = ____items[____i_2]
        if self:contains(it) then
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = it
        end
    end
    return __K2L_ListWrap(____out_1, ____count_1)
end

function Grid:copy()
    local ____list_1 = self.cells
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_3 = 1, ____n_1 do
        local it = ____items_1[____i_3]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = it:toTypedArray()
    end
    return Grid.new(__K2L_ListWrap(____out_2, ____count_2))
end

local ____lambda_1 = function(it) return __K2L_Text.string(it) end
function Grid:render()
    return self.cells:joinToString("\n", nil, nil, nil, nil, ____lambda_1)
end

function Grid:parse(text)
    local ____list_2 = __K2L_StringLines(__K2L_Text.trimIndent(text))
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_4 = 1, ____n_2 do
        local it = ____items_2[____i_4]
        ____count_3 = ____count_3 + 1
        ____out_3[____count_3] = __K2L_Text.toCharArray(it)
    end
    return Grid.new(__K2L_ListWrap(____out_3, ____count_3))
end

local MAZE = "\n    #################\n    #S..#.....#.....#\n    #.#.#.###.#.###.#\n    #.#...#...#...#.#\n    #.#####.#####.#.#\n    #.....#.....#.#.#\n    #####.#####.#.#.#\n    #...#.....#...#E#\n    #.#.#####.#####.#\n    #.#.......#.....#\n    #################\n"

local function bfs(grid, start, goal)
    local previous = __K2L_HashMap.new()
    local queue = __K2L_ArrayDeque.new()
    local seen = __K2L_SetOf(start)
    queue:addLast(start)
    while queue:isNotEmpty() do
        local cur = queue:removeFirst()
        if cur:equals(goal) then
            local path = __K2L_ListOf(cur)
            local p = cur
            while not p:equals(start) do
                p = previous:getValue(p)
                path:add(p)
            end
            return path:asReversed()
        end
        local ____list_3 = grid:neighbours(cur)
        local ____mod = ____list_3.____modCount
        for ____i_5 = 1, ____list_3.size do
            local n = ____list_3[____i_5]
            do
                if grid:get(n) == "#" or not seen:add(n) then
                    goto ____continue
                end
                previous:set(n, cur)
                queue:addLast(n)
            end
            ::____continue::
            if ____list_3.____modCount ~= ____mod and ____list_3:____comodified(____i_5) then
                break
            end
        end
    end
    return nil
end

local State = __K2L_Class("State")

function State:____init(pos, dir)
    self.pos = pos
    self.dir = dir
end

function State.new(pos, dir)
    return setmetatable({pos = pos, dir = dir}, State)
end

function State:toString()
    return "State(pos=" .. __K2L_Str(self.pos) .. ", dir=" .. __K2L_Str(self.dir) .. ")"
end

function State:hashCode()
    return (31 * self.pos:hashCode() + __K2L_Hash(self.dir) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function State:equals(other)
    return getmetatable(other) == State and self.pos:equals(other.pos) and self.dir == other.dir
end

local ____lambda_2 = function(____a, ____b)
    local ____x, ____y = ____a.first, ____b.first
    if ____x ~= ____y then
        return ____x < ____y and -1 or 1
    end
    return 0
end
local function cheapestRoute(grid, start, goal)
    local best = __K2L_MapOf()
    local pq = __K2L_PriorityQueue.new(____lambda_2)
    local first = State.new(start, Dir.RIGHT)
    best:set(first, 0)
    pq:add(__K2L_Pair.new(0, first))
    while pq:isNotEmpty() do
        do
            local ____destructured = pq:poll()
            local cost, state = ____destructured.first, ____destructured.second
            if state.pos:equals(goal) then
                return cost
            end
            if cost > (best:get(state) or 2147483647) then
                goto ____continue_1
            end
            local moves = __K2L_ReadOnlyListOf(__K2L_Pair.new(State.new(state.pos:plus(state.dir), state.dir), 1), __K2L_Pair.new(State.new(state.pos, state.dir:turnLeft()), 1000), __K2L_Pair.new(State.new(state.pos, state.dir:turnRight()), 1000))
            local ____mod_1 = moves.____modCount
            for ____i_6 = 1, moves.size do
                local ____item = moves[____i_6]
                local ____next, step = ____item.first, ____item.second
                do
                    if grid:get(____next.pos) == "#" then
                        goto ____continue_2
                    end
                    local newCost = cost + step
                    if newCost < best:getOrDefault(____next, 2147483647) then
                        best:set(____next, newCost)
                        pq:offer(__K2L_Pair.new(newCost, ____next))
                    end
                end
                ::____continue_2::
                if moves.____modCount ~= ____mod_1 and moves:____comodified(____i_6) then
                    break
                end
            end
        end
        ::____continue_1::
    end
    return -1
end

local GARDEN = "\n    AAAABBC\n    AABBBCC\n    DDBEECC\n    DDDEEEF\n    GGDDFFF\n"
local Region = __K2L_Class("Region")

function Region:____init(plant, area, perimeter)
    self.plant = plant
    self.area = area
    self.perimeter = perimeter
end

function Region.new(plant, area, perimeter)
    return setmetatable({plant = plant, area = area, perimeter = perimeter}, Region)
end

function Region:getPrice()
    return self.area * self.perimeter
end

function Region:toString()
    return "Region(plant=" .. self.plant .. ", area=" .. self.area .. ", perimeter=" .. self.perimeter .. ")"
end

function Region:hashCode()
    return (31 * (31 * __K2L_Hash(self.plant) + self.area) + self.perimeter + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Region:equals(other)
    return getmetatable(other) == Region and self.plant == other.plant and self.area == other.area and self.perimeter == other.perimeter
end

local function regions(grid)
    local visited = __K2L_HashSet.new()
    local result = __K2L_ListOf()
    for _, start in grid:positions():iter() do
        do
            if visited:contains(start) then
                goto ____continue_3
            end
            local plant = __K2L_NotNull(grid:get(start))
            local area = 0
            local perimeter = 0
            local stack = __K2L_ArrayDeque.new(__K2L_SingletonListOf(start))
            visited:add(start)
            while stack:isNotEmpty() do
                local p = stack:removeLast()
                area = area + 1
                local ____values_4 = Dir.____values
                for ____i_7 = 1, #____values_4 do
                    local d = ____values_4[____i_7]
                    local n = p:plus(d)
                    if grid:get(n) ~= plant then
                        perimeter = perimeter + 1
                    elseif visited:add(n) then
                        stack:addLast(n)
                    end
                end
            end
            result:add(Region.new(plant, area, perimeter))
        end
        ::____continue_3::
    end
    return result
end

local PATROL = "\n    ....#.....\n    .........#\n    ..........\n    ..#.......\n    .......#..\n    ..........\n    .#..^.....\n    ........#.\n    #.........\n    ......#...\n"

local function patrol(grid)
    local pos = grid:positions():first(function(it)
        return Dir:of(__K2L_NotNull(grid:get(it))) ~= nil
    end)
    local dir = __K2L_NotNull(Dir:of(__K2L_NotNull(grid:get(pos))))
    local visited = __K2L_SetOf()
    local states = __K2L_SetOf()
    while true do
        visited:add(pos)
        if not states:add(State.new(pos, dir)) then
            return __K2L_Pair.new(visited.size, true)
        end
        local ahead = pos:plus(dir)
        local ____subject = grid:get(ahead)
        if ____subject == nil then
            return __K2L_Pair.new(visited.size, false)
        elseif ____subject == "#" or ____subject == "O" then
            dir = dir:turnRight()
        else
            pos = ahead
        end
    end
end

local ____lambda_3 = function(____a_1, ____b_1)
    local ____x_2, ____y_2 = ____b_1:getPrice(), ____a_1:getPrice()
    if ____x_2 ~= ____y_2 then
        return ____x_2 < ____y_2 and -1 or 1
    end
    return __K2L_CompareValues(____a_1.plant, ____b_1.plant)
end
local function main()
    local maze = Grid:parse(MAZE)
    print("maze " .. maze:getWidth() .. "x" .. maze:getHeight())
    local start = maze:find("S")
    local ____end = maze:find("E")
    print("start=" .. __K2L_Str(start) .. " end=" .. __K2L_Str(____end) .. " distance=" .. start:manhattan(____end))
    local ____value_2 = bfs(maze, start, ____end)
    if ____value_2 == nil then
        error(__K2L_IllegalStateException.new("no path"))
    end
    local path = ____value_2
    print("shortest path: " .. path.size - 1 .. " steps")
    print("first steps: " .. path:take(5):joinToString(" -> "))
    local drawn = maze:copy()
    local ____list_4 = path:zipWithNext()
    local ____mod_2 = ____list_4.____modCount
    for ____i_8 = 1, ____list_4.size do
        local ____it = ____list_4[____i_8]
        do
            local a, b = ____it.first, ____it.second
            local d = __K2L_EnumValues(Dir):single(function(it) return a:plus(it):equals(b) end)
            if drawn:get(b) == "." then
                drawn:set(b, d.symbol)
            end
        end
        if ____list_4.____modCount ~= ____mod_2 and ____list_4:____comodified(____i_8) then
            break
        end
    end
    print(drawn:render())
    print("cheapest route: " .. cheapestRoute(maze, start, ____end))
    print("walled-in: " .. __K2L_Str(bfs(maze, start, Pos.new(0, 0))))
    local garden = Grid:parse(GARDEN)
    local rs = regions(garden)
    local ____list_5 = rs:sortedWith(____lambda_3)
    local ____mod_3 = ____list_5.____modCount
    for ____i_9 = 1, ____list_5.size do
        local it = ____list_5[____i_9]
        print("  " .. it.plant .. ": area=" .. it.area .. " perimeter=" .. it.perimeter .. " price=" .. it:getPrice())
        if ____list_5.____modCount ~= ____mod_3 and ____list_5:____comodified(____i_9) then
            break
        end
    end
    local ____sum = 0
    local ____items_3, ____n_3 = rs:____array()
    for ____i_10 = 1, ____n_3 do
        local it = ____items_3[____i_10]
        ____sum = ____sum + it:getPrice()
    end
    print("total price: " .. ____sum)
    local ____result_1 = __K2L_Map.new()
    local ____items_4, ____n_4 = rs:____array()
    for ____i_11 = 1, ____n_4 do
        local it = ____items_4[____i_11]
        local ____value_3 = it.plant
        local ____group = ____result_1:get(____value_3)
        if ____group == nil then
            ____group = __K2L_List.new()
            ____result_1:put(____value_3, ____group)
        end
        ____group:add(it.area)
    end
    local byPlant = ____result_1
    print("areas by plant: " .. __K2L_Str(byPlant))
    local lab = Grid:parse(PATROL)
    local ____destructured_1 = patrol(lab)
    local count, looped = ____destructured_1.first, ____destructured_1.second
    print("guard visits " .. count .. " cells, loop=" .. tostring(looped))
    local startPos = lab:positions():first(function(it) return lab:get(it) == "^" end)
    local loops = 0
    for r = 0, lab:getHeight() - 1 do
        do
            for c = 0, lab:getWidth() - 1 do
                do
                    local p = Pos.new(r, c)
                    if p:equals(startPos) or lab:get(p) ~= "." then
                        goto ____continue_4
                    end
                    if p:manhattan(startPos) > 6 then
                        goto ____continue_5
                    end
                    local trial = lab:copy()
                    trial:set(p, "O")
                    if patrol(trial).second then
                        loops = loops + 1
                    end
                end
                ::____continue_4::
            end
        end
        ::____continue_5::
    end
    print("obstacles creating loops (near start): " .. loops)
end

main()
return {Pos = Pos, Dir = Dir, Grid = Grid, MAZE = MAZE, bfs = bfs, State = State, cheapestRoute = cheapestRoute, GARDEN = GARDEN, Region = Region, regions = regions, PATROL = PATROL, patrol = patrol}
