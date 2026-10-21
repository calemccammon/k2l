local ____lualib = require("lualib_bundle")
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_Main = ____lualib.__K2L_Main
local __K2L_Str = ____lualib.__K2L_Str

local ____greeter = require("lib.greeter")
local ____vector = require("lib.vector")

local function main()
    print(____greeter.greet("lua") .. " v" .. ____greeter.VERSION)
    local q, r = ____greeter.divmod(17, 5)
    print(q .. " " .. r)
    local names = {}
    names[1] = "ann"
    names[2] = "bob"
    print(#names)
    ____greeter.each(names, function(it)
        print("item " .. it)
    end)
    local counter = ____greeter.makeCounter(10)
    counter:increment(5)
    print(counter.count)
    print(counter.describe(counter))
    local v = ____vector.new(3.0, 4.0):add(____vector.new(0.0, 0.0))
    print(__K2L_Str(v:length()))
    print(__K2L_Str(v.x))
    local config = {}
    config.retries = 3
    print(config.retries ~= nil)
    config.retries = nil
    print(__K2L_Str(config.retries))
    print("raw", 1, true)
    print(type(names))
    print(os.time() > 0)
    local ok, _ = pcall(function()
        error(__K2L_IllegalStateException.new("boom"))
    end)
    print(ok)
end

__K2L_Main(main)
