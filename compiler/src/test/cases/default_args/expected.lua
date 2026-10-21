local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str

local function greet(name, punctuation)
    if name == nil then
        name = "world"
    end
    if punctuation == nil then
        punctuation = "!"
    end
    return "Hello, " .. name .. punctuation
end

local function range(from, to, step)
    if from == nil then
        from = 0
    end
    if step == nil then
        step = 1
    end
    local s = ""
    local i = from
    while i < to do
        s = s .. i .. " "
        i = i + step
    end
    return s
end

local function withDerived(a, b)
    if b == nil then
        b = a * 2
    end
    return a + b
end

local Config = __K2L_Class("Config")

function Config:____init(name, retries, verbose)
    if retries == nil then
        retries = 3
    end
    if verbose == nil then
        verbose = false
    end
    self.name = name
    self.retries = retries
    self.verbose = verbose
end

function Config:toString()
    return "Config(" .. self.name .. ", " .. self.retries .. ", " .. tostring(self.verbose) .. ")"
end

local function main()
    print(greet())
    print(greet("Kotlin"))
    print(greet(nil, "?"))
    print(greet("Lua", "."))
    print(range(nil, 5))
    print(range(2, 10, 3))
    print(range(nil, 6, 2))
    print(withDerived(5))
    print(withDerived(5, 1))
    print(__K2L_Str(Config.new("a")))
    print(__K2L_Str(Config.new("b", nil, true)))
    print(__K2L_Str(Config.new("c", 5)))
end

__K2L_Main(main)
return {greet = greet, range = range, withDerived = withDerived, Config = Config}
