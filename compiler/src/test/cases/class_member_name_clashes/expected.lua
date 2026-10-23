local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Entry = ____lualib.__K2L_Entry
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_Str = ____lualib.__K2L_Str

local Wrapper = __K2L_Class("Wrapper")

function Wrapper.new(obj, hashCode)
    return setmetatable({obj = obj, ____hashCode = hashCode}, Wrapper)
end

function Wrapper:hashCode()
    return self.____hashCode
end

function Wrapper:equals(other)
    return getmetatable(other) == Wrapper and other.obj == self.obj
end

function Wrapper:toString()
    return "Wrapper(" .. self.obj .. ", hashCode = " .. self.____hashCode .. ")"
end

local Pair2 = __K2L_Class("Pair2")
rawget(Pair2, "____interfaces")[__K2L_Entry] = true

function Pair2:____init(key, value)
    self.key = key
    self.value = value
end

function Pair2.new(key, value)
    return setmetatable({key = key, value = value}, Pair2)
end

function Pair2:toString()
    return self.key .. "=" .. self.value
end

local Cell = __K2L_Class("Cell", Pair2)
rawget(Cell, "____interfaces")[__K2L_Entry] = true

function Cell:____init(key, value)
    Pair2.____init(self, key, value)
    self.value = value
    self.writes = 0
end

function Cell:setValue(newValue)
    local old = self.value
    self.value = newValue
    self.writes = self.writes + 1
    return old
end

local ____lambda_1 = function(it) return it.____hashCode end
local function main()
    local w = Wrapper.new("a", 7)
    print(w.____hashCode)
    print(w:hashCode())
    print(__K2L_SetOf(w, Wrapper.new("a", 7)).size)
    print(__K2L_Str(w))
    local read = ____lambda_1
    print(read(w))
    local cell = Cell.new("k", 1)
    print(cell:setValue(5))
    print(cell.value)
    cell.value = 6
    print(__K2L_Str(cell) .. " " .. cell.writes)
    local entry = cell
    print(entry:setValue(8))
    print(entry.value .. " " .. cell.writes)
    local base = cell
    print(base.value)
end

__K2L_RunMain(main)
return {Wrapper = Wrapper, Pair2 = Pair2, Cell = Cell}
