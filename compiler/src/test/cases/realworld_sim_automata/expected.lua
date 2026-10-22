local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Random = ____lualib.__K2L_Random
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Shr = ____lualib.__K2L_Shr
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrimEnd = ____lualib.__K2L_StringTrimEnd
local __K2L_Text = ____lualib.__K2L_Text

local Life = __K2L_Class("Life")

function Life:____init(width, height)
    self.width = width
    self.height = height
    self.cells = __K2L_ListOfSize(self.width * self.height, false, true)
    self.next = __K2L_ListOfSize(self.width * self.height, false, true)
    self.generation = 0
end

function Life:get(x, y)
    return self.cells:get(y % self.height * self.width + x % self.width)
end

function Life:set(x, y, alive)
    local ____object = self.cells
    local ____key = y % self.height * self.width + x % self.width
    ____object:set(____key, alive)
end

function Life:place(pattern, ox, oy)
    local ____list = __K2L_StringLines(__K2L_Text.trimIndent(pattern))
    for ____i = 1, ____list.size do
        local row = ____list[____i]
        local dy = ____i - 1
        do
            local ____chars = __K2L_StringToList(row)
            for dx = 0, ____chars.size - 1 do
                local c = ____chars[dx + 1]
                if c == "#" then
                    local ____key_1 = ox + dx
                    local ____key_2 = oy + dy
                    self:set(____key_1, ____key_2, true)
                end
            end
        end
    end
end

function Life:neighbours(x, y)
    local n = 0
    for dy = -1, 1 do
        for dx = -1, 1 do
            if (dx ~= 0 or dy ~= 0) and self:get(x + dx, y + dy) then
                n = n + 1
            end
        end
    end
    return n
end

function Life:step()
    for y = 0, self.height - 1 do
        for x = 0, self.width - 1 do
            local n = self:neighbours(x, y)
            local ____object_1 = self.next
            local ____key_3 = y * self.width + x
            ____object_1:set(____key_3, n == 3 or n == 2 and self.cells:get(y * self.width + x))
        end
    end
    local t = self.cells
    self.cells = self.next
    self.next = t
    self.generation = self.generation + 1
end

function Life:population()
    local ____list_1 = self.cells
    local ____result = 0
    local ____items, ____n = ____list_1:____array()
    for ____i_1 = 1, ____n do
        local it = ____items[____i_1]
        if it then
            ____result = ____result + 1
        end
    end
    return ____result
end

function Life:signature()
    return self.cells:contentHashCode()
end

function Life:render()
    return __K2L_IntRange.new(0, self.height - 1):joinToString("\n", nil, nil, nil, nil, function(y)
        return __K2L_IntRange.new(0, self.width - 1):joinToString("", nil, nil, nil, nil, function(x) return self:get(x, y) and "#" or "." end)
    end)
end

local ____lambda_1 = function(it) return it == 1 and "#" or " " end
local function elementary(rule, width, steps, seedCells)
    if seedCells == nil then
        seedCells = nil
    end
    local row = __K2L_ListOfSize(width, 0, true)
    if seedCells == nil then
        local ____object_2 = row
        local ____key_4 = width - 1
        if ____key_4 < 0 or ____key_4 >= ____object_2.size then
            __K2L_IndexError(____key_4, ____object_2.size, "array")
        end
        ____object_2[____key_4 + 1] = 1
    else
        for ____i_2 = 1, seedCells.size do
            local it = seedCells[____i_2]
            do
                local ____object_3 = row
                if it < 0 or it >= ____object_3.size then
                    __K2L_IndexError(it, ____object_3.size, "array")
                end
                ____object_3[it + 1] = 1
            end
        end
    end
    local out = __K2L_ListOf()
    for it = 0, steps - 1 do
        do
            out:add(__K2L_StringTrimEnd(row:joinToString("", nil, nil, nil, nil, ____lambda_1)))
            local ____next = __K2L_ListOfSize(width, 0, true)
            for i = 0, width - 1 do
                local l = i == 0 and 0 or (row[i] or __K2L_IndexError(i - 1, row.size, "array"))
                local c = row[i + 1] or __K2L_IndexError(i, row.size, "array")
                local r = i == width - 1 and 0 or (row[i + 1 + 1] or __K2L_IndexError(i + 1, row.size, "array"))
                local ____value = __K2L_Shr(rule, ((l << 2) + 0x80000000 & 0xFFFFFFFF) - 0x80000000 | ((c << 1) + 0x80000000 & 0xFFFFFFFF) - 0x80000000 | r) & 1
                if i < 0 or i >= ____next.size then
                    __K2L_IndexError(i, ____next.size, "array")
                end
                ____next[i + 1] = ____value
            end
            row = ____next
        end
    end
    return out
