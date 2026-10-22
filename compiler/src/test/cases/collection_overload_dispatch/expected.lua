local ____lualib = require("lualib_bundle")
local __K2L_AbstractList = ____lualib.__K2L_AbstractList
local __K2L_AbstractMap = ____lualib.__K2L_AbstractMap
local __K2L_AbstractSet = ____lualib.__K2L_AbstractSet
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DispatchMapRemove = ____lualib.__K2L_DispatchMapRemove
local __K2L_DispatchPredicate = ____lualib.__K2L_DispatchPredicate
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_Set = ____lualib.__K2L_Set
local __K2L_Str = ____lualib.__K2L_Str

local Bag = __K2L_Class("Bag", __K2L_AbstractList)

function Bag:____init()
    self.items = __K2L_List.new()
    self.log = ""
end

function Bag:getSize()
    return self.items.size
end

function Bag:get(index)
    return self.items:get(index)
end

function Bag:set(index, element)
    return self.items:set(index, element)
end

function Bag:addAt(index, element)
    self.items:addAt(index, element)
end

function Bag:removeAt(index)
    return self.items:removeAt(index)
end

function Bag:removeAll(elements)
    self.log = self.log .. "removeAll(elements) "
    return self:removeAll__1(function(it) return elements:contains(it) end)
end

function Bag:retainAll(elements)
    self.log = self.log .. "retainAll(elements) "
    return self.items:retainAll(elements)
end

function Bag:removeAll__1(predicate)
    self.log = self.log .. "own removeAll(predicate) "
    return self.items:removeAll(predicate)
end

__K2L_PropertyOverride(Bag, "size", "getSize")
__K2L_DispatchPredicate(Bag, "removeAll")
__K2L_DispatchPredicate(Bag, "retainAll")
local Registry = __K2L_Class("Registry", __K2L_AbstractMap)

function Registry:____init()
    self.backing = __K2L_Map.new()
    self.log = ""
end

function Registry:getEntries()
    return self.backing:getEntries()
end

function Registry:put(key, value)
    return self.backing:put(key, value)
end

function Registry:remove(key)
    self.log = self.log .. "remove(" .. key .. ") "
    return self.backing:remove(key)
end

function Registry:remove__1(key, value)
    self.log = self.log .. "remove(" .. key .. ", " .. value .. ") "
    if self.backing:get(key) ~= value then
        return false
    end
    self.backing:remove(key)
    return true
end

__K2L_PropertyOverride(Registry, "entries", "getEntries")
__K2L_DispatchMapRemove(Registry, "remove__1")
local Plain = __K2L_Class("Plain", __K2L_AbstractMap)

function Plain:____init()
    self.backing = __K2L_Map.new()
end

function Plain:getEntries()
    return self.backing:getEntries()
end

function Plain:put(key, value)
    return self.backing:put(key, value)
end

function Plain:remove(key)
    return self.backing:remove(key)
end

__K2L_PropertyOverride(Plain, "entries", "getEntries")
__K2L_DispatchMapRemove(Plain, nil)
local Tags = __K2L_Class("Tags", __K2L_AbstractSet)

function Tags:____init()
    self.items = __K2L_Set.new()
end

function Tags:getSize()
    return self.items.size
end

function Tags:iterator()
    return __K2L_IteratorOf(self.items)
end

function Tags:add(element)
    return self.items:add(element)
end

__K2L_PropertyOverride(Tags, "size", "getSize")

local ____lambda_1 = function(it) return it % 2 == 0 end
local ____lambda_2 = function(it) return it > 3 end
local ____lambda_3 = function(it) return true end
local function main()
    local bag = Bag.new()
    bag:addAll(__K2L_ListOf(1, 2, 3, 4, 5, 6))
    local list = bag
    print(list:removeAll(____lambda_1))
    print(__K2L_Str(bag))
    print(list:removeAll(__K2L_ListOf(1)))
    print(__K2L_Str(bag))
    print(list:retainAll(____lambda_2))
    print(__K2L_Str(bag))
    print(list:retainAll(__K2L_ListOf(5)))
    print(__K2L_Str(bag) .. " " .. bag.log)
    print(bag:removeAll__1(____lambda_3))
    local registry = Registry.new()
    registry:set("a", 1)
    registry:set("b", 2)
    registry:set("c", 3)
    local map = registry
    print(map:remove("a", 9))
    print(map:remove("a", 1))
    print(__K2L_Str(map:remove("b")))
    print(registry:remove__1("c", 3))
    print(__K2L_Str(registry) .. " " .. registry.log)
    local plain = Plain.new()
    plain:set("x", 1)
    plain:set("y", 2)
    local plainMap = plain
    print(plainMap:remove("x", 2))
    print(plainMap:remove("x", 1))
    print(__K2L_Str(plainMap:remove("y")))
    print(__K2L_Str(plain))
    local tags = Tags.new()
    tags:addAll(__K2L_ListOf("a", "b", "c", "d"))
    print(tags:removeAll(__K2L_SequenceOf("a", "c")))
    print(__K2L_Str(tags))
    print(tags:retainAll(__K2L_SequenceOf("d")))
    print(__K2L_Str(tags))
end

__K2L_RunMain(main)
return {Bag = Bag, Registry = Registry, Plain = Plain, Tags = Tags}
