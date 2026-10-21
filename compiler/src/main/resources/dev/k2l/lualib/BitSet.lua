-- requires: Class, Bit, Exceptions, Collections, LongArith
-- java.util.BitSet. The bits are kept in 32-bit words (`w[0]`, `w[1]`, ...: unsigned numbers, so every target reads and
-- writes single bits with arithmetic); `n` counts the words up to the last non-zero one, as the JDK's wordsInUse does with
-- 64-bit words. `cap` is the length of the JDK's long[] (size() is cap * 64): it grows, doubles and is trimmed by clone()
-- where the JDK's does, and `sticky` is the JDK's sizeIsSticky (a size chosen by the constructor).
local __K2L_BitSet = __K2L_Class("java.util.BitSet")

do

local floor, max, min = math.floor, math.max, math.min
local T32, ONES = 4294967296, 4294967295
local NegativeArraySize = __K2L_Class("java.lang.NegativeArraySizeException", __K2L_RuntimeException)
local band, bor, bxor = __K2L_BAnd, __K2L_BOr, __K2L_BXor

-- POW2[k] = 2^k, made by doubling so that they are integers on 5.3/5.4
local POW2 = {[0] = 1}
for k = 1, 32 do
    POW2[k] = POW2[k - 1] * 2
end

-- the number of one bits of each byte
local POP8 = {[0] = 0}
for b = 1, 255 do
    POP8[b] = POP8[floor(b / 2)] + b % 2
end

-- the bit operations of Bit return signed Ints on some targets
local function u(x)
    if x < 0 then
        return x + T32
    end
    return x
end

local function popcount(x)
    local c = 0
    while x > 0 do
        local b = x % 256
        c = c + POP8[b]
        x = floor(x / 256)
    end
    return c
end

-- the index of the lowest one bit of a non-zero word
local function lowest(x)
    local i = 0
    if x % 65536 == 0 then
        x, i = x / 65536, 16
    end
    if x % 256 == 0 then
        x, i = x / 256, i + 8
    end
    while x % 2 == 0 do
        x, i = x / 2, i + 1
    end
    return i
end

-- the index of the highest one bit of a non-zero word
local function highest(x)
    local i = 0
    if x >= 65536 then
        x, i = floor(x / 65536), 16
    end
    if x >= 256 then
        x, i = floor(x / 256), i + 8
    end
    while x >= 2 do
        x, i = floor(x / 2), i + 1
    end
    return i
end

local function outOfBounds(message)
    error(__K2L_IndexOutOfBoundsException.new(message))
end

local function checkIndex(i)
    if i < 0 then
        outOfBounds("bitIndex < 0: " .. i)
    end
end

local function checkRange(from, to)
    if from < 0 then
        outOfBounds("fromIndex < 0: " .. from)
    elseif to < 0 then
        outOfBounds("toIndex < 0: " .. to)
    elseif from > to then
        outOfBounds("fromIndex: " .. from .. " > toIndex: " .. to)
    end
end

-- the JDK's ensureCapacity, in 64-bit words
local function ensure(self, words64)
    if self.cap < words64 then
        self.cap = max(2 * self.cap, words64)
        self.sticky = false
    end
end

-- makes room for the 32-bit word `i` (expandTo)
local function expand(self, i)
    ensure(self, floor(i / 2) + 1)
    local w, n = self.w, self.n
    if i >= n then
        for k = n, i do
            w[k] = 0
        end
        self.n = i + 1
    end
end

-- drops the zero words at the end (recalculateWordsInUse)
local function trim(self)
    local w, n = self.w, self.n
    while n > 0 and w[n - 1] == 0 do
        w[n - 1] = nil
        n = n - 1
    end
    self.n = n
end

local function words64(self)
    return floor((self.n + 1) / 2)
end

function __K2L_BitSet:____init(nbits)
    self.w, self.n = {}, 0
    if nbits == nil then
        self.cap, self.sticky = 1, false
    else
        if nbits < 0 then
            error(NegativeArraySize.new("nbits < 0: " .. nbits))
        end
        self.cap, self.sticky = floor((nbits + 63) / 64), true
    end
