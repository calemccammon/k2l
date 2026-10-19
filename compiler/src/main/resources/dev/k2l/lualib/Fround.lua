-- Rounds a double to the nearest IEEE single-precision value (ties to even), as a Kotlin Float operation does. nil stays nil.
local __K2L_Fround
do
    local pack, unpack = string.pack, string.unpack
    __K2L_Fround = function(x)
        if x == nil then
            return nil
        end
        return (unpack("f", pack("f", x)))
    end
end
