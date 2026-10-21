local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_DoubleEquals = ____lualib.__K2L_DoubleEquals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMap = ____lualib.__K2L_HashMap
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_JdkCollections = ____lualib.__K2L_JdkCollections
local __K2L_ListBase = ____lualib.__K2L_ListBase
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Identified = __K2L_Class("generics.delegation.Identified")
local Repository = __K2L_Class("generics.delegation.Repository")

function Repository:require(id)
    local ____value = self:findById(id)
    if ____value == nil then
        error(__K2L_NoSuchElementException.new("no entity with id " .. __K2L_Str(id)))
    end
    return ____value
end

function Repository:saveAll(entities)
    return entities:map(function(it) return self:save(it) end)
end

function Repository:count()
    return self:findAll().size
end

function Repository:exists(id)
    return self:findById(id) ~= nil
end

function Repository:findWhere(predicate)
    return self:findAll():filter(predicate)
end

local InMemoryRepository = __K2L_Class("generics.delegation.InMemoryRepository", nil, Repository)

function InMemoryRepository:____init()
    self.store = __K2L_SortedMapOf()
    self.reads = 0
end

function InMemoryRepository:findById(id)
    local ____value_1 = self.store:get(id)
    self.reads = self.reads + 1
    return ____value_1
end

function InMemoryRepository:findAll()
    local ____value_2 = self.store:getValues():toList()
    self.reads = self.reads + 1
    return ____value_2
end

function InMemoryRepository:save(entity)
    do
        local ____object = self.store
        local ____key = entity.id
        ____object:set(____key, entity)
    end
    return entity
end

function InMemoryRepository:delete(id)
    return self.store:remove(id) ~= nil
end

local CachingRepository = __K2L_Class("generics.delegation.CachingRepository", nil, Repository)

function CachingRepository:____init(inner)
    self.inner = inner
    self.____delegate_Repository = inner
    self.cache = __K2L_HashMap.new()
    self.hits = 0
end

function CachingRepository:findById(id)
    if self.cache:containsKey(id) then
        self.hits = self.hits + 1
        return self.cache:get(id)
    end
    local ____value_3 = self.inner:findById(id)
    do
        local ____object_1 = self.cache
        ____object_1:set(id, ____value_3)
    end
    return ____value_3
end

function CachingRepository:save(entity)
    local ____value_4 = self.inner:save(entity)
    do
        local ____object_2 = self.cache
        local ____key_1 = entity.id
        ____object_2:set(____key_1, ____value_4)
    end
    return ____value_4
end

function CachingRepository:delete(id)
    local ____value_5 = self.inner:delete(id)
    self.cache:remove(id)
    return ____value_5
end

function CachingRepository:findAll(...)
    return self.____delegate_Repository:findAll(...)
end

function CachingRepository:require(...)
    return self.____delegate_Repository:require(...)
end

function CachingRepository:saveAll(...)
    return self.____delegate_Repository:saveAll(...)
end

function CachingRepository:count(...)
    return self.____delegate_Repository:count(...)
end

function CachingRepository:exists(...)
    return self.____delegate_Repository:exists(...)
end

function CachingRepository:findWhere(...)
    return self.____delegate_Repository:findWhere(...)
end

local AuditingRepository = __K2L_Class("generics.delegation.AuditingRepository", nil, Repository)

function AuditingRepository:____init(inner, log)
    self.inner = inner
    self.log = log
    self.____delegate_Repository = inner
end

function AuditingRepository:save(entity)
    self.log:add((self.inner:exists(entity.id) and "update" or "insert") .. " " .. __K2L_Str(entity.id))
    return self.inner:save(entity)
end

function AuditingRepository:delete(id)
    local ____value_6 = self.inner:delete(id)
    self.log:add("delete " .. __K2L_Str(id) .. " -> " .. tostring(____value_6))
    return ____value_6
end

function AuditingRepository:findById(...)
    return self.____delegate_Repository:findById(...)
end

function AuditingRepository:findAll(...)
    return self.____delegate_Repository:findAll(...)
end

function AuditingRepository:require(...)
    return self.____delegate_Repository:require(...)
end

function AuditingRepository:saveAll(...)
    return self.____delegate_Repository:saveAll(...)
end

function AuditingRepository:count(...)
    return self.____delegate_Repository:count(...)
end

function AuditingRepository:exists(...)
    return self.____delegate_Repository:exists(...)
end

function AuditingRepository:findWhere(...)
    return self.____delegate_Repository:findWhere(...)
end

local ReadOnly = __K2L_Class("generics.delegation.ReadOnly")

