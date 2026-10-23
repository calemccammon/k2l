local ____lualib = require("lualib_bundle")
local __K2L_AsSequence = ____lualib.__K2L_AsSequence
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Iterator = ____lualib.__K2L_Iterator
local __K2L_IteratorBuilder = ____lualib.__K2L_IteratorBuilder
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Sequence = ____lualib.__K2L_Sequence
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SequenceOf = ____lualib.__K2L_SequenceOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Node = __K2L_Class("Node")

function Node.new(id, children)
    return setmetatable({id = id, children = children}, Node)
end

local function chain(n)
    local node = Node.new(n, __K2L_ListOf())
    for i = n - 1, 0, -1 do
        node = Node.new(i, __K2L_ListOf(node))
    end
    return node
end

local function tree(depth, id)
    if id == nil then
        id = 1
    end
    return Node.new(id, depth == 0 and __K2L_ListOf() or __K2L_ListOf(tree(depth - 1, id * 2), tree(depth - 1, id * 2 + 1)))
end

local function walk(n)
    return __K2L_SequenceBuilder(function(self)
        self:yield(n.id)
        local ____list = n.children
        for ____i = 1, ____list.size do
            local c = ____list[____i]
            self:yieldAll(walk(c))
        end
    end)
end

local function walkIt(n)
    return __K2L_IteratorBuilder(function(____this)
        ____this:yield(n.id)
        local ____list_1 = n.children
        for ____i_1 = 1, ____list_1.size do
            local c = ____list_1[____i_1]
            ____this:yieldAll(walkIt(c))
        end
    end)
end

local log = __K2L_ListOf()

local function countdown(n)
    return __K2L_SequenceBuilder(function(____this_1)
        log:add("start " .. n)
        if n > 0 then
            ____this_1:yield(n)
            ____this_1:yieldAll(countdown(n - 1))
            log:add("after " .. n)
        end
    end)
end

local Boom = __K2L_Class("Boom", __K2L_Exception)

function Boom:____init(message)
    __K2L_Exception.____init(self, message)
end

local function failing(n, at)
    return __K2L_SequenceBuilder(function(____this_2)
        if n == at then
            error(Boom.new("at " .. n))
        end
        ____this_2:yield(n)
        ____this_2:yieldAll(failing(n + 1, at))
    end)
end

local function catching(n, at, catchAt)
    return __K2L_SequenceBuilder(function(____this_3)
        if n == at then
            error(Boom.new("thrown at " .. n))
        end
        ____this_3:yield(n)
        local ____ok, ____result = pcall(function()
            ____this_3:yieldAll(catching(n + 1, at, catchAt))
        end)
        if not ____ok then
            ____ok, ____result = pcall(function()
                local ____error = __K2L_ToThrowable(____result)
                if getmetatable(____error) == Boom then
                    local e = ____error
                    if n ~= catchAt then
                        error(e)
                    end
                    ____this_3:yield(-n)
                else
                    error(____error, 0)
                end
            end)
        end
        if n % 1000 == 0 then
            log:add("finally " .. n)
        end
        if not ____ok then
            error(____result, 0)
        end
    end)
end

local function dive(n)
    return __K2L_SequenceBuilder(function(____this_4)
        if n == 0 then
            error(Boom.new("bottom"))
        end
        ____this_4:yieldAll(dive(n - 1))
    end)
end

local function guarded(n, ____until)
    return __K2L_SequenceBuilder(function(____this_5)
        local ____ok_1, ____result_1 = pcall(function()
            ____this_5:yield(n)
            if n < ____until then
                ____this_5:yieldAll(guarded(n + 1, ____until))
            end
        end)
        if n % 1000 == 0 then
            log:add("finally " .. n)
        end
        if not ____ok_1 then
            error(____result_1, 0)
        end
    end)
end

local Countdown = __K2L_Class("Countdown", __K2L_Sequence)

function Countdown:____init(from)
    self.from = from
end

function Countdown:iterator()
    return __K2L_IteratorBuilder(function(____this_6)
        if self.from > 0 then
            ____this_6:yield(self.from)
            ____this_6:yieldAll(Countdown.new(self.from - 1))
        end
    end)
end

