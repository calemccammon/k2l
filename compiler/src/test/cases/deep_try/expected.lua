local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DeepMain = ____lualib.__K2L_DeepMain
local __K2L_DeepPcall = ____lualib.__K2L_DeepPcall
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_StackOverflowError = ____lualib.__K2L_StackOverflowError
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____exports = {}
local Expr = __K2L_Class("Expr")
local Num = __K2L_Class("Num", Expr)

function Num:____init(n)
    self.n = n
end

function Num.new(n)
    return setmetatable({n = n}, Num)
end

local Add = __K2L_Class("Add", Expr)

function Add:____init(l, r)
    self.l = l
    self.r = r
end

function Add.new(l, r)
    return setmetatable({l = l, r = r}, Add)
end

local Div = __K2L_Class("Div", Expr)

function Div:____init(l, r)
    self.l = l
    self.r = r
end

function Div.new(l, r)
    return setmetatable({l = l, r = r}, Div)
end

local EvalError = __K2L_Class("EvalError", __K2L_Exception)

function EvalError:____init(message)
    __K2L_Exception.____init(self, message)
end

____exports.finallies = 0

local function eval(e)
    local ____ok, ____result, ____returned = __K2L_DeepPcall(function()
        local ____mt = getmetatable(e)
        if ____mt == Num then
            return true, e.n
        elseif ____mt == Add then
            return true, eval(e.l) + eval(e.r)
        elseif ____mt == Div then
            local d = eval(e.r)
            if d == 0 then
                error(EvalError.new("division by zero"))
            end
            return true, __K2L_IDiv(eval(e.l), d)
        end
    end)
    ____exports.finallies = ____exports.finallies + 1
    if not ____ok then
        error(____result, 0)
    end
    if ____result then
        return ____returned
    end
end

local function depthOf(n)
    local ____ok_1, ____result_1, ____returned_1 = __K2L_DeepPcall(function()
        return true, n == 0 and 0 or 1 + depthOf(n - 1)
    end)
    if ____ok_1 then
        if ____result_1 then
            return ____returned_1
        end
    else
        local ____error_1 = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalStateException) then
            local e = ____error_1
            return -1
        else
            error(____error_1, 0)
        end
    end
end

local function catchAt(n, at)
    local ____ok_2, ____result_2, ____returned_2 = __K2L_DeepPcall(function()
        if n == 0 then
            error(__K2L_IllegalStateException.new("bottom"))
        end
        return true, catchAt(n - 1, at)
    end)
    if ____ok_2 then
        if ____result_2 then
            return ____returned_2
        end
    else
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_2, __K2L_IllegalStateException) then
            local e = ____error_2
            if n == at then
                return "caught at " .. n .. ": " .. __K2L_Str(e.message)
            end
            error(e)
        else
            error(____error_2, 0)
        end
    end
end

local function usesRunCatching(n)
    if n == 0 then
        return 0
    else
        return __K2L_RunCatching(function() return usesRunCatching(n - 1) + 1 end):getOrThrow()
    end
end

local Resource = __K2L_Class("Resource")

function Resource:____init(id)
    self.id = id
end

function Resource.new(id)
    return setmetatable({id = id}, Resource)
end

function Resource:close()
    Resource.closed = Resource.closed + 1
end

function Resource:____initCompanion()
    self.closed = 0
end

Resource:____initCompanion()

local function nestedUse(n)
    if n == 0 then
        return 0
    else
        local ____resource = Resource.new(n)
        local ____result_3
        local ____ok_3, ____result_4 = __K2L_DeepPcall(function()
            ____result_3 = nestedUse(n - 1) + 1
        end)
        if ____ok_3 then
            ____resource:close()
        else
            pcall(____resource.close, ____resource)
        end
        if not ____ok_3 then
            error(____result_4, 0)
        end
        return ____result_3
    end
end

local function infinite(n)
    local ____ok_4, ____result_5, ____returned_4 = __K2L_DeepPcall(function()
        return true, infinite(n + 1) + 1
    end)
    ____exports.finallies = ____exports.finallies + 1
    if not ____ok_4 then
        error(____result_5, 0)
    end
    if ____result_5 then
        return ____returned_4
    end
end

local function main()
    local e = Num.new(1)
    for i = 1, 3000 do
        e = Add.new(e, Num.new(i >= 0 and i % 7 or 0 - -i % 7))
    end
    print("eval " .. eval(e) .. " finallies=" .. ____exports.finallies)
    print("depth " .. depthOf(5000))
    print(catchAt(4000, 2500))
    print("runCatching " .. usesRunCatching(1000))
    print("use " .. nestedUse(1000) .. " closed=" .. Resource.closed)
    local ____ok_5, ____result_6 = __K2L_DeepPcall(function()
        eval(Div.new(Num.new(1), Add.new(Num.new(0), Num.new(0))))
    end)
    if not ____ok_5 then
        local ____error_4 = __K2L_ToThrowable(____result_6)
        if getmetatable(____error_4) == EvalError then
            local x = ____error_4
            print("error: " .. __K2L_Str(x.message))
        else
            error(____error_4, 0)
        end
    end
    ____exports.finallies = 0
    local ____ok_6, ____result_7 = __K2L_DeepPcall(function()
        infinite(0)
    end)
    if not ____ok_6 then
        local ____error_5 = __K2L_ToThrowable(____result_7)
        if __K2L_InstanceOf(____error_5, __K2L_StackOverflowError) then
            local x = ____error_5
            print("StackOverflowError, finally blocks ran: " .. tostring(____exports.finallies > 1000))
        else
            error(____error_5, 0)
        end
    end
end

____exports.Expr = Expr
____exports.Num = Num
____exports.Add = Add
____exports.Div = Div
____exports.EvalError = EvalError
____exports.eval = eval
____exports.depthOf = depthOf
____exports.catchAt = catchAt
____exports.usesRunCatching = usesRunCatching
____exports.Resource = Resource
____exports.nestedUse = nestedUse
____exports.infinite = infinite
__K2L_DeepMain(main)
return ____exports