local function readOnly(self)
    local repo = self
    local ____object_3 = __K2L_Class("generics.delegation.MainKt$readOnly$1", nil, ReadOnly)
    function ____object_3:findById(id)
        return repo:findById(id)
    end
    function ____object_3:findAll()
        return repo:findAll()
    end
    return ____object_3
end

local Labeled = __K2L_Class("generics.delegation.Labeled", __K2L_ListBase)

function Labeled:____init(items, label)
    self.items = items
    self.label = label
    self.____delegate_MutableList = items
end

function Labeled:add(element)
    print("  [" .. self.label .. "] add " .. __K2L_Str(element))
    return self.items:add(element)
end

function Labeled:toString()
    return self.label .. __K2L_Str(self.items)
end

function Labeled:addAt(index, element)
    return self.____delegate_MutableList:addAt(index, element)
end

function Labeled:remove(element)
    return self.____delegate_MutableList:remove(element)
end

function Labeled:addAll(elements)
    return self.____delegate_MutableList:addAll(elements)
end

function Labeled:addAllAt(index, elements)
    return self.____delegate_MutableList:addAllAt(index, elements)
end

function Labeled:removeAll(elements)
    return self.____delegate_MutableList:removeAll(elements)
end

function Labeled:retainAll(elements)
    return self.____delegate_MutableList:retainAll(elements)
end

function Labeled:clear()
    return self.____delegate_MutableList:clear()
end

function Labeled:set(index, element)
    return self.____delegate_MutableList:set(index, element)
end

function Labeled:removeAt(index)
    return self.____delegate_MutableList:removeAt(index)
end

function Labeled:listIterator()
    return __K2L_JdkCollections.listIterator(self.____delegate_MutableList)
end

function Labeled:listIteratorAt(index)
    return __K2L_JdkCollections.listIterator(self.____delegate_MutableList, index)
end

function Labeled:subList(fromIndex, toIndex)
    return self.____delegate_MutableList:subList(fromIndex, toIndex)
end

function Labeled:getSize()
    return self.____delegate_MutableList.size
end

__K2L_PropertyOverride(Labeled, "size", "getSize")

function Labeled:isEmpty()
    return self.____delegate_MutableList:isEmpty()
end

function Labeled:contains(element)
    return self.____delegate_MutableList:contains(element)
end

function Labeled:iterator()
    return __K2L_IteratorOf(self.____delegate_MutableList)
end

function Labeled:containsAll(elements)
    return self.____delegate_MutableList:containsAll(elements)
end

function Labeled:get(index)
    return self.____delegate_MutableList:get(index)
end

function Labeled:indexOf(element)
    return self.____delegate_MutableList:indexOf(element)
end

function Labeled:lastIndexOf(element)
    return self.____delegate_MutableList:lastIndexOf(element)
end

local User = __K2L_Class("generics.delegation.User", nil, Identified)

function User:____init(id, name, role)
    self.id = id
    self.name = name
    self.role = role
end

function User.new(id, name, role)
    return setmetatable({id = id, name = name, role = role}, User)
end

function User:toString()
    return "User(id=" .. self.id .. ", name=" .. self.name .. ", role=" .. self.role .. ")"
end

