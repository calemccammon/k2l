local ____lualib = require("lualib_bundle")
local __K2L_AbstractCoroutineContextElement = ____lualib.__K2L_AbstractCoroutineContextElement
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ContextFold = ____lualib.__K2L_ContextFold
local __K2L_ContextGet = ____lualib.__K2L_ContextGet
local __K2L_ContextMinusKey = ____lualib.__K2L_ContextMinusKey
local __K2L_ContextPlus = ____lualib.__K2L_ContextPlus
local __K2L_CoroutineContext = ____lualib.__K2L_CoroutineContext
local __K2L_EmptyCoroutineContext = ____lualib.__K2L_EmptyCoroutineContext
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_PropertyOverride = ____lualib.__K2L_PropertyOverride
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_StartCoroutine = ____lualib.__K2L_StartCoroutine
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local RequestId
local RequestKey = __K2L_Class("RequestKey")
RequestId = __K2L_Class("RequestId")

function RequestId:____init(id)
    self.id = id
end

function RequestId.new(id)
    return setmetatable({id = id}, RequestId)
end

function RequestId:getKey()
    return RequestKey
end

__K2L_PropertyOverride(RequestId, "key", "getKey")
local Tagged = __K2L_Class("Tagged", __K2L_AbstractCoroutineContextElement)

function Tagged:____init(tag)
    __K2L_AbstractCoroutineContextElement.____init(self, Tagged)
    self.tag = tag
end

function Tagged:getKey()
    return Tagged
end

__K2L_PropertyOverride(Tagged, "key", "getKey")
local Counter = __K2L_Class("Counter")

function Counter:____init(n)
    self.n = n
    self.reads = 0
end

function Counter:getKey()
    self.reads = self.reads + 1
    return Counter
end

__K2L_PropertyOverride(Counter, "key", "getKey")
local MyError = __K2L_Class("MyError", __K2L_Exception)

function MyError:____init(code)
    __K2L_Exception.____init(self)
    self.code = code
end

function MyError:getMessage()
    if self.code > 100 then
        return "huge code"
    end
    return "code " .. self.code
end

function MyError:getCause()
    if self.code > 1 then
        return __K2L_IllegalStateException.new("inner " .. self.code)
    end
    return nil
end

__K2L_PropertyOverride(MyError, "message", "getMessage")
__K2L_PropertyOverride(MyError, "cause", "getCause")
local Parent = __K2L_Class("Parent")

function Parent:getLabel()
    return "parent"
end

local Child = __K2L_Class("Child", Parent)

function Child:____init()
    self.reads = 0
end

function Child:getLabel()
    self.reads = self.reads + 1
    return "child " .. Parent.getLabel(self)
end

local Receiver = __K2L_Class("Receiver")

function Receiver:____init(log)
    self.log = log
    self.own = __K2L_ContextPlus(__K2L_EmptyCoroutineContext, Tagged.new("receiver"))
end

function Receiver:getContext()
    self.log:add("context read")
    return self.own
end

function Receiver:resumeWith(result)
    self.log:add("result " .. __K2L_Str(result:getOrNull()))
end

__K2L_PropertyOverride(Receiver, "context", "getContext")

local function tag()
    local ____receiver = __K2L_ContextGet(__K2L_CoroutineContext(), Tagged)
    return ____receiver and ____receiver.tag or "none"
end

local ____lambda_1 = function(acc, _) return acc + 1 end
local ____lambda_2 = function() return #tag() end
local function main()
    local ctx = __K2L_ContextPlus(__K2L_ContextPlus(__K2L_EmptyCoroutineContext, RequestId.new(7)), Tagged.new("t"))
    local ____receiver_1 = __K2L_ContextGet(ctx, RequestKey)
    print(__K2L_Str(____receiver_1 and ____receiver_1.id))
    local ____receiver_2 = __K2L_ContextGet(ctx, Tagged)
    print(__K2L_Str(____receiver_2 and ____receiver_2.tag))
    print(__K2L_ContextFold(ctx, 0, ____lambda_1))
    local minus = __K2L_ContextMinusKey(ctx, RequestKey)
    print(__K2L_ContextGet(minus, RequestKey) == nil)
    local ____receiver_3 = __K2L_ContextGet(minus, Tagged)
    print(__K2L_Str(____receiver_3 and ____receiver_3.tag))
    local c = Counter.new(1)
    local c2 = __K2L_ContextPlus(__K2L_EmptyCoroutineContext, c)
    local ____receiver_4 = __K2L_ContextGet(c2, Counter)
    print(__K2L_Str(____receiver_4 and ____receiver_4.n))
    print(c.reads > 0)
    local e = MyError.new(3)
    print(e:getMessage())
    local ____receiver_5 = e:getCause()
    print(__K2L_Str(____receiver_5 and ____receiver_5.message))
    local ____ok, ____result = pcall(function()
        error(MyError.new(1))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local x = ____error
            print(__K2L_Str(x.message))
            print(__K2L_Str(x.cause))
        else
            error(____error, 0)
        end
    end
    print(MyError.new(500):getMessage())
    local child = Child.new()
    print(child:getLabel())
    print(child.reads)
    local log = __K2L_ListOf()
    local receiver = Receiver.new(log)
    local block = ____lambda_2
    __K2L_StartCoroutine(block, receiver)
    print(__K2L_Str(log))
end

__K2L_RunMain(main)
return {RequestKey = RequestKey, RequestId = RequestId, Tagged = Tagged, Counter = Counter, MyError = MyError, Parent = Parent, Child = Child, Receiver = Receiver, tag = tag}
