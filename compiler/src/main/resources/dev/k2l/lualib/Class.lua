-- Instances look keys up in their class (`cls.__index = cls`), except when the class (or a base) needs more:
-- * it overrides a library property such as Throwable.message with a custom getter: the field is not set on instances
--   (what the Throwable constructor stores goes to `____message`), so reading it reaches `__index`, which calls the getter;
-- * its elements are read and written by index through methods (`____at`/`____atPut`, see AbstractCollections): an
--   AbstractList's `list[i]` is get(i - 1), so generated loops and the lualib read it like any list.
-- Subclasses inherit this.
local function instanceIndex(cls)
    local accessors, at = cls.____accessors, cls.____at
    return function(self, key)
        if accessors ~= nil then
            local getter = accessors[key]
            if getter ~= nil then
                return cls[getter](self)
            end
        end
        if at ~= nil and type(key) == "number" then
            return at(self, key)
        end
        return cls[key]
    end
end

local function instanceNewIndex(self, key, value)
    local cls = getmetatable(self)
    local accessors = cls.____accessors
    if accessors ~= nil and accessors[key] ~= nil then
        rawset(self, "____" .. key, value)
    elseif type(key) == "number" and cls.____atPut ~= nil then
        cls.____atPut(self, key, value)
    else
        rawset(self, key, value)
    end
end

local function installIndex(cls)
    cls.__index = instanceIndex(cls)
    cls.__newindex = instanceNewIndex
end

local function __K2L_PropertyOverride(cls, key, getter)
    local accessors = {}
    for k, v in pairs(cls.____accessors or {}) do
        accessors[k] = v
    end
    accessors[key] = getter
    cls.____accessors = accessors
    installIndex(cls)
end

-- Makes `cls` read and write its elements by index with `at(self, i)` and `atPut(self, i, value)` (1-based `i`).
local function __K2L_ElementAccess(cls, at, atPut)
    cls.____at, cls.____atPut = at, atPut
    installIndex(cls)
end

-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
    if base ~= nil then
        cls.__tostring = rawget(base, "__tostring")
        cls.__call = rawget(base, "__call")
    end
    local interfaces = {...}
    for _, iface in ipairs(interfaces) do
        -- objects of a class implementing Comparator, Runnable or a function type are callable (see SamInterfaces)
        cls.__call = cls.__call or rawget(iface, "__call")
        cls.____interfaces[iface] = true
        for super in pairs(iface.____interfaces) do
            cls.____interfaces[super] = true
        end
    end
    if #interfaces == 0 then
        if base ~= nil then
            setmetatable(cls, base)
        end
    else
        setmetatable(cls, {__index = function(_, key)
            if base ~= nil then
                local value = base[key]
                if value ~= nil then
                    return value
                end
            end
            for _, iface in ipairs(interfaces) do
                local value = iface[key]
                if value ~= nil then
                    return value
                end
            end
        end})
    end
    if base ~= nil and (base.____accessors ~= nil or base.____at ~= nil) then
        installIndex(cls)
    end
    function cls.new(...)
        local self = setmetatable({}, cls)
        local init = cls.____init
        if init ~= nil then
            init(self, ...)
        end
        return self
    end
    return cls
end
