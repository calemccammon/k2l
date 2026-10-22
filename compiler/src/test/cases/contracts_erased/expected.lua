local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Unit = ____lualib.__K2L_Unit

local function once(block)
    return block()
end

local function isText(value)
    return type(value) == "string"
end

local function requireNotBlank(value)
    if value == nil or __K2L_StringIsBlank(value) then
        error(__K2L_IllegalArgumentException.new("blank"))
    end
    return value
end

local Counter = __K2L_Class("Counter")

function Counter:____init()
    self.count = 0
end

function Counter:bump(times, step)
    for it = 0, times - 1 do
        self.count = self.count + step()
    end
end

local ____lambda_1 = function() return "once" end
local ____lambda_2 = function() return 2 end
local function main()
    local x
    once(function()
        x = 41
        return __K2L_Unit
    end)
    print(x + 1)
    print(once(____lambda_1))
    local v = "text"
    if isText(v) then
        print(#v)
    end
    print(isText(3))
    print(__K2L_StringTrim(requireNotBlank(" ok ")))
    local ____ok, ____result = pcall(function()
        requireNotBlank("  ")
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalArgumentException) then
            local e = ____error
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local c = Counter.new()
    c:bump(3, ____lambda_2)
    print(c.count)
end

__K2L_RunMain(main)
return {once = once, isText = isText, requireNotBlank = requireNotBlank, Counter = Counter}
