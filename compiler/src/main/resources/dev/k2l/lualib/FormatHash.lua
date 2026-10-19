-- requires: Strings, Hash, Numbers
-- %h and %H of String.format: Integer.toHexString(arg.hashCode()), "null" for null. Loaded only by programs whose format
-- strings use them (or are not literals), so the formatter does not pull in Hash otherwise.
function __K2L_Text.formatHash(value)
    if value == nil then
        return "null"
    end
    return __K2L_Num.toRadixUnsigned(__K2L_Hash(value), 16)
end
