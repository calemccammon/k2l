local ____lualib = require("lualib_bundle")
local __K2L_ArrayIndexOutOfBoundsException = ____lualib.__K2L_ArrayIndexOutOfBoundsException
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_IsArray = ____lualib.__K2L_IsArray
local __K2L_ListOfSize = ____lualib.__K2L_ListOfSize
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_TypedArrayOf = ____lualib.__K2L_TypedArrayOf

local Slots = __K2L_Class("Slots")

function Slots:____init(n)
    local ____cast = __K2L_ListOfSize(n, nil, true)
    if not __K2L_IsArray(____cast) then
        __K2L_CastFail(____cast, "java.lang.Array", "kotlin.Array")
    end
    self.items = ____cast
end

function Slots:get(i)
    return self.items:get(i)
end

function Slots:set(i, v)
    local ____object = self.items
    ____object:set(i, v)
end

local function main()
    local ____cast_1 = __K2L_ListOfSize(3, nil, "[Ljava.lang.String;")
    if not __K2L_IsArray(____cast_1) then
        __K2L_CastFail(____cast_1, "java.lang.Array", "kotlin.Array")
    end
    local names = ____cast_1
    if 1 < 0 or 1 >= names.size then
        __K2L_IndexError(1, names.size, "array")
    end
    names[2] = "b"
    print((names[1] or __K2L_IndexError(0, names.size, "array")) == nil)
    print(names[2] or __K2L_IndexError(1, names.size, "array"))
    print((names[3] or __K2L_IndexError(2, names.size, "array")) == nil)
    local grid = __K2L_ListOfSize(2, nil, "[[I")
    grid:set(0, __K2L_TypedArrayOf("[I", 1, 2))
    print(grid:get(1) == nil)
    print(__K2L_NotNull(grid:get(0)):get(1))
    local s = Slots.new(2)
    s:set(0, "x")
    print(s:get(0) .. " " .. tostring(s:get(1) == nil))
    local ____ok, ____result = __K2L_DeepPcall(function()
        print(names[4] or __K2L_IndexError(3, names.size, "array"))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_ArrayIndexOutOfBoundsException) then
            local e = ____error
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    local ____ok_1, ____result_1 = __K2L_DeepPcall(function()
        print(names[-1 + 1] or __K2L_IndexError(-1, names.size, "array"))
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_ArrayIndexOutOfBoundsException) then
            local e = ____error_1
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
end

__K2L_DeepMain(main)
return {Slots = Slots}
