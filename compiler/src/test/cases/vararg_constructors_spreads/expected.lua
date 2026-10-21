local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Spread = ____lualib.__K2L_Spread
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf
local __K2L_Unpack = ____lualib.__K2L_Unpack

local spreads
local Tags = __K2L_Class("Tags")

function Tags:____init(...)
    local names = __K2L_ArrayOf(...)
    self.names = names
end

function Tags:toString()
    return self.names:joinToString(",", "Tags(", ")")
end

local Batch = __K2L_Class("Batch")

function Batch:____init(id, ...)
    local items = __K2L_ArrayOf(...)
    self.id = id
    self.items = items:toList()
end

function Batch:____init1(label, ...)
    local items = __K2L_ArrayOf(...)
    Batch.____init(self, #label, __K2L_Spread("s.", items, 0))
end

function Batch.new1(label, ...)
    local self = setmetatable({}, Batch)
    self:____init1(label, ...)
    return self
end

function Batch:toString()
    return "Batch(" .. self.id .. ", " .. __K2L_Str(self.items) .. ")"
end

local Labeled = __K2L_Class("Labeled", Batch)

function Labeled:____init(label, ...)
    local xs = __K2L_ArrayOf(...)
    Batch.____init(self, #label * 10, __K2L_Unpack(xs))
    self.label = label
end

local Chord = __K2L_Class("Chord")

function Chord:____init(name, ordinal, ...)
    local notes = __K2L_ArrayOf(...)
    self.name = name
    self.ordinal = ordinal
    self.notes = notes
end

function Chord:toString()
    return self.name
end

function Chord:compareTo(other)
    return self.ordinal - other.ordinal
end

Chord.C_MAJOR = Chord.new("C_MAJOR", 0, "C", "E", "G")
Chord.POWER = Chord.new("POWER", 1, "C", "G")
Chord.SILENCE = Chord.new("SILENCE", 2)
Chord.____values = {Chord.C_MAJOR, Chord.POWER, Chord.SILENCE}

local function main()
    print(__K2L_Str(Tags.new()))
    print(__K2L_Str(Tags.new("a")))
    print(Tags.new("a", "b", "c").names.size)
    local more = __K2L_TypedArrayOf("[Ljava.lang.String;", "y", "z")
    print(__K2L_Str(Tags.new("x", __K2L_Unpack(more))))
    print(__K2L_Str(Batch.new(1)))
    print(__K2L_Str(Batch.new(2, 5, 6)))
    local xs = __K2L_TypedArrayOf("[I", 7, 8)
    print(__K2L_Str(Batch.new(3, __K2L_Spread("s.", xs, 9))))
    print(__K2L_Str(Batch.new1("four", 1, 2)))
    print(__K2L_Str(Labeled.new("ab", 4, 4)))
    local ____values = Chord.____values
    local ____out = {}
    local ____count = 0
    for ____i = 1, #____values do
        local it = ____values[____i]
        ____count = ____count + 1
        ____out[____count] = it.name .. "=" .. it.notes:joinToString("")
    end
    print(__K2L_Str(__K2L_ListWrap(____out, ____count)))
    spreads()
end

local function total(label, ...)
    local xs = __K2L_ArrayOf(...)
    return label .. "=" .. xs:sum() .. "/" .. xs.size
end

function spreads()
    local a = __K2L_TypedArrayOf("[Ljava.lang.String;", "a", "b")
    local n = __K2L_TypedArrayOf("[I", 1, 2, 3)
    local none = __K2L_TypedArrayOf("[Ljava.lang.String;")
    print(__K2L_Str(__K2L_ReadOnlyListOf(__K2L_Spread("s.", a, "c"))))
    print(__K2L_Str(__K2L_ListOf("0", __K2L_Spread("ss.", a, a, "z"))))
    print(__K2L_Str(__K2L_TypedArrayOf("[Ljava.lang.String;", __K2L_Spread("s..", a, nil, "q")):toList()))
    print(__K2L_ReadOnlyListOf(__K2L_Spread("s.s", none, nil, a)).size)
    print(total("t", __K2L_Spread("s.", n, 10)))
    print(total("u", __K2L_Spread("ss", n, n)))
    print(total("v", 5, __K2L_Spread("s.", n, 6)))
    print(__K2L_Str(__K2L_ReadOnlySetOf(__K2L_Spread("s.", a, "a"))))
    print(__K2L_Str(Tags.new(__K2L_Spread("s.s", a, "!", __K2L_TypedArrayOf("[Ljava.lang.String;", "?")))))
end

__K2L_Main(main)
return {Tags = Tags, Batch = Batch, Labeled = Labeled, Chord = Chord, total = total, spreads = spreads}
