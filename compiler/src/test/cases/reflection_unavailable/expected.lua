local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_NeedsReflect = ____lualib.__K2L_NeedsReflect
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local D = __K2L_Class("D")
__K2L_ClassInfo(D, "D", "D", "class")

function D:____init(x)
    self.x = x
end

function D.new(x)
    return setmetatable({x = x}, D)
end

function D:toString()
    return "D(x=" .. self.x .. ")"
end

function D:hashCode()
    return self.x
end

function D:equals(other)
    return getmetatable(other) == D and self.x == other.x
end

local O = __K2L_Class("O")
__K2L_ClassInfo(O, "O", "O", "class")
local S = __K2L_Class("S")
__K2L_ClassInfo(S, "S", "S", "class")
local Op = __K2L_Class("Op")
__K2L_ClassInfo(Op, "Op", "Op", "class")
local Ab = __K2L_Class("Ab")
__K2L_ClassInfo(Ab, "Ab", "Ab", "class")

local function probe(name, f)
    local ____ok, ____result = pcall(function()
        print(name .. " = " .. __K2L_Str(f()))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        local e = ____error
        print(name .. " threw " .. __K2L_Str(__K2L_KClassOfValue(e).simpleName))
    end
end

local ____lambda_1 = function() return __K2L_NeedsReflect(__K2L_KClassOf(D)) end
local ____lambda_2 = function() return __K2L_NeedsReflect(__K2L_KClassOf(O)) end
local ____lambda_3 = function() return __K2L_NeedsReflect(__K2L_KClassOf(S)) end
local ____lambda_4 = function() return __K2L_NeedsReflect(__K2L_KClassOf(Op)) end
local ____lambda_5 = function() return __K2L_NeedsReflect(__K2L_KClassOf(Ab)) end
local ____lambda_6 = function() return __K2L_NeedsReflect(__K2L_KClassOf(D)) end
local ____lambda_7 = function() return __K2L_NeedsReflect(__K2L_KClassOf(S)) end
local ____lambda_8 = function() return __K2L_NeedsReflect(__K2L_KClassOf(D)) end
local ____lambda_9 = function() return __K2L_NeedsReflect(__K2L_KClassOf(D)) end
local ____lambda_10 = function() return __K2L_NeedsReflect(__K2L_KClassOf(D)) end
local function main()
    probe("isData", ____lambda_1)
    probe("objectInstance", ____lambda_2)
    probe("sealedSubclasses", ____lambda_3)
    probe("isOpen", ____lambda_4)
    probe("isAbstract", ____lambda_5)
    probe("isFinal", ____lambda_6)
    probe("isSealed", ____lambda_7)
    probe("isCompanion", ____lambda_8)
    probe("isInner", ____lambda_9)
    probe("supertypes", ____lambda_10)
end

main()
return {D = D, O = O, S = S, Op = Op, Ab = Ab, probe = probe}
