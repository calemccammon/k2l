-- requires: Class
-- kotlin.Unit where it is a value (printed, in a collection, as Any, the result of a generic lambda): one object whose
-- toString is "kotlin.Unit"; equals and hashCode are identity, as on the JVM. Calls of functions returning Unit
-- still return nothing to Lua; the code using such a call as a value uses this object instead.
local UnitClass = __K2L_Class("kotlin.Unit")

function UnitClass:toString()
    return "kotlin.Unit"
end

UnitClass.__tostring = UnitClass.toString

local __K2L_Unit = setmetatable({}, UnitClass)
