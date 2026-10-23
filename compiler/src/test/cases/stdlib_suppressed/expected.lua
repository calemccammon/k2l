local ____lualib = require("lualib_bundle")
local __K2L_ArithmeticException = ____lualib.__K2L_ArithmeticException
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CloseAfter = ____lualib.__K2L_CloseAfter
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Suppressed = ____lualib.__K2L_Suppressed
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException

local Resource = __K2L_Class("Resource")

function Resource.new(name, failClose, log)
    return setmetatable({name = name, failClose = failClose, log = log}, Resource)
end

function Resource:close()
    self.log:add("close " .. self.name)
    if self.failClose then
        error(__K2L_IllegalStateException.new("close " .. self.name .. " failed"))
    end
end

local function report(e)
    local ____arg = __K2L_Str(e.message)
    local ____list = __K2L_Suppressed(e)
    local ____out = {}
    local ____count = 0
    local ____items, ____n = ____list:____array()
    for ____i = 1, ____n do
        local it = ____items[____i]
        ____count = ____count + 1
        ____out[____count] = it.message
    end
    return ____arg .. " suppressed=" .. __K2L_Str(__K2L_ListWrap(____out, ____count))
end

local function main()
    local ____main = __K2L_RuntimeException.new("main")
    print(__K2L_Str(__K2L_Suppressed(____main)))
    ____main:addSuppressed(__K2L_IllegalArgumentException.new("first"))
    ____main:addSuppressed(__K2L_UnsupportedOperationException.new("second"))
    print(report(____main))
    local ____list_1 = __K2L_Suppressed(____main)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_1 = 1, ____n_1 do
        local it = ____items_1[____i_1]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = __K2L_SimpleName(it)
    end
    print(__K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print(__K2L_Suppressed(____main).size)
    ____main:addSuppressed(____main)
    print("self ignored: " .. __K2L_Suppressed(____main).size)
    local copy = __K2L_Suppressed(____main)
    ____main:addSuppressed(__K2L_Exception.new("third"))
    print("copy " .. copy.size .. ", now " .. __K2L_Suppressed(____main).size)
    local log = __K2L_ListOf()
    local ____ok, ____result = pcall(function()
        local ____resource = Resource.new("a", true, log)
        local ____result_1
        local ____ok_1, ____result_2 = pcall(function()
            local ____result_3
            error(__K2L_IllegalStateException.new("body failed"))
            ____result_1 = ____result_3
        end)
        if ____ok_1 then
            ____resource:close()
        else
            __K2L_CloseAfter(____resource, ____result_2)
        end
        if not ____ok_1 then
            error(____result_2, 0)
        end
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print(report(e))
            local ____value = __K2L_Suppressed(e):first()
            print(__K2L_InstanceOf(____value, __K2L_IllegalStateException))
        else
            error(____error, 0)
        end
    end
    local ____ok_2, ____result_4 = pcall(function()
        local ____resource_1 = Resource.new("b", true, log)
        local ____result_5
        local ____ok_3, ____result_6 = pcall(function()
            ____result_5 = "ok"
        end)
        if ____ok_3 then
            ____resource_1:close()
        else
            __K2L_CloseAfter(____resource_1, ____result_6)
        end
        if not ____ok_3 then
            error(____result_6, 0)
        end
    end)
    if not ____ok_2 then
        local ____error_1 = __K2L_ToThrowable(____result_4)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            print("thrown: " .. report(e))
        else
            error(____error_1, 0)
        end
    end
    local ____ok_4, ____result_7 = pcall(function()
        local ____resource_2 = Resource.new("outer", true, log)
        local ____result_8
        local ____ok_5, ____result_9 = pcall(function()
            local ____result_10
            do
                local ____resource_3 = Resource.new("inner", true, log)
                local ____result_11
                local ____ok_6, ____result_12 = pcall(function()
                    local ____result_13
                    error(__K2L_IllegalStateException.new("nested body"))
                    ____result_11 = ____result_13
                end)
                if ____ok_6 then
                    ____resource_3:close()
                else
                    __K2L_CloseAfter(____resource_3, ____result_12)
                end
                if not ____ok_6 then
                    error(____result_12, 0)
                end
            end
            ____result_8 = ____result_10
        end)
        if ____ok_5 then
            ____resource_2:close()
        else
            __K2L_CloseAfter(____resource_2, ____result_9)
        end
        if not ____ok_5 then
            error(____result_9, 0)
        end
    end)
    if not ____ok_4 then
        local ____error_2 = __K2L_ToThrowable(____result_7)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            print(report(e))
            local ____list_2 = __K2L_Suppressed(e)
            local ____out_2 = {}
            local ____count_2 = 0
            local ____items_2, ____n_2 = ____list_2:____array()
            for ____i_2 = 1, ____n_2 do
                local it = ____items_2[____i_2]
                ____count_2 = ____count_2 + 1
                ____out_2[____count_2] = report(it)
            end
            print(__K2L_Str(__K2L_ListWrap(____out_2, ____count_2)))
        else
            error(____error_2, 0)
        end
    end
    local ____ok_7, ____result_14 = pcall(function()
        local ____resource_4 = Resource.new("c", false, log)
        local ____result_15
        local ____ok_8, ____result_16 = pcall(function()
            local ____result_17
            error(__K2L_ArithmeticException.new("plain"))
            ____result_15 = ____result_17
        end)
        if ____ok_8 then
            ____resource_4:close()
        else
            __K2L_CloseAfter(____resource_4, ____result_16)
        end
        if not ____ok_8 then
            error(____result_16, 0)
        end
    end)
    if not ____ok_7 then
        local ____error_3 = __K2L_ToThrowable(____result_14)
        if __K2L_InstanceOf(____error_3, __K2L_ArithmeticException) then
            local e = ____error_3
            print(report(e))
        else
            error(____error_3, 0)
        end
    end
    local ____resource_5 = Resource.new("d", false, log)
    local ____result_18
    local ____ok_9, ____result_19 = pcall(function()
        ____result_18 = 42
    end)
    if ____ok_9 then
        ____resource_5:close()
    else
        __K2L_CloseAfter(____resource_5, ____result_19)
    end
    if not ____ok_9 then
        error(____result_19, 0)
    end
    print(____result_18)
    print(__K2L_Str(log))
    local outer = __K2L_IllegalStateException.new("outer", ____main)
    outer:addSuppressed(__K2L_ArithmeticException.new("side"))
    local ____arg_1 = __K2L_Suppressed(outer).size
    local ____receiver = outer.cause
    local ____receiver_1 = ____receiver and __K2L_Suppressed(____receiver)
    print(__K2L_Str(__K2L_ListOf(____arg_1, ____receiver_1 and ____receiver_1.size)))
end

__K2L_RunMain(main)
return {Resource = Resource, report = report}