function User:hashCode()
    return (31 * (31 * self.id + __K2L_Hash(self.name)) + __K2L_Hash(self.role) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function User:equals(other)
    return getmetatable(other) == User and self.id == other.id and self.name == other.name and self.role == other.role
end

local Product = __K2L_Class("generics.delegation.Product", nil, Identified)

function Product:____init(id, price, stock)
    self.id = id
    self.price = price
    self.stock = stock
end

function Product.new(id, price, stock)
    return setmetatable({id = id, price = price, stock = stock}, Product)
end

function Product:toString()
    return "Product(id=" .. self.id .. ", price=" .. __K2L_Str(self.price) .. ", stock=" .. self.stock .. ")"
end

function Product:hashCode()
    return (31 * (31 * __K2L_Hash(self.id) + __K2L_Hash(self.price)) + self.stock + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Product:equals(other)
    return getmetatable(other) == Product and self.id == other.id and __K2L_DoubleEquals(self.price, other.price) and self.stock == other.stock
end

local ____lambda_1 = function(it) return it.id end
local function getIds(____this)
    return ____this:findAll():map(____lambda_1)
end

local function getMiddle(____this_1)
    if ____this_1:isEmpty() then
        return nil
    else
        return ____this_1:get(____this_1.size >= 0 and ____this_1.size // 2 or 0 - -____this_1.size // 2)
    end
end

local function update(____this_2, id, change)
    local ____receiver = ____this_2:findById(id)
    return ____receiver and ____this_2:save(change(____receiver))
end

local ____lambda_2 = function(it) return it.value end
local function keyOfMax(____this_3)
    local ____receiver_1 = ____this_3:getEntries():maxByOrNull(____lambda_2)
    return ____receiver_1 and ____receiver_1.key
end

local function countBy(____this_4, key)
    return ____this_4:groupingBy(key):eachCount()
end

local ____lambda_3 = function(it) return it.role == "dev" end
local ____lambda_4 = function(it) return it.name end
local ____lambda_5 = function(it)
    return User.new(it.id, it.name:upper(), it.role)
end
local ____lambda_6 = function(it) return it end
local ____lambda_7 = function(it) return it.id end
local ____lambda_8 = function(it) return __K2L_Pair.new(it.id, it.stock) end
local ____lambda_9 = function(it) return it.stock > 0 end
local ____lambda_10 = function(it) return it.price > 10 and "high" or "low" end
local function main()
    print("== users")
    local log = __K2L_ListOf()
    local base = InMemoryRepository.new()
    local users = AuditingRepository.new(CachingRepository.new(base), log)
    users:saveAll(__K2L_ReadOnlyListOf(User.new(3, "carol", "admin"), User.new(1, "alice", "dev"), User.new(2, "bob", "dev")))
    users:save(User.new(2, "bob", "lead"))
    print("count=" .. users:count() .. " ids=" .. __K2L_Str(getIds(users)) .. " exists(4)=" .. tostring(users:exists(4)))
    print("devs=" .. __K2L_Str(users:findWhere(____lambda_3):map(____lambda_4)))
    print("update=" .. __K2L_Str(update(users, 1, ____lambda_5)) .. " missing=" .. __K2L_Str(update(users, 9, ____lambda_6)))
    print("require(3)=" .. users:require(3).name .. " again=" .. users:require(3).role)
    local ____ok, ____result = __K2L_DeepPcall(function()
        users:require(42)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_NoSuchElementException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print("delete(2)=" .. tostring(users:delete(2)) .. " delete(2)=" .. tostring(users:delete(2)) .. " ids=" .. __K2L_Str(getIds(users)))
    print("base reads=" .. base.reads)
    for ____i = 1, log.size do
        local it = log[____i]
        print("  audit: " .. it)
    end
    print("== products")
    local products = CachingRepository.new(InMemoryRepository.new())
    products:saveAll(__K2L_ReadOnlyListOf(Product.new("kb", 49.5, 10), Product.new("mouse", 19.99, 0), Product.new("cable", 4.25, 120)))
    for it = 0, 2 do
        products:findById("kb")
    end
    products:findById("none")
    products:findById("none")
    local ____arg = products.hits
    local ____arg_1 = __K2L_Str(getIds(products))
    local ____receiver_2 = getMiddle(products:findAll())
    print("hits=" .. ____arg .. " ids=" .. ____arg_1 .. " middle=" .. __K2L_Str(____receiver_2 and ____receiver_2.id))
    local view = readOnly(products)
    local ____arg_2 = __K2L_Str(view:findAll():map(____lambda_7))
    local ____cast = view:findById("kb")
    local ____receiver_3 = getmetatable(____cast) == Product and ____cast or nil
    local ____result_1
    if ____receiver_3 ~= nil then
        local ____cast_1 = view:findById("kb")
        ____result_1 = (getmetatable(____cast_1) == Product and ____cast_1 or nil).price
    end
    print("view=" .. ____arg_2 .. " kb=" .. __K2L_Str(____result_1))
    local stock = products:findAll():associate(____lambda_8)
    print("most stocked=" .. __K2L_Str(keyOfMax(stock)) .. " empty=" .. __K2L_Str(keyOfMax(__K2L_ReadOnlyMapOf())))
    print("in stock by price band=" .. __K2L_Str(countBy(products:findWhere(____lambda_9), ____lambda_10)))
    print("== delegated list")
    local tags = Labeled.new(__K2L_ListOf("a"), "tags")
    tags:add("b")
    tags:add("c")
    tags:addAll(__K2L_ReadOnlyListOf("d", "e"))
    tags:removeAt(0)
    print(__K2L_Str(tags) .. " size=" .. tags.size .. " middle=" .. __K2L_Str(getMiddle(tags)) .. " contains(c)=" .. tostring(tags:contains("c")) .. " sorted=" .. __K2L_Str(tags:sortedDescending()))
    print("empty middle=" .. __K2L_Str(getMiddle(__K2L_ReadOnlyListOf())))
end

__K2L_DeepMain(main)
return {Identified = Identified, Repository = Repository, InMemoryRepository = InMemoryRepository, CachingRepository = CachingRepository, AuditingRepository = AuditingRepository, ReadOnly = ReadOnly, readOnly = readOnly, Labeled = Labeled, User = User, Product = Product, getIds = getIds, getMiddle = getMiddle, update = update, keyOfMax = keyOfMax, countBy = countBy}