local ____lambda_1 = function(it) return it * 10 end
local function main()
    local root = chain(5000)
    print("sequence: " .. walk(root):count() .. " elements, last " .. walk(root):last())
    local sum = 0
    for _, x in __K2L_Iterator.iter(walkIt(root)) do
        sum = sum + x
    end
    print("iterator: sum " .. sum)
    print("first 5: " .. __K2L_Str(walk(root):take(5):toList()))
    print("tree: " .. __K2L_Str(walk(tree(3)):toList()))
    print("tree iterator: " .. __K2L_Str(__K2L_AsSequence(walkIt(tree(2))):toList()))
    print("class: " .. Countdown.new(3000):count() .. " " .. __K2L_Str(Countdown.new(4):toList()))
    local it = countdown(3):iterator()
    print(it:next() .. " " .. __K2L_Str(log))
    print(it:next() .. " " .. __K2L_Str(log))
    print(__K2L_Str(__K2L_AsSequence(it):toList()) .. " " .. __K2L_Str(log))
    log:clear()
    local partial = walkIt(chain(3))
    partial:next()
    local ahead = walkIt(chain(3))
    ahead:next()
    ahead:hasNext()
    local done = walkIt(chain(0))
    done:next()
    print(__K2L_Str(__K2L_SequenceBuilder(function(____this_7)
        ____this_7:yieldAll(partial)
        ____this_7:yield(-1)
        ____this_7:yieldAll(ahead)
        ____this_7:yieldAll(done)
        ____this_7:yield(-2)
    end):toList()))
    print(tostring(partial:hasNext()) .. " " .. tostring(ahead:hasNext()) .. " " .. tostring(done:hasNext()))
    local mixed = __K2L_SequenceBuilder(function(____this_8)
        ____this_8:yieldAll(__K2L_ListOf(1, 2))
        ____this_8:yieldAll(walk(chain(2)):map(____lambda_1))
        ____this_8:yieldAll(__K2L_SequenceOf(7))
        ____this_8:yieldAll(walk(tree(1)))
    end)
    print(__K2L_Str(mixed:toList()))
    local ____ok_2, ____result_2 = pcall(function()
        failing(0, 4000):count()
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_2)
        if getmetatable(____error_2) == Boom then
            local e = ____error_2
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error_2, 0)
        end
    end
    local ____ok_3, ____result_3 = pcall(function()
        catching(0, 3000, 1000):count()
    end)
    if not ____ok_3 then
        local ____error_3 = __K2L_ToThrowable(____result_3)
        if getmetatable(____error_3) == Boom then
            local e = ____error_3
            print("caught " .. __K2L_Str(e.message))
        else
            error(____error_3, 0)
        end
    end
    print(guarded(0, 2500):count())
    local caughtInside = __K2L_SequenceBuilder(function(____this_9)
        local ____ok_4, ____result_4 = pcall(function()
            ____this_9:yieldAll(failing(0, 3))
        end)
        if not ____ok_4 then
            local ____error_4 = __K2L_ToThrowable(____result_4)
            if getmetatable(____error_4) == Boom then
                local e = ____error_4
                ____this_9:yield(-1)
            else
                error(____error_4, 0)
            end
        end
    end)
    local ____ok_5, ____result_5 = pcall(function()
        print(__K2L_Str(caughtInside:toList()))
    end)
    if not ____ok_5 then
        local ____error_5 = __K2L_ToThrowable(____result_5)
        if getmetatable(____error_5) == Boom then
            local e = ____error_5
            print("not caught inside: " .. __K2L_Str(e.message))
        else
            error(____error_5, 0)
        end
    end
    local function attempt(label, s)
        local got = __K2L_ListOf()
        local ____ok_6, ____result_6 = pcall(function()
            for _, x in s:iter() do
                got:add(x)
            end
            print(label .. ": " .. __K2L_Str(got))
        end)
        if not ____ok_6 then
            local ____error_6 = __K2L_ToThrowable(____result_6)
            if getmetatable(____error_6) == Boom then
                local e = ____error_6
                print(label .. ": " .. __K2L_Str(got) .. ", then " .. __K2L_Str(e.message))
            else
                error(____error_6, 0)
            end
        end
    end
    attempt("before the first element", __K2L_SequenceBuilder(function(____this_10)
        local ____ok_7, ____result_7 = pcall(function()
            ____this_10:yieldAll(failing(3, 3))
        end)
        if not ____ok_7 then
            local ____error_7 = __K2L_ToThrowable(____result_7)
            if getmetatable(____error_7) == Boom then
                local e = ____error_7
                ____this_10:yield(-1)
            else
                error(____error_7, 0)
            end
        end
    end))
    attempt("nested before the first element", __K2L_SequenceBuilder(function(____this_11)
        local ____ok_8, ____result_8 = pcall(function()
            ____this_11:yieldAll(__K2L_SequenceBuilder(function(____this_12)
                ____this_12:yieldAll(__K2L_SequenceBuilder(function(____this_13)
                    error(Boom.new("deep"))
                end))
            end))
        end)
        if not ____ok_8 then
            local ____error_8 = __K2L_ToThrowable(____result_8)
            if getmetatable(____error_8) == Boom then
                local e = ____error_8
                ____this_11:yield(-2)
            else
                error(____error_8, 0)
            end
        end
    end))
    attempt("after some elements", __K2L_SequenceBuilder(function(____this_14)
        ____this_14:yield(1)
        local ____ok_9, ____result_9 = pcall(function()
            ____this_14:yieldAll(failing(5, 5))
        end)
        if not ____ok_9 then
            local ____error_9 = __K2L_ToThrowable(____result_9)
            if getmetatable(____error_9) == Boom then
                local e = ____error_9
                ____this_14:yield(-3)
            else
                error(____error_9, 0)
            end
        end
        ____this_14:yield(2)
    end))
    local started = __K2L_IteratorBuilder(function(____this_15)
        ____this_15:yield(1)
        error(Boom.new("started"))
    end)
    started:next()
    attempt("partly read iterator", __K2L_SequenceBuilder(function(____this_16)
        local ____ok_10, ____result_10 = pcall(function()
            ____this_16:yieldAll(started)
        end)
        if not ____ok_10 then
            local ____error_10 = __K2L_ToThrowable(____result_10)
            if getmetatable(____error_10) == Boom then
                local e = ____error_10
                ____this_16:yield(-4)
            else
                error(____error_10, 0)
            end
        end
    end))
    local buffered = __K2L_IteratorBuilder(function(____this_17)
        ____this_17:yield(1)
        ____this_17:yield(2)
        error(Boom.new("buffered"))
    end)
    buffered:next()
    buffered:hasNext()
    attempt("iterator with a pulled element", __K2L_SequenceBuilder(function(____this_18)
        local ____ok_11, ____result_11 = pcall(function()
            ____this_18:yieldAll(buffered)
        end)
        if not ____ok_11 then
            local ____error_11 = __K2L_ToThrowable(____result_11)
            if getmetatable(____error_11) == Boom then
                local e = ____error_11
                ____this_18:yield(-5)
            else
                error(____error_11, 0)
            end
        end
    end))
    attempt("deep before the first element", __K2L_SequenceBuilder(function(____this_19)
        local ____ok_12, ____result_12 = pcall(function()
            ____this_19:yieldAll(dive(300))
        end)
        if not ____ok_12 then
            local ____error_12 = __K2L_ToThrowable(____result_12)
            if getmetatable(____error_12) == Boom then
                local e = ____error_12
                ____this_19:yield(-7)
            else
                error(____error_12, 0)
            end
        end
    end))
    attempt("deep after the elements", __K2L_SequenceBuilder(function(____this_20)
        local ____ok_13, ____result_13 = pcall(function()
            ____this_20:yieldAll(catching(0, 3000, 0))
        end)
        if not ____ok_13 then
            local ____error_13 = __K2L_ToThrowable(____result_13)
            if getmetatable(____error_13) == Boom then
                local e = ____error_13
                ____this_20:yield(-6)
            else
                error(____error_13, 0)
            end
        end
    end):drop(2999))
    print(__K2L_Str(log))
    local again = walk(chain(10))
    print(again:sum() .. " " .. again:sum())
end

__K2L_RunMain(main)
return {Node = Node, chain = chain, tree = tree, walk = walk, walkIt = walkIt, log = log, countdown = countdown, Boom = Boom, failing = failing, catching = catching, dive = dive, guarded = guarded, Countdown = Countdown}
