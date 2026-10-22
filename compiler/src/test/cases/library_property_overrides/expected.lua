local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Failure = __K2L_Class("Failure", __K2L_Exception)

function Failure:____init(code)
    __K2L_Exception.____init(self, "ignored")
    self.code = code
end

function Failure:getMessage()
    return "failed with code " .. self.code
end

__K2L_PropertyOverride(Failure, "message", "getMessage")
local Wrapped = __K2L_Class("Wrapped", __K2L_RuntimeException)

function Wrapped:____init()
    __K2L_RuntimeException.____init(self)
end

function Wrapped:getCause()
    return __K2L_IllegalStateException.new("inner")
end

function Wrapped:getMessage()
    return "wrapped/" .. __K2L_Str(self.____message)
end

__K2L_PropertyOverride(Wrapped, "cause", "getCause")
__K2L_PropertyOverride(Wrapped, "message", "getMessage")
local Base = __K2L_Class("Base", __K2L_Exception)

function Base:____init(text)
    __K2L_Exception.____init(self, text)
end

function Base:getMessage()
    return "base:" .. __K2L_Str(self.____message)
end

__K2L_PropertyOverride(Base, "message", "getMessage")
local Leaf = __K2L_Class("Leaf", Base)

function Leaf:____init()
    Base.____init(self, "leaf")
end

local function main()
    local f = Failure.new(7)
    print(f:getMessage())
    print(__K2L_Str(f))
    local asThrowable = f
    print(__K2L_Str(asThrowable.message))
    local ____ok, ____result = pcall(function()
        error(f)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local w = Wrapped.new()
    print(__K2L_Str(w:getMessage()))
    local ____receiver = w:getCause()
    print(__K2L_Str(____receiver and ____receiver.message))
    print(Leaf.new():getMessage())
    local leaf = Leaf.new()
    print(__K2L_Str(leaf.message))
    print(__K2L_Str(leaf))
end

__K2L_RunMain(main)
return {Failure = Failure, Wrapped = Wrapped, Base = Base, Leaf = Leaf}
