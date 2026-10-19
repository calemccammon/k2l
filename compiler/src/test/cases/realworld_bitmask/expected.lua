local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Bits = ____lualib.__K2L_Bits
local __K2L_CheckStep = ____lualib.__K2L_CheckStep
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_Shr = ____lualib.__K2L_Shr
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Ushr = ____lualib.__K2L_Ushr

local Sudoku = __K2L_Class("Sudoku")

function Sudoku:____init(puzzle)
    self.grid = __K2L_ListOfSize(81, 0, true)
    self.rows = __K2L_ListOfSize(9, 0, true)
    self.cols = __K2L_ListOfSize(9, 0, true)
    self.boxes = __K2L_ListOfSize(9, 0, true)
    self.guesses = 0
    local digits = __K2L_Text.filter(puzzle, function(it) return it:match("^%d$") ~= nil or it == "." end)
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
    return __K2L_IDiv(i, 27) * 3 + __K2L_IDiv(math.fmod(i, 9), 3)
end

function Sudoku:place(i, d)
    local bit = __K2L_Shl(1, d)
    if not (self.rows:get(__K2L_IDiv(i, 9)) & bit == 0 and self.cols:get(math.fmod(i, 9)) & bit == 0 and self.boxes:get(self:box(i)) & bit == 0) then
        error(__K2L_IllegalStateException.new("conflict at " .. i))
    end
    local ____object = self.grid
    ____object:set(i, d)
    local ____object_1 = self.rows
    local ____key = __K2L_IDiv(i, 9)
    ____object_1:set(____key, self.rows:get(__K2L_IDiv(i, 9)) | bit)
    local ____object_2 = self.cols
    local ____key_1 = math.fmod(i, 9)
    ____object_2:set(____key_1, self.cols:get(math.fmod(i, 9)) | bit)
    local ____object_3 = self.boxes
    local ____key_2 = self:box(i)
    ____object_3:set(____key_2, self.boxes:get(self:box(i)) | bit)
end

function Sudoku:remove(i)
    local mask = ~__K2L_Shl(1, self.grid:get(i))
    local ____object_4 = self.rows
    local ____key_3 = __K2L_IDiv(i, 9)
    ____object_4:set(____key_3, self.rows:get(__K2L_IDiv(i, 9)) & mask)
    local ____object_5 = self.cols
    local ____key_4 = math.fmod(i, 9)
    ____object_5:set(____key_4, self.cols:get(math.fmod(i, 9)) & mask)
    local ____object_6 = self.boxes
    local ____key_5 = self:box(i)
    ____object_6:set(____key_5, self.boxes:get(self:box(i)) & mask)
    local ____object_7 = self.grid
    ____object_7:set(i, 0)
end

function Sudoku:candidates(i)
    return 1022 & ~(self.rows:get(__K2L_IDiv(i, 9)) | self.cols:get(math.fmod(i, 9)) | self.boxes:get(self:box(i)))
end

function Sudoku:solve()
    local best = -1
    local bestCount = 10
    for i = 0, 80 do
        do
            if self.grid:get(i) ~= 0 then
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
        local bit = cands & -cands
        cands = cands ~ bit
        self.guesses = self.guesses + 1
        self:place(best, __K2L_Num.countTrailingZeroBits(bit))
        if self:solve() then
            return true
        end
        self:remove(best)
    end
    return false
end

function Sudoku:toString()
    return self.grid:toList():chunked(9):joinToString("\n", nil, nil, nil, nil, function(row)
        return row:chunked(3):joinToString(" | ", nil, nil, nil, nil, function(it) return it:joinToString(" ") end)
    end)
end

local function tsp(dist)
    local n = dist.size
    local full = __K2L_Shl(1, n)
    local inf = __K2L_IDiv(2147483647, 2)
    local dp = __K2L_ListOfSize(full, function(it)
        return __K2L_ListOfSize(n, function(it) return inf end, true)
    end, true)
    local parent = __K2L_ListOfSize(full, function(it)
        return __K2L_ListOfSize(n, function(it) return -1 end, true)
    end, true)
    local ____object_8 = dp:get(1)
    ____object_8:set(0, 0)
    for mask = 1, full - 1 do
        do
            if mask & 1 == 0 then
                goto ____continue_1
            end
            for last = 0, n - 1 do
                do
                    if mask & __K2L_Shl(1, last) == 0 or dp:get(mask):get(last) >= inf then
                        goto ____continue_2
                    end
                    for ____next = 0, n - 1 do
                        do
                            if mask & __K2L_Shl(1, ____next) ~= 0 then
                                goto ____continue_3
                            end
                            local nm = mask | __K2L_Shl(1, ____next)
                            local cost = dp:get(mask):get(last) + dist:get(last):get(____next)
                            if cost < dp:get(nm):get(____next) then
                                local ____object_9 = dp:get(nm)
                                ____object_9:set(____next, cost)
                                local ____object_10 = parent:get(nm)
                                ____object_10:set(____next, last)
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
        return __K2L_Pair.new(it, dp:get(full - 1):get(it) + dist:get(it):get(0))
    end):minBy(function(it) return it.second end)
    local ____end, total = ____destructured.first, ____destructured.second
    local tour = __K2L_ArrayDeque.new()
    local mask = full - 1
    local cur = ____end
    while cur ~= -1 do
        tour:addFirst(cur)
        local p = parent:get(mask):get(cur)
        mask = mask ~ __K2L_Shl(1, cur)
        cur = p
    end
    return __K2L_Pair.new(total, tour:plus(0))
end

local function gray(n)
    return n ~ __K2L_Shr(n, 1)
end

local function fromGray(g)
    local n = g
    local shift = __K2L_Shr(g, 1)
    while shift ~= 0 do
        n = n ~ shift
        shift = __K2L_Shr(shift, 1)
    end
    return n