end

local function blank(cap, sticky)
    local set = __K2L_BitSet.new()
    set.cap, set.sticky = cap, sticky
    return set
end

function __K2L_BitSet:get(from, to)
    if to ~= nil then
        return self:____getRange(from, to)
    end
    checkIndex(from)
    local word = self.w[floor(from / 32)]
    if word == nil then
        return false
    end
    local p = POW2[from % 32]
    return word % (p + p) >= p
end

-- the bits from `from` to `to` (exclusive) as a new set, shifted down to 0
function __K2L_BitSet:____getRange(from, to)
    checkRange(from, to)
    local len = self:length()
    if len <= from or from == to then
        return blank(0, true)
    end
    to = min(to, len)
    local out = blank(floor((to - from + 63) / 64), true)
    local i = self:nextSetBit(from)
    while i >= 0 and i < to do
        out:set(i - from)
        i = self:nextSetBit(i + 1)
    end
    return out
end

-- set(i), set(i, value), set(from, to) and set(from, to, value)
function __K2L_BitSet:set(a, b, c)
    if b == nil or b == true then
        return self:____setBit(a)
    elseif b == false then
        return self:clear(a)
    elseif c == false then
        return self:clear(a, b)
    end
    return self:____setRange(a, b, bor)
end

function __K2L_BitSet:____setBit(i)
    checkIndex(i)
    local wi = floor(i / 32)
    if wi >= self.n then
        expand(self, wi)
    end
    local w = self.w
    local word, p = w[wi], POW2[i % 32]
    if word % (p + p) < p then
        w[wi] = word + p
    end
end

-- applies `op` (or, xor) with the bits from `from` to `to` (exclusive) to the words they are in
function __K2L_BitSet:____setRange(from, to, op)
    checkRange(from, to)
    if from == to then
        return
    end
    local first, last = floor(from / 32), floor((to - 1) / 32)
    expand(self, last)
    local w = self.w
    for wi = first, last do
        local lo = wi == first and from % 32 or 0
        local hi = wi == last and (to - 1) % 32 + 1 or 32
        local mask = POW2[hi] - POW2[lo]
        w[wi] = u(op(w[wi], mask))
    end
    trim(self)
end

-- clear(), clear(i) and clear(from, to)
function __K2L_BitSet:clear(from, to)
    local w = self.w
    if from == nil then
        for k = 0, self.n - 1 do
            w[k] = nil
        end
        self.n = 0
        return
    end
    if to == nil then
        checkIndex(from)
        local wi = floor(from / 32)
        local word = w[wi]
        if word ~= nil then
            local p = POW2[from % 32]
            if word % (p + p) >= p then
                w[wi] = word - p
                if wi == self.n - 1 then
                    trim(self)
                end
            end
        end
        return
    end
    checkRange(from, to)
    to = min(to, self.n * 32)
    if from >= to then
        return
    end
    local first, last = floor(from / 32), floor((to - 1) / 32)
    for wi = first, last do
        local lo = wi == first and from % 32 or 0
        local hi = wi == last and (to - 1) % 32 + 1 or 32
        w[wi] = u(band(w[wi], ONES - (POW2[hi] - POW2[lo])))
    end
    trim(self)
end

-- flip(i) and flip(from, to)
function __K2L_BitSet:flip(from, to)
    if to ~= nil then
        return self:____setRange(from, to, bxor)
    end
    checkIndex(from)
    local wi = floor(from / 32)
    expand(self, wi)
    local w = self.w
    local word, p = w[wi], POW2[from % 32]
    if word % (p + p) >= p then
        w[wi] = word - p
        trim(self)
    else
        w[wi] = word + p
    end
end

function __K2L_BitSet:cardinality()
    local c, w = 0, self.w
    for k = 0, self.n - 1 do
        c = c + popcount(w[k])
    end
    return c
end

