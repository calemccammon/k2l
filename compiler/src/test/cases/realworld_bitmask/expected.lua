local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_CheckStep = ____lualib.__K2L_CheckStep
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IsDigit = ____lualib.__K2L_IsDigit
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_Shr = ____lualib.__K2L_Shr
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Ushr = ____lualib.__K2L_Ushr

local Sudoku = __K2L_Class("Sudoku")

local ____lambda_1 = function(it)
    return __K2L_IsDigit[it] == true or it == "."
end
function Sudoku:____init(puzzle)
    self.grid = __K2L_ListOfSize(81, 0, true)
    self.rows = __K2L_ListOfSize(9, 0, true)
    self.cols = __K2L_ListOfSize(9, 0, true)
    self.boxes = __K2L_ListOfSize(9, 0, true)
    self.guesses = 0
    local digits = __K2L_Text.filter(puzzle, ____lambda_1)
    if #digits ~= 81 then
        error(__K2L_IllegalArgumentException.new("expected 81 cells, got " .. #digits))
    end
    local ____chars = __K2L_StringToList(digits)
    for i = 0, ____chars.size - 1 do
        local c = ____chars[i + 1]
        if c ~= "." and c ~= "0" then
            self:place(i, __K2L_Num.digitToInt(c))
        end
    end
end

function Sudoku:box(i)
    return i // 27 * 3 + i % 9 // 3
end

function Sudoku:place(i, d)
    local ____bit = __K2L_Shl(1, d)
    if not (self.rows:get(i // 9) & ____bit == 0 and self.cols:get(i % 9) & ____bit == 0 and self.boxes:get(self:box(i)) & ____bit == 0) then
        error(__K2L_IllegalStateException.new("conflict at " .. i))
    end
    local ____object = self.grid
    if i < 0 or i >= ____object.size then
        __K2L_IndexError(i, ____object.size, "array")
    end
    ____object[i + 1] = d
    local ____object_1 = self.rows
    local ____key = i // 9
    local ____value = self.rows:get(i // 9) | ____bit
    if ____key < 0 or ____key >= ____object_1.size then
        __K2L_IndexError(____key, ____object_1.size, "array")
    end
    ____object_1[____key + 1] = ____value
    local ____object_2 = self.cols
    local ____key_1 = i % 9
    local ____value_1 = self.cols:get(i % 9) | ____bit
    if ____key_1 < 0 or ____key_1 >= ____object_2.size then
        __K2L_IndexError(____key_1, ____object_2.size, "array")
    end
    ____object_2[____key_1 + 1] = ____value_1
    local ____object_3 = self.boxes
    local ____key_2 = self:box(i)
    local ____value_2 = self.boxes:get(self:box(i)) | ____bit
    if ____key_2 < 0 or ____key_2 >= ____object_3.size then
        __K2L_IndexError(____key_2, ____object_3.size, "array")
    end
    ____object_3[____key_2 + 1] = ____value_2
end

function Sudoku:remove(i)
    local mask = ~__K2L_Shl(1, self.grid[i + 1] or __K2L_IndexError(i, self.grid.size, "array"))
    local ____object_4 = self.rows
    local ____key_3 = i // 9
    local ____value_3 = self.rows:get(i // 9) & mask
    if ____key_3 < 0 or ____key_3 >= ____object_4.size then
        __K2L_IndexError(____key_3, ____object_4.size, "array")
    end
    ____object_4[____key_3 + 1] = ____value_3
    local ____object_5 = self.cols
    local ____key_4 = i % 9
    local ____value_4 = self.cols:get(i % 9) & mask
    if ____key_4 < 0 or ____key_4 >= ____object_5.size then
        __K2L_IndexError(____key_4, ____object_5.size, "array")
    end
    ____object_5[____key_4 + 1] = ____value_4
    local ____object_6 = self.boxes
    local ____key_5 = self:box(i)
    local ____value_5 = self.boxes:get(self:box(i)) & mask
    if ____key_5 < 0 or ____key_5 >= ____object_6.size then
        __K2L_IndexError(____key_5, ____object_6.size, "array")
    end
    ____object_6[____key_5 + 1] = ____value_5
    local ____object_7 = self.grid
    if i < 0 or i >= ____object_7.size then
        __K2L_IndexError(i, ____object_7.size, "array")
    end
    ____object_7[i + 1] = 0
end

function Sudoku:candidates(i)
    return 1022 & ~(self.rows:get(i // 9) | self.cols:get(i % 9) | self.boxes:get(self:box(i)))
end

function Sudoku:solve()
    local best = -1
    local bestCount = 10
    for i = 0, 80 do
        do
            if (self.grid[i + 1] or __K2L_IndexError(i, self.grid.size, "array")) ~= 0 then
                goto ____continue
            end
            local n = __K2L_Num.countOneBits(self:candidates(i))
            if n < bestCount then
                best = i
                bestCount = n
                if n <= 1 then
                    break
                end
            end
        end
        ::____continue::
    end
    if best < 0 then
        return true
    end
    local cands = self:candidates(best)
    while cands ~= 0 do
        local ____bit = cands & -cands
        cands = cands ~ ____bit
        self.guesses = self.guesses + 1
        self:place(best, __K2L_Num.countTrailingZeroBits(____bit))
        if self:solve() then
            return true
        end
        self:remove(best)
    end
    return false
end

local ____lambda_2 = function(it) return it:joinToString(" ") end
local ____lambda_3 = function(row)
    return row:chunked(3):joinToString(" | ", nil, nil, nil, nil, ____lambda_2)
end
function Sudoku:toString()
    return self.grid:toList():chunked(9):joinToString("\n", nil, nil, nil, nil, ____lambda_3)
end

local ____lambda_4 = function(it) return -1 end
local ____lambda_5 = function(it) return it.second end
local function tsp(dist)
    local n = dist.size
    local full = __K2L_Shl(1, n)
    local inf = 2147483647 // 2
    local dp = __K2L_ListOfSize(full, function(it)
        return __K2L_ListOfSize(n, function(it) return inf end, true)
    end, true)
    local parent = __K2L_ListOfSize(full, function(it)
        return __K2L_ListOfSize(n, ____lambda_4, true)
    end, true)
    local ____object_8 = dp[2] or __K2L_IndexError(1, dp.size, "array")
    if 0 < 0 or 0 >= ____object_8.size then
        __K2L_IndexError(0, ____object_8.size, "array")
    end
    ____object_8[1] = 0
    for mask = 1, full - 1 do
        do
            if mask & 1 == 0 then
                goto ____continue_1
            end
            for last = 0, n - 1 do
                do
                    if mask & __K2L_Shl(1, last) == 0 or (dp[mask + 1] or __K2L_IndexError(mask, dp.size, "array")):get(last) >= inf then
                        goto ____continue_2
                    end
                    for ____next = 0, n - 1 do
                        do
                            if mask & __K2L_Shl(1, ____next) ~= 0 then
                                goto ____continue_3
                            end
                            local nm = mask | __K2L_Shl(1, ____next)
                            local cost = (dp[mask + 1] or __K2L_IndexError(mask, dp.size, "array")):get(last) + (dist[last + 1] or __K2L_IndexError(last, dist.size, "array")):get(____next)
                            if cost < (dp[nm + 1] or __K2L_IndexError(nm, dp.size, "array")):get(____next) then
                                local ____object_9 = dp[nm + 1] or __K2L_IndexError(nm, dp.size, "array")
                                if ____next < 0 or ____next >= ____object_9.size then
                                    __K2L_IndexError(____next, ____object_9.size, "array")
                                end
                                ____object_9[____next + 1] = cost
                                local ____object_10 = parent[nm + 1] or __K2L_IndexError(nm, parent.size, "array")
                                if ____next < 0 or ____next >= ____object_10.size then
                                    __K2L_IndexError(____next, ____object_10.size, "array")
                                end
                                ____object_10[____next + 1] = last
                            end
                        end
                        ::____continue_3::
                    end
                end
                ::____continue_2::
            end
        end
        ::____continue_1::
    end
    local ____destructured = __K2L_IntRange.new(1, n - 1):map(function(it)
        return __K2L_Pair.new(it, (dp[full] or __K2L_IndexError(full - 1, dp.size, "array")):get(it) + (dist[it + 1] or __K2L_IndexError(it, dist.size, "array")):get(0))
    end):minBy(____lambda_5)
    local ____end, total = ____destructured.first, ____destructured.second
    local tour = __K2L_ArrayDeque.new()
    local mask = full - 1
    local cur = ____end
    while cur ~= -1 do
        tour:addFirst(cur)
        local p = (parent[mask + 1] or __K2L_IndexError(mask, parent.size, "array")):get(cur)
        mask = mask ~ __K2L_Shl(1, cur)
        cur = p
    end
    return __K2L_Pair.new(total, tour:plus(0))
end

local function gray(n)
    return n ~ n // 2
end

local function fromGray(g)
    local n = g
    local shift = g // 2
    while shift ~= 0 do
        n = n ~ shift
        shift = shift // 2
    end
    return n
end

local function subsetsWithSum(items, target)
    local ____list = __K2L_IntRange.new(0, __K2L_Shl(1, items.size) - 1):filter(function(mask)
        return items:getIndices():sumOf(function(it)
            return __K2L_Shr(mask, it) & 1 == 1 and (items[it + 1] or __K2L_IndexError(it, items.size, "array")) or 0
        end) == target
    end)
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_1 = 1, ____n_1 do
        local mask = ____items_1[____i_1]
        local ____result
        do
            local ____list_1 = items:getIndices():filter(function(it) return mask & __K2L_Shl(1, it) ~= 0 end)
            local ____out_1 = {}
            local ____count_1 = 0
            local ____items, ____n = ____list_1:____array()
            for ____i = 1, ____n do
                local it = ____items[____i]
                ____count_1 = ____count_1 + 1
                ____out_1[____count_1] = items[it + 1] or __K2L_IndexError(it, items.size, "array")
            end
            ____result = __K2L_ListWrap(____out_1, ____count_1)
        end
        ____count = ____count + 1
        ____out[____count] = ____result
    end
    return __K2L_ListWrap(____out, ____count)
end

local BitSieve = __K2L_Class("BitSieve")

function BitSieve:____init(limit)
    self.limit = limit
    self.bits = __K2L_ListOfSize(self.limit // 32 + 1, 0, true)
    self:set(0)
    self:set(1)
    local p = 2
    while p * p <= self.limit do
        if not self:get(p) then
            for m = p * p, self.limit, __K2L_CheckStep(p) do
                self:set(m)
            end
        end
        p = p + 1
    end
end

function BitSieve:get(i)
    return (self.bits[((i & 0xFFFFFFFF) >> 5) + 1] or __K2L_IndexError((i & 0xFFFFFFFF) >> 5, self.bits.size, "array")) & __K2L_Shl(1, i & 31) ~= 0
end

function BitSieve:set(i)
    local ____object_11 = self.bits
    local ____key_6 = (i & 0xFFFFFFFF) >> 5
    local ____value_6 = (self.bits[((i & 0xFFFFFFFF) >> 5) + 1] or __K2L_IndexError((i & 0xFFFFFFFF) >> 5, self.bits.size, "array")) | __K2L_Shl(1, i & 31)
    if ____key_6 < 0 or ____key_6 >= ____object_11.size then
        __K2L_IndexError(____key_6, ____object_11.size, "array")
    end
    ____object_11[____key_6 + 1] = ____value_6
end

function BitSieve:primes()
    return __K2L_IntRange.new(2, self.limit):filterNot(function(it) return self:get(it) end)
end

function BitSieve:count()
    local ____arg = self.limit + 1
    local ____list_2 = self.bits
    local ____sum = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_2 = 1, ____n_2 do
        local it = ____items_2[____i_2]
        ____sum = ____sum + __K2L_Num.countOneBits(it)
    end
    return ____arg - ____sum + __K2L_Num.countOneBits(__K2L_Ushr(self.bits:last(), (self.limit & 31) + 1))
end

local ____lambda_6 = function() return Sudoku.new("123") end
local ____lambda_7 = function() return Sudoku.new("11" .. ("."):rep(79)) end
local ____lambda_8 = function(it) return gray(it) end
local ____lambda_9 = function(a, b) return __K2L_Num.countOneBits(a ~ b) end
local function main()
    local puzzle = "\n        53..7.... 6..195... .98....6.\n        8...6...3 4..8.3..1 7...2...6\n        .6....28. ...419..5 ....8..79\n    "
    local s = Sudoku.new(puzzle)
    print("solved=" .. tostring(s:solve()) .. " guesses=" .. s.guesses)
    print(__K2L_Str(s))
    local hard = Sudoku.new("8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..")
    print("hard solved=" .. tostring(hard:solve()) .. " guesses=" .. hard.guesses)
    print(__K2L_StringLines(hard:toString()):first())
    local ____receiver = __K2L_RunCatching(____lambda_6):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    local ____receiver_1 = __K2L_RunCatching(____lambda_7):exceptionOrNull()
    print(__K2L_Str(____receiver_1 and ____receiver_1.message))
    local cities = __K2L_ListOf("A", "B", "C", "D", "E", "F")
    local dist = __K2L_ArrayOf(__K2L_ArrayOf(0, 12, 10, 19, 8, 14), __K2L_ArrayOf(12, 0, 3, 7, 2, 11), __K2L_ArrayOf(10, 3, 0, 6, 20, 4), __K2L_ArrayOf(19, 7, 6, 0, 4, 9), __K2L_ArrayOf(8, 2, 20, 4, 0, 13), __K2L_ArrayOf(14, 11, 4, 9, 13, 0))
    local ____destructured_1 = tsp(dist)
    local cost, tour = ____destructured_1.first, ____destructured_1.second
    print("tsp cost=" .. cost .. " tour=" .. tour:joinToString("->", nil, nil, nil, nil, function(it) return cities:get(it) end))
    print("check: " .. tostring(tour:zipWithNext(function(a, b)
        return (dist[a + 1] or __K2L_IndexError(a, dist.size, "array")):get(b)
    end):sum() == cost))
    local codes = __K2L_IntRange.new(0, 8 - 1):map(____lambda_8)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_3, ____n_3 = codes:____array()
    for ____i_3 = 1, ____n_3 do
        local it = ____items_3[____i_3]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = __K2L_StringPadStart(__K2L_Num.toRadix(it, 2), 3, "0")
    end
    print("gray: " .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)) .. " back=" .. __K2L_Str(codes:map(fromGray)))
    local ____list_3 = codes:zipWithNext(____lambda_9)
    local ____result_1 = true
    local ____items_4, ____n_4 = ____list_3:____array()
    for ____i_4 = 1, ____n_4 do
        local it = ____items_4[____i_4]
        if it ~= 1 then
            ____result_1 = false
            break
        end
    end
    print("one bit apart: " .. tostring(____result_1))
    print("subsets of [3,34,4,12,5,2] summing to 9: " .. __K2L_Str(subsetsWithSum(__K2L_ArrayOf(3, 34, 4, 12, 5, 2), 9)))
    local x = 182
    print("bits of " .. x .. ": count=" .. __K2L_Num.countOneBits(x) .. " lowest=" .. __K2L_Bits.lowest32(x) .. " highest=" .. __K2L_Bits.highest32(x) .. " tz=" .. __K2L_Num.countTrailingZeroBits(x) .. " lz=" .. __K2L_Num.countLeadingZeroBits(x))
    print("swap nibbles: " .. __K2L_Num.toRadix((((x & 15) << 4) + 0x80000000 & 0xFFFFFFFF) - 0x80000000 | (x & 240) // 16, 2))
    print("masks: " .. ((-1 & 0xFFFFFFFF) >> 28) .. " " .. ((1 << 31) + 0x80000000 & 0xFFFFFFFF) - 0x80000000 .. " " .. ((((1 << 31) + 0x80000000 & 0xFFFFFFFF) - 0x80000000 & 0xFFFFFFFF) >> 31) .. " " .. -16 // 4 .. " " .. ((-16 & 0xFFFFFFFF) >> 28) .. " " .. 2147483647 + 0)
    local sieve = BitSieve.new(200)
    print("primes ≤ 200: " .. sieve:primes().size .. ", count()=" .. sieve:count() .. ", last " .. __K2L_Str(sieve:primes():takeLast(3)) .. ", 97 prime? " .. tostring(not sieve:get(97)))
end

__K2L_RunMain(main)
return {Sudoku = Sudoku, tsp = tsp, gray = gray, fromGray = fromGray, subsetsWithSum = subsetsWithSum, BitSieve = BitSieve}
