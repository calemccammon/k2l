local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NaturalOrder = ____lualib.__K2L_NaturalOrder
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_Shr = ____lualib.__K2L_Shr
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local ____exports = {}
local MinQueue = __K2L_Class("MinQueue")

function MinQueue:____init(comparator)
    self.comparator = comparator
    self.heap = __K2L_List.new()
end

function MinQueue:getSize()
    return self.heap.size
end

function MinQueue:isEmpty()
    return self.heap:isEmpty()
end

function MinQueue:isNotEmpty()
    return self.heap:isNotEmpty()
end

function MinQueue:peek()
    return self.heap:firstOrNull()
end

function MinQueue:add(item)
    self.heap:add(item)
    local i = self.heap.size - 1
    while i > 0 do
        local parent = (i - 1) // 2
        if self.comparator(self.heap:get(i), self.heap:get(parent)) >= 0 then
            break
        end
        local t = self.heap:get(i)
        local ____object = self.heap
        local ____key = i
        ____object:set(____key, self.heap:get(parent))
        local ____object_1 = self.heap
        ____object_1:set(parent, t)
        i = parent
    end
    return true
end

function MinQueue:offer(item)
    return self:add(item)
end

function MinQueue:plusAssign(item)
    self:add(item)
end

function MinQueue:poll()
    if self.heap:isEmpty() then
        error(__K2L_NoSuchElementException.new("queue is empty"))
    end
    local top = self.heap:get(0)
    local last = self.heap:removeAt(self.heap.size - 1)
    if self.heap:isNotEmpty() then
        local ____object_2 = self.heap
        ____object_2:set(0, last)
        local i = 0
        while true do
            local l = 2 * i + 1
            if l >= self.heap.size then
                break
            end
            local r = l + 1
            local c = r < self.heap.size and self.comparator(self.heap:get(r), self.heap:get(l)) < 0 and r or l
            if self.comparator(self.heap:get(c), self.heap:get(i)) >= 0 then
                break
            end
            local t = self.heap:get(i)
            local ____object_3 = self.heap
            local ____key_1 = i
            ____object_3:set(____key_1, self.heap:get(c))
            local ____object_4 = self.heap
            ____object_4:set(c, t)
            i = c
        end
    end
    return top
end

local Node = __K2L_Class("Node")
Node.____comparable = true

function Node:____init(weight)
    self.weight = weight
end

function Node.new(weight)
    return setmetatable({weight = weight}, Node)
end

local ____lambda_1 = function(receiver) return receiver.weight end
local ____lambda_2 = function(receiver) return receiver:getMinChar() end
function Node:compareTo(other)
    return __K2L_CompareBy(__K2L_PropertyRef.new("weight", "weight@1757", ____lambda_1), __K2L_PropertyRef.new("minChar", "/Node.minChar", ____lambda_2))(self, other)
end

Node.Leaf = __K2L_Class("Node$Leaf", Node)

function Node.Leaf:____init(ch, weight)
    Node.____init(self, weight)
    self.ch = ch
end

function Node.Leaf:getMinChar()
    return self.ch
end

Node.Branch = __K2L_Class("Node$Branch", Node)

function Node.Branch:____init(left, right)
    Node.____init(self, left.weight + right.weight)
    self.left = left
    self.right = right
    self.minChar = __K2L_Num.minOf(self.left:getMinChar(), self.right:getMinChar())
end

function Node.Branch:getMinChar()
    return self.minChar
end

local ____lambda_3 = function(it) return it end
local function buildTree(text)
    local queue = MinQueue.new(__K2L_NaturalOrder)
    local ____collection = __K2L_StringToList(text):groupingBy(____lambda_3):eachCount()
    local ____items, ____n = ____collection:____entryArray()
    for ____i = 1, ____n do
        local ____entry = ____items[____i]
        do
            local c, n = ____entry.key, ____entry.value
            queue:add(Node.Leaf.new(c, n))
        end
    end
    if queue:getSize() == 1 then
        return Node.Branch.new(queue:poll(), Node.Leaf.new("\000", 0))
    end
    while queue:getSize() > 1 do
        local a = queue:poll()
        local b = queue:poll()
        queue:add(Node.Branch.new(a, b))
    end
    return queue:poll()
end

local ____lambda_4 = function() return "0" end
local function codes(node, prefix, out)
    if prefix == nil then
        prefix = ""
    end
    if out == nil then
        out = __K2L_SortedMapOf(nil)
    end
    local ____mt = getmetatable(node)
    if ____mt == Node.Leaf then
        local ____key_2 = node.ch
        out:set(____key_2, __K2L_Text.ifEmpty(prefix, ____lambda_4))
    elseif ____mt == Node.Branch then
        codes(node.left, prefix .. "0", out)
        codes(node.right, prefix .. "1", out)
    end
    return out
end