function __K2L_BitSet:length()
    local n = self.n
    if n == 0 then
        return 0
    end
    return (n - 1) * 32 + highest(self.w[n - 1]) + 1
end

function __K2L_BitSet:size()
    return self.cap * 64
end

function __K2L_BitSet:isEmpty()
    return self.n == 0
end

function __K2L_BitSet:nextSetBit(from)
    if from < 0 then
        outOfBounds("fromIndex < 0: " .. from)
    end
    local w, n = self.w, self.n
    local wi = floor(from / 32)
    if wi >= n then
        return -1
    end
    local word = w[wi]
    word = word - word % POW2[from % 32]
    while word == 0 do
        wi = wi + 1
        if wi >= n then
            return -1
        end
        word = w[wi]
    end
    return wi * 32 + lowest(word)
end

function __K2L_BitSet:nextClearBit(from)
    if from < 0 then
        outOfBounds("fromIndex < 0: " .. from)
    end
    local w, n = self.w, self.n
    local wi = floor(from / 32)
    if wi >= n then
        return from
    end
    local word = ONES - w[wi]
    word = word - word % POW2[from % 32]
    while word == 0 do
        wi = wi + 1
        if wi >= n then
            return wi * 32
        end
        word = ONES - w[wi]
    end
    return wi * 32 + lowest(word)
end

function __K2L_BitSet:previousSetBit(from)
    if from < 0 then
        if from == -1 then
            return -1
        end
        outOfBounds("fromIndex < -1: " .. from)
    end
    local w = self.w
    local wi = floor(from / 32)
    if wi >= self.n then
        return self:length() - 1
    end
    local word = w[wi] % POW2[from % 32 + 1]
    while word == 0 do
        wi = wi - 1
        if wi < 0 then
            return -1
        end
        word = w[wi]
    end
    return wi * 32 + highest(word)
end

function __K2L_BitSet:previousClearBit(from)
    if from < 0 then
        if from == -1 then
            return -1
        end
        outOfBounds("fromIndex < -1: " .. from)
    end
    local w = self.w
    local wi = floor(from / 32)
    if wi >= self.n then
        return from
    end
    local word = (ONES - w[wi]) % POW2[from % 32 + 1]
    while word == 0 do
        wi = wi - 1
        if wi < 0 then
            return -1
        end
        word = ONES - w[wi]
    end
    return wi * 32 + highest(word)
end

function __K2L_BitSet:intersects(other)
    local w, o = self.w, other.w
    for k = 0, min(self.n, other.n) - 1 do
        if band(w[k], o[k]) ~= 0 then
            return true
        end
    end
    return false
end

function __K2L_BitSet:And(other)
    if self == other then
        return
    end
    local w, o = self.w, other.w
    for k = 0, self.n - 1 do
        local x = o[k]
        w[k] = x ~= nil and u(band(w[k], x)) or 0
    end
    trim(self)
end

-- or and xor: the set grows to the other's words
local function combine(self, other, op)
    ensure(self, words64(other))
    local w, o, n = self.w, other.w, self.n
    for k = n, other.n - 1 do
        w[k] = 0
    end
    if other.n > n then
        self.n = other.n
    end
    for k = 0, other.n - 1 do
        w[k] = u(op(w[k], o[k]))
    end
    trim(self)
end

function __K2L_BitSet:Or(other)
    if self ~= other then
        combine(self, other, bor)
    end
end

function __K2L_BitSet:xor(other)
    if self == other then
        self:clear()
    else
        combine(self, other, bxor)
    end
end

function __K2L_BitSet:andNot(other)
    local w, o = self.w, other.w
    for k = 0, min(self.n, other.n) - 1 do
        w[k] = u(band(w[k], ONES - o[k]))
    end
    trim(self)
end

-- clone() trims the JDK's array to the words in use, unless the constructor chose the size
function __K2L_BitSet:clone()
    local out = blank(self.cap, self.sticky)
    if not self.sticky then
        out.cap = words64(self)
    end
    local w, o = self.w, out.w
    for k = 0, self.n - 1 do
        o[k] = w[k]
    end
    out.n = self.n
    return out