end

local function subsetsWithSum(items, target)
    return __K2L_IntRange.new(0, __K2L_Shl(1, items.size) - 1):filter(function(mask)
        return items:getIndices():sumOf(function(it)
            return __K2L_Shr(mask, it) & 1 == 1 and items:get(it) or 0
        end) == target
    end):map(function(mask)
        return items:getIndices():filter(function(it) return mask & __K2L_Shl(1, it) ~= 0 end):map(function(it) return items:get(it) end)
    end)
end

local BitSieve = __K2L_Class("BitSieve")

function BitSieve:____init(limit)
    self.limit = limit
    self.bits = __K2L_ListOfSize(__K2L_IDiv(self.limit, 32) + 1, 0, true)
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
    return self.bits:get(__K2L_Ushr(i, 5)) & __K2L_Shl(1, i & 31) ~= 0
end

function BitSieve:set(i)
    local ____object_11 = self.bits
    local ____key_6 = __K2L_Ushr(i, 5)
    ____object_11:set(____key_6, self.bits:get(__K2L_Ushr(i, 5)) | __K2L_Shl(1, i & 31))
end

function BitSieve:primes()
    return __K2L_IntRange.new(2, self.limit):filterNot(function(it) return self:get(it) end)
end

function BitSieve:count()
    return self.limit + 1 - self.bits:sumOf(function(it) return __K2L_Num.countOneBits(it) end) + __K2L_Num.countOneBits(__K2L_Ushr(self.bits:last(), (self.limit & 31) + 1))
end

local function main()
    local puzzle = "\n        53..7.... 6..195... .98....6.\n        8...6...3 4..8.3..1 7...2...6\n        .6....28. ...419..5 ....8..79\n    "
    local s = Sudoku.new(puzzle)
    print("solved=" .. tostring(s:solve()) .. " guesses=" .. s.guesses)
    print(__K2L_Str(s))
    local hard = Sudoku.new("8..........36......7..9.2...5...7.......457.....1...3...1....68..85...1..9....4..")
    print("hard solved=" .. tostring(hard:solve()) .. " guesses=" .. hard.guesses)
    print(__K2L_StringLines(hard:toString()):first())
    local ____receiver = __K2L_RunCatching(function() return Sudoku.new("123") end):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    local ____receiver_1 = __K2L_RunCatching(function() return Sudoku.new("11" .. ("."):rep(79)) end):exceptionOrNull()
    print(__K2L_Str(____receiver_1 and ____receiver_1.message))
    local cities = __K2L_ReadOnlyListOf("A", "B", "C", "D", "E", "F")
    local dist = __K2L_ArrayOf(__K2L_ArrayOf(0, 12, 10, 19, 8, 14), __K2L_ArrayOf(12, 0, 3, 7, 2, 11), __K2L_ArrayOf(10, 3, 0, 6, 20, 4), __K2L_ArrayOf(19, 7, 6, 0, 4, 9), __K2L_ArrayOf(8, 2, 20, 4, 0, 13), __K2L_ArrayOf(14, 11, 4, 9, 13, 0))
    local ____destructured_1 = tsp(dist)
    local cost, tour = ____destructured_1.first, ____destructured_1.second
    print("tsp cost=" .. cost .. " tour=" .. tour:joinToString("->", nil, nil, nil, nil, function(it) return cities:get(it) end))
    print("check: " .. tostring(tour:zipWithNext(function(a, b) return dist:get(a):get(b) end):sum() == cost))
    local codes = __K2L_IntRange.new(0, 8 - 1):map(function(it) return gray(it) end)
    print("gray: " .. __K2L_Str(codes:map(function(it)
        return __K2L_StringPadStart(__K2L_Num.toRadix(it, 2), 3, "0")
    end)) .. " back=" .. __K2L_Str(codes:map(fromGray)))
    print("one bit apart: " .. tostring(codes:zipWithNext(function(a, b) return __K2L_Num.countOneBits(a ~ b) end):all(function(it) return it == 1 end)))
    print("subsets of [3,34,4,12,5,2] summing to 9: " .. __K2L_Str(subsetsWithSum(__K2L_ArrayOf(3, 34, 4, 12, 5, 2), 9)))
    local x = 182
    print("bits of " .. x .. ": count=" .. __K2L_Num.countOneBits(x) .. " lowest=" .. __K2L_Bits.lowest32(x) .. " highest=" .. __K2L_Bits.highest32(x) .. " tz=" .. __K2L_Num.countTrailingZeroBits(x) .. " lz=" .. __K2L_Num.countLeadingZeroBits(x))
    print("swap nibbles: " .. __K2L_Num.toRadix(__K2L_Shl(x & 15, 4) | __K2L_Shr(x & 240, 4), 2) .. " reversed bits: " .. __K2L_Ushr(__K2L_Num.reverseInt(x), 24))
    print("masks: " .. __K2L_Ushr(-1, 28) .. " " .. __K2L_Shl(1, 31) .. " " .. __K2L_Ushr(__K2L_Shl(1, 31), 31) .. " " .. __K2L_Shr(-16, 2) .. " " .. __K2L_Ushr(-16, 28) .. " " .. 2147483647 + 0)
    local sieve = BitSieve.new(200)
    print("primes ≤ 200: " .. sieve:primes().size .. ", count()=" .. sieve:count() .. ", last " .. __K2L_Str(sieve:primes():takeLast(3)) .. ", 97 prime? " .. tostring(not sieve:get(97)))
end

main()
return {Sudoku = Sudoku, tsp = tsp, gray = gray, fromGray = fromGray, subsetsWithSum = subsetsWithSum, BitSieve = BitSieve}