local function decode(tree, bits)
    local ____builder = __K2L_StringBuilder.new()
    do
        local node = tree
        for ____i_1 = 1, #bits do
            local b = __K2L_StrByte(bits, ____i_1)
            local ____cast = node
            if getmetatable(____cast) ~= Node.Branch then
                __K2L_CastFail(____cast, "Node.Branch")
            end
            local ____result
            ____result = b == 48 and ____cast.left or ____cast.right
            node = ____result
            local ____value = node
            if getmetatable(____value) == Node.Leaf then
                ____builder:append(node.ch)
                node = tree
            end
        end
    end
    return ____builder:toString()
end

local Token = __K2L_Class("Token")
Token.Literal = __K2L_Class("Token$Literal", nil, Token)

function Token.Literal.new(c)
    return setmetatable({c = c}, Token.Literal)
end

__K2L_DataClass(Token.Literal, {"c"})
Token.Ref = __K2L_Class("Token$Ref", nil, Token)

function Token.Ref.new(distance, length)
    return setmetatable({distance = distance, length = length}, Token.Ref)
end

__K2L_DataClass(Token.Ref, {"distance", "length"})

local function lz77(input, window)
    if window == nil then
        window = 32
    end
    local out = __K2L_ListOf()
    local i = 0
    while i < #input do
        local bestLen = 0
        local bestDist = 0
        for j = math.max(0, i - window), i - 1 do
            local len = 0
            while i + len < #input and (j + len >= 0 and j + len < #input and input:sub(j + len + 1, j + len + 1) or __K2L_IndexError(j + len, #input, "string")) == (i + len >= 0 and i + len < #input and input:sub(i + len + 1, i + len + 1) or __K2L_IndexError(i + len, #input, "string")) and len < 255 do
                len = len + 1
            end
            if len > bestLen then
                bestLen = len
                bestDist = i - j
            end
        end
        if bestLen >= 3 then
            out:add(Token.Ref.new(bestDist, bestLen))
            i = i + bestLen
        else
            local ____old = i
            i = i + 1
            out:add(Token.Literal.new(____old >= 0 and ____old < #input and input:sub(____old + 1, ____old + 1) or __K2L_IndexError(____old, #input, "string")))
        end
    end
    return out
end

local function unlz77(tokens)
    local sb = __K2L_StringBuilder.new()
    for ____i_2 = 1, tokens.size do
        local t = tokens[____i_2]
        local ____mt_1 = getmetatable(t)
        if ____mt_1 == Token.Literal then
            sb:append(t.c)
        elseif ____mt_1 == Token.Ref then
            for it = 0, t.length - 1 do
                sb:append(sb:get(sb:getLength() - t.distance))
            end
        end
    end
    return sb:toString()
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local ____lambda_5 = function(i, acc, b)
    return acc | __K2L_Shl(b, 16 - 8 * i)
end
local function base64(bytes)
    return bytes:chunked(3):joinToString("", nil, nil, nil, nil, function(chunk)
        local n = chunk:foldIndexed(0, ____lambda_5)
        return __K2L_IntRange.new(0, 4 - 1):map(function(k)
            return k <= chunk.size and __K2L_StringCharAt(B64, __K2L_Shr(n, 18 - 6 * k) & 63) or "="
        end):joinToString("")
    end)
end

local ____lambda_6 = function(it) return it ~= "=" end
local ____lambda_7 = function(it) return __K2L_StringIndexOf(B64, it) end
local ____lambda_8 = function(i, acc, v)
    return acc | __K2L_Shl(v, 18 - 6 * i)
end
local function unbase64(s)
    local ____list = __K2L_StringToList(__K2L_Text.filter(s, ____lambda_6)):map(____lambda_7):chunked(4)
    local ____out = {}
    local ____count = 0
    local ____items_1, ____n_1 = ____list:____array()
    for ____i_3 = 1, ____n_1 do
        local group = ____items_1[____i_3]
        local ____result_1
        do
            local n = group:foldIndexed(0, ____lambda_8)
            ____result_1 = __K2L_IntRange.new(0, group.size - 1 - 1):map(function(k) return __K2L_Shr(n, 16 - 8 * k) & 255 end)
        end
        local ____inner, ____m = ____result_1:____array()
        for ____j = 1, ____m do
            ____count = ____count + 1
            ____out[____count] = ____inner[____j]
        end
    end
    return __K2L_ListWrap(____out, ____count)
end

local CRC_TABLE = __K2L_ListOfSize(256, function(n)
    local c = n
    for it = 0, 7 do
        c = c & 1 ~= 0 and (c & 0xFFFFFFFF) >> 1 ~ 3988292384 or (c & 0xFFFFFFFF) >> 1
    end
    return c
end, true)

local function crc32(bytes)
    local crc = -1
    for ____i_4 = 1, bytes.size do
        local b = bytes[____i_4]
        crc = (CRC_TABLE[((crc ~ b) & 255) + 1] or __K2L_IndexError((crc ~ b) & 255, CRC_TABLE.size, "array")) ~ (crc & 0xFFFFFFFF) >> 8
    end
    return ~crc & 4294967295
end

local function memoized(self)
    local cache = __K2L_Map.new()
    return function(a)
        return cache:getOrPut(a, function() return self(a) end)
    end
end

____exports.slowCalls = 0
local slowSquare = function(x)
    ____exports.slowCalls = ____exports.slowCalls + 1
    return x * x
end

local ____lambda_9 = function(x) return getmetatable(x) == Token.Ref end
local ____lambda_10 = function(it) return it:byte() end
local ____lambda_11 = function(it) return it:byte() end
local ____lambda_12 = function(it) return it:byte() end
local function main()
    local text = "abracadabra alakazam"
    local tree = buildTree(text)
    local ____table = codes(tree)
    print("weights: total=" .. tree.weight .. ", codes=" .. __K2L_Str(____table))
    local encoded = __K2L_StringToList(text):map(function(it) return ____table:getValue(it) end):joinToString("")
    print("encoded " .. #encoded .. " bits vs " .. #text * 8 .. ": " .. __K2L_Text.chunked(encoded, 8):joinToString(" "))
    print("decoded: " .. decode(tree, encoded) .. " ok=" .. tostring(decode(tree, encoded) == text))
    local ____list_1 = ____table:getEntries()
    local ____sum = 0
    local ____items_2, ____n_2 = ____list_1:____array()
    for ____i_5 = 1, ____n_2 do
        local ____it = ____items_2[____i_5]
        local ____result_2
        do
            local c, code = ____it.key, ____it.value
            ____result_2 = #code * __K2L_StringToList(text):count(function(it) return it == c end)
        end
        ____sum = ____sum + ____result_2
    end
    local avg = (____sum + 0.0) / #text
    print("average code length: " .. string.format("%.3f", avg))
    print("single symbol: " .. __K2L_Str(codes(buildTree("zzzz"))))
    local sample = "to be or not to be, that is the question; to be or not to be"
    local tokens = lz77(sample)
    local ____arg = tokens.size
    local ____result_3 = 0
    local ____items_3, ____n_3 = tokens:____array()
    for ____i_6 = 1, ____n_3 do
        local it = ____items_3[____i_6]
        if getmetatable(it) == Token.Ref then
            ____result_3 = ____result_3 + 1
        end
    end
    print("lz77: " .. ____arg .. " tokens, " .. ____result_3 .. " refs; first refs " .. __K2L_Str(tokens:filter(____lambda_9):take(3)))
    print("round trip: " .. tostring(unlz77(tokens) == sample))
    local pattern = "abcabcabcabcabcabcx"
    print("lz77(" .. pattern .. ") = " .. lz77(pattern):joinToString("", nil, nil, nil, nil, function(it)
        if getmetatable(it) == Token.Literal then
            return it.c
        else
            if getmetatable(it) ~= Token.Ref then
                __K2L_CastFail(it, "Token.Ref")
            end
            return "<" .. it.distance .. "," .. it.length .. ">"
        end
    end))
    local ____list_2 = __K2L_ListOf("Man", "Ma", "M", "hello, world!", "")
    for ____i_8 = 1, ____list_2.size do
        local s = ____list_2[____i_8]
        local bytes = __K2L_StringToList(s):map(____lambda_10)
        local enc = base64(bytes)
        local ____list_3 = unbase64(enc)
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_4, ____n_4 = ____list_3:____array()
        for ____i_7 = 1, ____n_4 do
            local it = ____items_4[____i_7]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = string.char(it)
        end
        local back = __K2L_ListWrap(____out_1, ____count_1):joinToString("")
        print("base64('" .. s .. "') = '" .. enc .. "' -> '" .. back .. "' crc=" .. __K2L_StringPadStart(__K2L_Num.toRadix(crc32(bytes), 16), 8, "0"))
    end
    print("crc32('123456789') = " .. crc32(__K2L_StringToList("123456789"):map(____lambda_11)) .. " (0x" .. __K2L_Num.toRadix(crc32(__K2L_StringToList("123456789"):map(____lambda_12)), 16) .. ")")
    local ____list_4 = CRC_TABLE:take(4)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_5, ____n_5 = ____list_4:____array()
    for ____i_9 = 1, ____n_5 do
        local it = ____items_5[____i_9]
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = __K2L_Num.toRadix(it, 16)
    end
    print("table: " .. __K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
    local fast = memoized(slowSquare)
    local results = __K2L_ListOf(3, 4, 3, 3, 5, 4):map(fast)
    print("memoized: " .. __K2L_Str(results) .. ", underlying calls " .. ____exports.slowCalls)
    local fib
    fib = memoized(function(n)
        return n < 2 and n or (fib or __K2L_Uninitialized("fib"))(n - 1) + (fib or __K2L_Uninitialized("fib"))(n - 2)
    end)
    print("fib(60) = " .. (fib or __K2L_Uninitialized("fib"))(60))
end

____exports.MinQueue = MinQueue
____exports.Node = Node
____exports.buildTree = buildTree
____exports.codes = codes
____exports.decode = decode
____exports.Token = Token
____exports.lz77 = lz77
____exports.unlz77 = unlz77
____exports.base64 = base64
____exports.unbase64 = unbase64
____exports.CRC_TABLE = CRC_TABLE
____exports.crc32 = crc32
____exports.memoized = memoized
____exports.slowSquare = slowSquare
__K2L_RunMain(main)
return ____exports