end

function __K2L_BitSet:equals(other)
    if getmetatable(other) ~= __K2L_BitSet or other.n ~= self.n then
        return false
    end
    local w, o = self.w, other.w
    for k = 0, self.n - 1 do
        if w[k] ~= o[k] then
            return false
        end
    end
    return true
end

-- the low 64 bits of the 64-bit word (hi, lo) times k, in 16-bit limbs so that every target is exact
local function mul64(hi, lo, k)
    local x0, x1 = lo % 65536, floor(lo / 65536)
    local x2, x3 = hi % 65536, floor(hi / 65536)
    local k0, k1 = k % 65536, floor(k / 65536)
    local r0 = x0 * k0
    local r1 = x1 * k0 + x0 * k1 + floor(r0 / 65536)
    local r2 = x2 * k0 + x1 * k1 + floor(r1 / 65536)
    local r3 = x3 * k0 + x2 * k1 + floor(r2 / 65536)
    return (r3 % 65536) * 65536 + r2 % 65536, (r1 % 65536) * 65536 + r0 % 65536
end

-- the JDK's: h = 1234, h ^= words[i] * (i + 1) from the last word down, then the two halves of h xor-ed
function __K2L_BitSet:hashCode()
    local hhi, hlo, w = 0, 1234, self.w
    for i = words64(self) - 1, 0, -1 do
        local phi, plo = mul64(w[2 * i + 1] or 0, w[2 * i] or 0, i + 1)
        hhi, hlo = u(bxor(hhi, phi)), u(bxor(hlo, plo))
    end
    local h = u(bxor(hhi, hlo))
    if h >= 2147483648 then
        return h - T32
    end
    return h
end

function __K2L_BitSet:toString()
    local parts = {}
    local i = self:nextSetBit(0)
    while i >= 0 do
        parts[#parts + 1] = tostring(i)
        i = self:nextSetBit(i + 1)
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

local function array(out, binary)
    out.size = #out
    return setmetatable(out, __K2L_ArrayClassOf(binary))
end

function __K2L_BitSet:toLongArray()
    local out, w = {}, self.w
    for i = 0, words64(self) - 1 do
        local hi = w[2 * i + 1] or 0
        out[i + 1] = __K2L_LongArith.fromHalves(hi >= 2147483648 and hi - T32 or hi, w[2 * i])
    end
    return array(out, "[J")
end

-- the bytes up to the last non-zero one, lowest first
function __K2L_BitSet:toByteArray()
    local out, w = {}, self.w
    for k = 0, self.n - 1 do
        local x = w[k]
        for _ = 1, 4 do
            local b = x % 256
            out[#out + 1] = b >= 128 and b - 256 or b
            x = floor(x / 256)
        end
    end
    while out[#out] == 0 do
        out[#out] = nil
    end
    return array(out, "[B")
end

-- the indexes of the set bits, as an IntArray (for stream())
function __K2L_BitSet:____bits()
    local out = {}
    local i = self:nextSetBit(0)
    while i >= 0 do
        out[#out + 1] = i
        i = self:nextSetBit(i + 1)
    end
    return array(out, "[I")
end

-- BitSet.valueOf(longs) and valueOf(bytes): `bytes` tells which
function __K2L_BitSet.valueOf(values, bytes)
    local set, w = blank(0, false), {}
    if bytes then
        for i = 1, values.size do
            local k = floor((i - 1) / 4)
            w[k] = (w[k] or 0) + (values[i] % 256) * POW2[(i - 1) % 4 * 8]
        end
        set.n = floor((values.size + 3) / 4)
    else
        for i = 1, values.size do
            local hi, lo = __K2L_LongArith.halves(values[i])
            w[2 * i - 2], w[2 * i - 1] = lo, hi % T32
        end
        set.n = 2 * values.size
    end
    for k = 0, set.n - 1 do
        w[k] = w[k] or 0
    end
    set.w = w
    trim(set)
    set.cap = words64(set)
    return set
end

end
