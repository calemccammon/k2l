local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_KClassOf = ____lualib.__K2L_KClassOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local D = __K2L_Class("D")
__K2L_ClassInfo(D, "D", "D", "class")

function D:____init(x)
    self.x = x
end

function D:toString()
    return "D(x=" .. self.x .. ")"
end

function D:hashCode()
    return __K2L_Hash(self.x)
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

local function main()
    probe("isData", function() return __K2L_KClassOf(D):____needsReflect() end)
    probe("objectInstance", function() return __K2L_KClassOf(O):____needsReflect() end)
    probe("sealedSubclasses", function() return __K2L_KClassOf(S):____needsReflect() end)
    probe("isOpen", function() return __K2L_KClassOf(Op):____needsReflect() end)
    probe("isAbstract", function() return __K2L_KClassOf(Ab):____needsReflect() end)
    probe("isFinal", function() return __K2L_KClassOf(D):____needsReflect() end)
    probe("isSealed", function() return __K2L_KClassOf(S):____needsReflect() end)
    probe("isCompanion", function() return __K2L_KClassOf(D):____needsReflect() end)
    probe("isInner", function() return __K2L_KClassOf(D):____needsReflect() end)
    probe("supertypes", function() return __K2L_KClassOf(D):____needsReflect() end)
end

main()
return {D = D, O = O, S = S, Op = Op, Ab = Ab, probe = probe}
