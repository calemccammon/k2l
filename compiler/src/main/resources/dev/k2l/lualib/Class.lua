-- A class that overrides a library property such as Throwable.message with a custom getter: the field is not set
-- on instances (what the Throwable constructor stores goes to `____message`), so reading it reaches `__index`,
-- which calls the getter. Subclasses inherit this.
local function accessorIndex(cls)
    local accessors = cls.____accessors
    return function(self, key)
        local getter = accessors[key]
        if getter ~= nil then
            return cls[getter](self)
        end
        return cls[key]
    end
end

local function accessorNewIndex(self, key, value)
    if getmetatable(self).____accessors[key] ~= nil then
        rawset(self, "____" .. key, value)
    else
        rawset(self, key, value)
    end
end

local function __K2L_PropertyOverride(cls, key, getter)
    local accessors = {}
    for k, v in pairs(rawget(cls, "____accessors") or {}) do
        accessors[k] = v
    end
    accessors[key] = getter
    cls.____accessors = accessors
    cls.__index = accessorIndex(cls)
    cls.__newindex = accessorNewIndex
end

-- Creates a class (or interface) table. Instances use it as their metatable; methods missing from
-- the class are looked up in the base class, then in interface default methods.
local function __K2L_Class(name, base, ...)
    local cls = {____name = name, ____super = base, ____interfaces = {}}
    cls.__index = cls
    if base ~= nil then
        cls.__tostring = rawget(base, "__tostring")
        if rawget(base, "____accessors") ~= nil then
            cls.____accessors = rawget(base, "____accessors")
            cls.__index = accessorIndex(cls)
            cls.__newindex = accessorNewIndex
        end
    end
    local interfaces = {...}
    for _, iface in ipairs(interfaces) do
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
