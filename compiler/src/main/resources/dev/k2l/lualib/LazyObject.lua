-- Kotlin initializes an object, a companion object or an enum class on first access. Takes the members out of
-- `cls`; the first read or write of a member puts them back and runs the named initializers (methods of `cls`).
-- Keys starting with `__` (metamethods, `____name`, `____interfaces`, ...) and nested classes stay, so the table can
-- still be tested with `is` and extended before it is initialized.
local function __K2L_LazyObject(cls, ...)
    local initializers = {...}
    local shadow = {}
    for key, value in pairs(cls) do
        local keep = type(key) == "string" and key:sub(1, 2) == "__" and not key:find("^____init")
        if type(value) == "table" and rawget(value, "____name") ~= nil then
            keep = true
        end
        if not keep then
            shadow[key] = value
        end
    end
    for key in pairs(shadow) do
        cls[key] = nil
    end
    local original = getmetatable(cls)
    local function initialize()
        setmetatable(cls, original)
        for key, value in pairs(shadow) do
            rawset(cls, key, value)
        end
        for _, name in ipairs(initializers) do
            cls[name](cls)
        end
    end
    setmetatable(cls, {
        __index = function(_, key)
            initialize()
            return cls[key]
        end,
        __newindex = function(_, key, value)
            initialize()
            cls[key] = value
        end,
    })
end
