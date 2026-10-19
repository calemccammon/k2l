local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_PriorityQueue = ____lualib.__K2L_PriorityQueue
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Shl = ____lualib.__K2L_Shl
local __K2L_Shr = ____lualib.__K2L_Shr
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringCharAt = ____lualib.__K2L_StringCharAt
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringIndexOf = ____lualib.__K2L_StringIndexOf
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized
local __K2L_Unsigned = ____lualib.__K2L_Unsigned
local __K2L_Ushr = ____lualib.__K2L_Ushr

local ____exports = {}
local Node = __K2L_Class("Node")

function Node:____init(weight)
    self.weight = weight
end

function Node:compareTo(other)
    return __K2L_CompareBy(__K2L_PropertyRef.new("weight", "weight@227", function(receiver) return receiver.weight end), __K2L_PropertyRef.new("minChar", "/Node.minChar", function(receiver) return receiver:getMinChar() end))(self, other)
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

local function buildTree(text)
    local queue = __K2L_PriorityQueue.new()
    for _, ____entry in ipairs(__K2L_StringToList(text):groupingBy(function(it) return it end):eachCount():getEntries()) do
        do
            local c, n = ____entry.key, ____entry.value
            queue:add(Node.Leaf.new(c, n))
        end
    end
    if queue.size == 1 then
        return Node.Branch.new(queue:poll(), Node.Leaf.new("\000", 0))
    end
    while queue.size > 1 do
        local a = queue:poll()
        local b = queue:poll()
        queue:add(Node.Branch.new(a, b))
    end
    return queue:single()
end

local function codes(node, prefix, out)
    if prefix == nil then
        prefix = ""
    end
    if out == nil then
        out = __K2L_SortedMapOf()
    end
    if __K2L_InstanceOf(node, Node.Leaf) then
        local ____key = node.ch
        out:set(____key, __K2L_Text.ifEmpty(prefix, function() return "0" end))
    elseif __K2L_InstanceOf(node, Node.Branch) then
        codes(node.left, prefix .. "0", out)
        codes(node.right, prefix .. "1", out)
    end
    return out
end

local function decode(tree, bits)
    local ____builder = __K2L_StringBuilder.new()
    do
        local node = tree
        for b in bits:gmatch(".") do
            local ____cast = node
            if not __K2L_InstanceOf(____cast, Node.Branch) then
                __K2L_CastFail(____cast, "Node$Branch", "Node.Branch")
            end
            local ____result
            ____result = b == "0" and ____cast.left or ____cast.right
            node = ____result
            local ____value = node
            if __K2L_InstanceOf(____value, Node.Leaf) then
                ____builder:append(node.ch)
                node = tree
            end
        end
    end
    return ____builder:toString()
end

local Token = __K2L_Class("Token")
Token.Literal = __K2L_Class("Token$Literal", nil, Token)

function Token.Literal:____init(c)
    self.c = c
end

function Token.Literal:toString()
    return "Literal(c=" .. self.c .. ")"
end

function Token.Literal:hashCode()
    return __K2L_Hash(self.c)
end

function Token.Literal:equals(other)
    return getmetatable(other) == Token.Literal and self.c == other.c
end

Token.Ref = __K2L_Class("Token$Ref", nil, Token)

function Token.Ref:____init(distance, length)
    self.distance = distance
    self.length = length
end

function Token.Ref:toString()
    return "Ref(distance=" .. self.distance .. ", length=" .. self.length .. ")"
end

function Token.Ref:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.distance) + __K2L_Hash(self.length))
end

function Token.Ref:equals(other)
    return getmetatable(other) == Token.Ref and self.distance == other.distance and self.length == other.length
end

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
            while i + len < #input and __K2L_StringCharAt(input, j + len) == __K2L_StringCharAt(input, i + len) and len < 255 do
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
            out:add(Token.Literal.new(__K2L_StringCharAt(input, ____old)))
        end
    end
    return out
end

local function unlz77(tokens)
    local sb = __K2L_StringBuilder.new()
    for _, t in ipairs(tokens) do
        if __K2L_InstanceOf(t, Token.Literal) then
            sb:append(t.c)
        elseif __K2L_InstanceOf(t, Token.Ref) then
            for it = 0, t.length - 1 do
                sb:append(sb:get(sb:getLength() - t.distance))
            end
        end
    end
    return sb:toString()
end

local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

local function base64(bytes)
    return bytes:chunked(3):joinToString("", nil, nil, nil, nil, function(chunk)
        local n = chunk:foldIndexed(0, function(i, acc, b)
            return acc | __K2L_Shl(b, 16 - 8 * i)
        end)
        return __K2L_IntRange.new(0, 4 - 1):map(function(k)
            return k <= chunk.size and __K2L_StringCharAt(B64, __K2L_Shr(n, 18 - 6 * k) & 63) or "="
        end):joinToString("")
    end)
end

