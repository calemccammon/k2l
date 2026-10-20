local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CollectionBase = ____lualib.__K2L_CollectionBase
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_Iterable = ____lualib.__K2L_Iterable
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListBase = ____lualib.__K2L_ListBase
local __K2L_MapBase = ____lualib.__K2L_MapBase
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Throwable = ____lualib.__K2L_Throwable
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Named = __K2L_Class("Named")

function Named:____init(name)
    self.name = name
end

function Named.new(name)
    return setmetatable({name = name}, Named)
end

function Named:describe()
    return "named " .. self.name
end

local Mixed = __K2L_Class("Mixed", Named, __K2L_IterableBase)
Mixed.____readOnly = true

function Mixed:____init()
    Named.____init(self, "mixed")
end

function Mixed:iterator()
    return __K2L_IteratorOf(__K2L_ReadOnlyListOf(3, 1, 2))
end

local Wrapped = __K2L_Class("Wrapped", __K2L_Exception, __K2L_CollectionBase)
Wrapped.____readOnly = true

function Wrapped:____init()
    __K2L_Exception.____init(self, "wrapped")
end

function Wrapped:getSize()
    return 2
end

function Wrapped:isEmpty()
    return false
end

function Wrapped:contains(element)
    return element == 4 or element == 5
end

function Wrapped:containsAll(elements)
    return elements:all(function(it) return self:contains(it) end)
end

function Wrapped:iterator()
    return __K2L_IteratorOf(__K2L_ReadOnlyListOf(4, 5))
end

__K2L_PropertyOverride(Wrapped, "size", "getSize")
local Row = __K2L_Class("Row", Named, __K2L_ListBase)
Row.____readOnly = true

function Row:____init(name, cells)
    Named.____init(self, name)
    self.cells = cells
    self.____delegate_List = cells
end

function Row:describe()
    return "row " .. self.name .. " of " .. self.size
end

function Row:isEmpty()
    return self.____delegate_List:isEmpty()
end

function Row:contains(element)
    return self.____delegate_List:contains(element)
end

function Row:iterator()
    return __K2L_IteratorOf(self.____delegate_List)
end

function Row:containsAll(elements)
    return self.____delegate_List:containsAll(elements)
end

function Row:get(index)
    return self.____delegate_List:get(index)
end

function Row:indexOf(element)
    return self.____delegate_List:indexOf(element)
end

function Row:lastIndexOf(element)
    return self.____delegate_List:lastIndexOf(element)
end

function Row:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_List)
end

function Row:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_List, index)
end

function Row:subList(fromIndex, toIndex)
    return self.____delegate_List:subList(fromIndex, toIndex)
end

function Row:getSize()
    return self.____delegate_List.size
end

__K2L_PropertyOverride(Row, "size", "getSize")
local Scores = __K2L_Class("Scores", Named, __K2L_ListBase)
Scores.____readOnly = true

function Scores:____init(values)
    Named.____init(self, "scores")
    self.values = values
end

function Scores:getSize()
    return self.values.size
end

function Scores:get(index)
    return self.values[index + 1] or __K2L_IndexError(index, self.values.size, "array")
end

function Scores:isEmpty()
    return self.values:isEmpty()
end

function Scores:contains(element)
    return self.values:contains(element)
end

function Scores:containsAll(elements)
    return elements:all(function(it) return self.values:contains(it) end)
end

function Scores:indexOf(element)
    return self.values:indexOf(element)
end

function Scores:lastIndexOf(element)
    return self.values:lastIndexOf(element)
end

function Scores:iterator()
    return __K2L_IteratorOf(self.values)
end

function Scores:listIterator()
    return __K2L_JdkCollections.listIterator(self.values:toList())
end

function Scores:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.values:toList(), index)
end

function Scores:subList(fromIndex, toIndex)
    return self.values:toList():subList(fromIndex, toIndex)
end

__K2L_PropertyOverride(Scores, "size", "getSize")
local Settings = __K2L_Class("Settings", Named, __K2L_MapBase)

function Settings:____init(backing)
    Named.____init(self, "settings")
    self.backing = backing
    self.____delegate_MutableMap = backing
end

function Settings:put(key, value)
    return self.____delegate_MutableMap:put(key, value)
end

function Settings:remove(key)
    return self.____delegate_MutableMap:remove(key)
end

function Settings:putAll(from)
    return self.____delegate_MutableMap:putAll(from)
end

function Settings:clear()
    return self.____delegate_MutableMap:clear()