end

local function langtonsAnt(size, steps)
    local grid = __K2L_ListOfSize(size, function(it) return __K2L_ListOfSize(size, false, true) end, true)
    local x = size // 2
    local y = size // 2
    local dir = 0
    local dx = __K2L_ArrayOf(0, 1, 0, -1)
    local dy = __K2L_ArrayOf(-1, 0, 1, 0)
    for it = 0, steps - 1 do
        do
            dir = grid:get(y):get(x) and (dir + 3) % 4 or (dir + 1) % 4
            local ____object_4 = grid:get(y)
            local ____key_5 = x
            ____object_4:set(____key_5, not grid:get(y):get(x))
            x = (x + (dx[dir + 1] or __K2L_IndexError(dir, dx.size, "array")) + size) % size
            y = (y + (dy[dir + 1] or __K2L_IndexError(dir, dy.size, "array")) + size) % size
        end
    end
    local ____sum = 0
    local ____items_2, ____n_2 = grid:____array()
    for ____i_4 = 1, ____n_2 do
        local row = ____items_2[____i_4]
        local ____result_1
        do
            local ____result_2 = 0
            local ____items_1, ____n_1 = row:____array()
            for ____i_3 = 1, ____n_1 do
                local it = ____items_1[____i_3]
                if it then
                    ____result_2 = ____result_2 + 1
                end
            end
            ____result_1 = ____result_2
        end
        ____sum = ____sum + ____result_1
    end
    local black = ____sum
    return __K2L_Pair.new(black, "ant at (" .. x .. ", " .. y .. ") facing " .. (dir >= 0 and dir < #"NESW" and ("NESW"):sub(dir + 1, dir + 1) or __K2L_IndexError(dir, #"NESW", "string")))
end

local function sandpile(size, grains)
    local pile = __K2L_ListOfSize(size, function(it) return __K2L_ListOfSize(size, 0, true) end, true)
    local ____object_5 = pile:get(size // 2)
    local ____key_6 = size // 2
    if ____key_6 < 0 or ____key_6 >= ____object_5.size then
        __K2L_IndexError(____key_6, ____object_5.size, "array")
    end
    ____object_5[____key_6 + 1] = grains
    local unstable = true
    local topples = 0
    while unstable do
        unstable = false
        for y = 0, size - 1 do
            for x = 0, size - 1 do
                if (pile[y + 1] or __K2L_IndexError(y, pile.size, "array")):get(x) >= 4 then
                    local q = (pile[y + 1] or __K2L_IndexError(y, pile.size, "array")):get(x) // 4
                    local ____object_6 = pile[y + 1] or __K2L_IndexError(y, pile.size, "array")
                    ____object_6[x + 1] = (____object_6[x + 1] or __K2L_IndexError(x, ____object_6.size, "array")) % 4
                    topples = topples + q
                    if y > 0 then
                        local ____object_7 = pile[y] or __K2L_IndexError(y - 1, pile.size, "array")
                        ____object_7[x + 1] = (____object_7[x + 1] or __K2L_IndexError(x, ____object_7.size, "array")) + q
                    end
                    if y < size - 1 then
                        local ____object_8 = pile[y + 1 + 1] or __K2L_IndexError(y + 1, pile.size, "array")
                        ____object_8[x + 1] = (____object_8[x + 1] or __K2L_IndexError(x, ____object_8.size, "array")) + q
                    end
                    if x > 0 then
                        local ____object_9 = pile[y + 1] or __K2L_IndexError(y, pile.size, "array")
                        local ____key_7 = x - 1
                        ____object_9[____key_7 + 1] = (____object_9[____key_7 + 1] or __K2L_IndexError(____key_7, ____object_9.size, "array")) + q
                    end
                    if x < size - 1 then
                        local ____object_10 = pile[y + 1] or __K2L_IndexError(y, pile.size, "array")
                        local ____key_8 = x + 1
                        ____object_10[____key_8 + 1] = (____object_10[____key_8 + 1] or __K2L_IndexError(____key_8, ____object_10.size, "array")) + q
                    end
                    unstable = true
                end
            end
        end
    end
    print("sandpile topples: " .. topples)
    return pile
end

local ____lambda_2 = function(it) return it == "#" end
local ____lambda_3 = function(it) return it == "#" end
local function main()
    print("-- life: glider and blinker")
    local life = Life.new(12, 10)
    life:place("\n        .#.\n        ..#\n        ###\n        ", 1, 1)
    life:place("###", 8, 6)
    print(life:render())
    for it = 0, 3 do
        life:step()
    end
    print("gen " .. life.generation .. " pop " .. life:population())
    print(life:render())
    print("-- life: random soup until it repeats")
    local soup = Life.new(16, 16)
    local rng = __K2L_Random.seeded(1234)
    for y = 0, 15 do
        for x = 0, 15 do
            soup:set(x, y, rng:nextInt(100) < 35)
        end
    end
    local seen = __K2L_Map.new()
    local populations = __K2L_ListOf()
    while soup.generation < 400 do
        local sig = soup:signature()
        local first = seen:get(sig)
        if first ~= nil then
            print("cycle: generation " .. soup.generation .. " repeats " .. first .. " (period " .. soup.generation - first .. ")")
            break
        end
        seen:set(sig, soup.generation)
        populations:add(soup:population())
        soup:step()
    end
    local ____out = {}
    local ____count = 0
    local ____items_3, ____n_3 = populations:____array()
    for ____i_5 = 1, ____n_3 do
        local _ = ____items_3[____i_5]
        local i = ____i_5 - 1
        if i % 10 == 0 then
            ____count = ____count + 1
            ____out[____count] = _
        end
    end
    print("population trace: " .. __K2L_Str(__K2L_ListWrap(____out, ____count)))
    print("peak " .. populations:max() .. " final " .. soup:population())
    print(soup:render())
    local ____list_2 = __K2L_ListOf(30, 90, 110)
    for ____i_8 = 1, ____list_2.size do
        local rule = ____list_2[____i_8]
        print("-- rule " .. rule)
        local rows = elementary(rule, 40, 16)
        for ____i_6 = 1, rows.size do
            local it = rows[____i_6]
            print("|" .. it)
        end
        local ____sum_1 = 0
        local ____items_4, ____n_4 = rows:____array()
        for ____i_7 = 1, ____n_4 do
            local r = ____items_4[____i_7]
            local ____result_3
            ____result_3 = __K2L_StringToList(r):count(____lambda_2)
            ____sum_1 = ____sum_1 + ____result_3
        end
        print("live cells: " .. ____sum_1)
    end
    local wide = elementary(110, 200, 200, __K2L_ArrayOf(199))
    print("rule 110 width 200 after 200 steps: " .. __K2L_StringToList(wide:last()):count(____lambda_3) .. " live, hash " .. __K2L_Hash(wide:joinToString("")))
    print("-- langton's ant")
    local ____list_3 = __K2L_ListOf(200, 11000)
    for ____i_9 = 1, ____list_3.size do
        local steps = ____list_3[____i_9]
        local ____destructured = langtonsAnt(64, steps)
        local black, where = ____destructured.first, ____destructured.second
        print(steps .. " steps: " .. black .. " black cells, " .. where)
    end
    print("-- sandpile")
    local pile = sandpile(9, 300)
    for ____i_10 = 1, pile.size do
        local it = pile[____i_10]
        print(it:joinToString(""))
    end
    local ____sum_2 = 0
    local ____items_5, ____n_5 = pile:____array()
    for ____i_11 = 1, ____n_5 do
        local it = ____items_5[____i_11]
        ____sum_2 = ____sum_2 + it:sum()
    end
    print("grains left: " .. ____sum_2)
end

__K2L_RunMain(main)
return {Life = Life, elementary = elementary, langtonsAnt = langtonsAnt, sandpile = sandpile}