local function unbase64(s)
    return __K2L_StringToList(__K2L_Text.filter(s, function(it) return it ~= "=" end)):map(function(it) return __K2L_StringIndexOf(B64, it) end):chunked(4):flatMap(function(group)
        local n = group:foldIndexed(0, function(i, acc, v)
            return acc | __K2L_Shl(v, 18 - 6 * i)
        end)
        return __K2L_IntRange.new(0, group.size - 1 - 1):map(function(k) return __K2L_Shr(n, 16 - 8 * k) & 255 end)
    end)
end

local CRC_TABLE = __K2L_ListOfSize(256, function(n)
    local c = n
    for it = 0, 7 do
        c = c & 1 ~= 0 and __K2L_Ushr(c, 1) ~ __K2L_ToInt32(3988292384) or __K2L_Ushr(c, 1)
    end
    return c
end, true)

local function crc32(bytes)
    local crc = -1
    for _, b in ipairs(bytes) do
        crc = CRC_TABLE:get((crc ~ b) & 255) ~ __K2L_Ushr(crc, 8)
    end
    return ~crc & 4294967295
end

local function memoized(self)
    local cache = __K2L_HashMap.new()
    return function(a)
        return cache:getOrPut(a, function() return self(a) end)
    end
end

____exports.slowCalls = 0
local slowSquare = function(x)
    ____exports.slowCalls = ____exports.slowCalls + 1
    return x * x
end

local function main()
    local text = "abracadabra alakazam"
    local tree = buildTree(text)
    local ____table = codes(tree)
    print("weights: total=" .. tree.weight .. ", codes=" .. __K2L_Str(____table))
    local encoded = __K2L_StringToList(text):map(function(it) return ____table:getValue(it) end):joinToString("")
    print("encoded " .. #encoded .. " bits vs " .. #text * 8 .. ": " .. __K2L_Text.chunked(encoded, 8):joinToString(" "))
    print("decoded: " .. decode(tree, encoded) .. " ok=" .. tostring(decode(tree, encoded) == text))
    local avg = (____table:getEntries():sumOf(function(____destructured)
        local c, code = ____destructured.key, ____destructured.value
        return #code * __K2L_StringToList(text):count(function(it) return it == c end)
    end) + 0.0) / #text
    print("average code length: " .. __K2L_StringFormat("%.3f", avg))
    print("single symbol: " .. __K2L_Str(codes(buildTree("zzzz"))))
    local sample = "to be or not to be, that is the question; to be or not to be"
    local tokens = lz77(sample)
    print("lz77: " .. tokens.size .. " tokens, " .. tokens:count(function(it) return __K2L_InstanceOf(it, Token.Ref) end) .. " refs; first refs " .. __K2L_Str(tokens:filter(function(x) return __K2L_InstanceOf(x, Token.Ref) end):take(3)))
    print("round trip: " .. tostring(unlz77(tokens) == sample))
    local pattern = "abcabcabcabcabcabcx"
    print("lz77(" .. pattern .. ") = " .. lz77(pattern):joinToString("", nil, nil, nil, nil, function(it)
        if __K2L_InstanceOf(it, Token.Literal) then
            return it.c
        else
            if not __K2L_InstanceOf(it, Token.Ref) then
                __K2L_CastFail(it, "Token$Ref", "Token.Ref")
            end
            return "<" .. it.distance .. "," .. it.length .. ">"
        end
    end))
    for _, s in ipairs(__K2L_ReadOnlyListOf("Man", "Ma", "M", "hello, world!", "")) do
        local bytes = __K2L_StringToList(s):map(function(it) return it:byte() end)
        local enc = base64(bytes)
        local back = unbase64(enc):map(function(it) return string.char(it) end):joinToString("")
        print("base64('" .. s .. "') = '" .. enc .. "' -> '" .. back .. "' crc=" .. __K2L_StringPadStart(__K2L_Num.toRadix(crc32(bytes), 16), 8, "0"))
    end
    print("crc32('123456789') = " .. crc32(__K2L_StringToList("123456789"):map(function(it) return it:byte() end)) .. " (0x" .. __K2L_Str(__K2L_Unsigned.toRadix(crc32(__K2L_StringToList("123456789"):map(function(it) return it:byte() end)), 16)) .. ")")
    print("table: " .. __K2L_Str(CRC_TABLE:take(4):map(function(it) return __K2L_Num.toRadixUnsigned(it, 16) end)))
    local fast = memoized(slowSquare)
    local results = __K2L_ReadOnlyListOf(3, 4, 3, 3, 5, 4):map(fast)
    print("memoized: " .. __K2L_Str(results) .. ", underlying calls " .. ____exports.slowCalls)
    local fib
    fib = memoized(function(n)
        return n < 2 and n or (fib or __K2L_Uninitialized("fib"))(n - 1) + (fib or __K2L_Uninitialized("fib"))(n - 2)
    end)
    print("fib(60) = " .. (fib or __K2L_Uninitialized("fib"))(60))
end

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
main()
return ____exports
