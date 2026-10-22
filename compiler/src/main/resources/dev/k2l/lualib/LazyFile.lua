-- Kotlin initializes a file's top-level properties when the file is first used. For a file whose initializers can be
-- noticed, its properties live in the exports table under `names` and `init` runs them: the first read or write of one
-- of those keys, from any file, drops the metatable and runs `init` once. Other keys (functions, classes)
-- stay plain fields, and afterwards the properties are plain fields too.
local function __K2L_LazyFile(exports, init, names)
    local pending = {}
    for i = 1, #names do
        pending[names[i]] = true
    end
    local function initialize()
        setmetatable(exports, nil)
        init()
    end
    setmetatable(exports, {
        __index = function(t, key)
            if pending[key] then
                initialize()
                return rawget(t, key)
            end
            return nil
        end,
        __newindex = function(t, key, value)
            if pending[key] then
                initialize()
            end
            rawset(t, key, value)
        end,
    })
end