end

function Settings:getKeys()
    return self.____delegate_MutableMap:getKeys()
end

function Settings:getValues()
    return self.____delegate_MutableMap:getValues()
end

function Settings:getEntries()
    return self.____delegate_MutableMap:getEntries()
end

function Settings:getSize()
    return self.____delegate_MutableMap.size
end

__K2L_PropertyOverride(Settings, "size", "getSize")

function Settings:isEmpty()
    return self.____delegate_MutableMap:isEmpty()
end

function Settings:containsKey(key)
    return self.____delegate_MutableMap:containsKey(key)
end

function Settings:containsValue(value)
    return self.____delegate_MutableMap:containsValue(value)
end

function Settings:get(key)
    return self.____delegate_MutableMap:get(key)
end

local ____lambda_1 = function(it) return it * 10 end
local ____lambda_2 = function(it) return it > 5 end
local ____lambda_3 = function(it) return it.value end
local function main()
    local m = Mixed.new()
    print(m.name .. " " .. m:describe() .. " " .. __K2L_Str(m:toList()) .. " " .. __K2L_Str(m:sorted()) .. " " .. m:sum() .. " " .. __K2L_Str(m:map(____lambda_1)) .. " " .. m:count() .. " " .. m:first())
    local total = 0
    local ____items, ____n = m:____array()
    for ____i = 1, ____n do
        local x = ____items[____i]
        total = total + x
    end
    print("loop " .. total .. " " .. tostring(__K2L_InstanceOf(m, __K2L_Iterable)) .. " " .. tostring(__K2L_InstanceOf(m, Named)))
    local w = Wrapped.new()
    print(__K2L_Str(w.message) .. " " .. w:getSize() .. " " .. tostring(w:contains(4)) .. " " .. __K2L_Str(w:toList()) .. " " .. w:joinToString("+") .. " " .. tostring(__K2L_InstanceOf(w, __K2L_Iterable) and w.size ~= nil) .. " " .. tostring(__K2L_InstanceOf(w, __K2L_Throwable)))
    local ____ok, ____result = pcall(function()
        error(w)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            local ____arg = e.message
            if getmetatable(e) ~= Wrapped then
                __K2L_CastFail(e, "Wrapped", "Wrapped")
            end
            print("caught " .. __K2L_Str(____arg) .. " " .. e:getSize())
        else
            error(____error, 0)
        end
    end
    local r = Row.new("r1", __K2L_ReadOnlyListOf("a", "b", "c"))
    print(r:describe() .. " " .. r:get(1) .. " " .. r:indexOf("c") .. " " .. __K2L_Str(r:reversed()) .. " " .. r:joinToString("") .. " " .. r.name .. " " .. tostring(__K2L_InstanceOf(r, __K2L_List)))
    local ____items_1, ____n_1 = r:____array()
    for ____i_1 = 1, ____n_1 do
        local cell = ____items_1[____i_1]
        io.write(cell .. " ")
    end
    print()
    local s = Scores.new(__K2L_TypedArrayOf("[I", 5, 7, 9))
    print(s:getSize() .. " " .. s:get(2) .. " " .. s:max() .. " " .. __K2L_Str(s:subList(0, 2)) .. " " .. __K2L_Str(s:filter(____lambda_2)) .. " " .. s:describe() .. " " .. s:getLastIndex() .. " " .. __K2L_Str(s:getOrNull(5)))
    local sum = 0
    for i = 0, s.size - 1 do
        sum = sum + s:get(i)
    end
    print("sum " .. sum .. " " .. tostring(__K2L_Equals(s:toList(), __K2L_ReadOnlyListOf(5, 7, 9))))
    local settings = Settings.new(__K2L_MapOf(__K2L_Pair.new("theme", "dark")))
    settings:set("font", "mono")
    print(settings.size .. " " .. __K2L_Str(settings:get("theme")) .. " " .. __K2L_Str(settings:getKeys()) .. " " .. __K2L_Str(settings:getEntries():map(____lambda_3)) .. " " .. settings:describe())
    local ____keys, ____values, ____n_2 = settings:____arrays()
    for ____i_2 = 1, ____n_2 do
        local k, v = ____keys[____i_2], ____values[____i_2]
        io.write(k .. "=" .. v .. " ")
    end
    print()
end

main()
return {Named = Named, Mixed = Mixed, Wrapped = Wrapped, Row = Row, Scores = Scores, Settings = Settings}
