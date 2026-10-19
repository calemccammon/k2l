-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____tools = require("tools.tools")
local inner

local function firstOr(xs, default, test)
    for _, x in ipairs(xs) do
        if test(x) then
            return x
        end
    end
    return default
end

local function twice(action)
    action()
    action()
end

local function withLog(name, block)
    print("start " .. name)
    local r = block(#name)
    print("end " .. name)
    return r
end

local function findBig(xs)
    local x = 100
    local ____result
    do
        local default = -1
        for _, x in ipairs(xs) do
            local ____result_1
            if x > 50 then
                return "early " .. x
            end
            ____result_1 = x > 3
            if ____result_1 then
                ____result = x
                goto ____inline_end
            end
        end
        ____result = default
        ::____inline_end::
    end
    local found = ____result
    return "found " .. found .. " " .. x
end

local function counter()
    local n = 0
    n = n + 1
    if n == 5 then
        return -1
    end
    n = n + 1
    if n == 5 then
        return -1
    end
    twice(function()
        n = n + 10
    end)
    return n
end

local function shadow()
    local x = 7
    return withLog("abc", function(it) return x + it end)
end

local function early(flag)
    local ____result_2
    do
        print("start " .. "q")
        local ____result_3
        do
            local it = #"q"
            if flag then
                return "bail"
            end
            ____result_3 = it * 2
        end
        local r = ____result_3
        print("end " .. "q")
        ____result_2 = r
    end
    local v = ____result_2
    return "v=" .. v
end

local Box = __K2L_Class("Box")

function Box:____init(items)
    self.items = items
    self.calls = 0
end

function Box:each(action)
    self.calls = self.calls + 1
    for _, i in ipairs(self.items) do
        action(i)
    end
end

function Box:mapFirst(f)
    if self.items:isEmpty() then
        return nil
    end
    return f(self.items:get(0))
end

local function sumUntil(self, limit, onSkip)
    if onSkip == nil then
        onSkip = function(it) end
    end
    local total = 0
    for _, v in ipairs(self) do
        if total + v > limit then
            onSkip(v)
            return total
        end
        total = total + v
    end
    return total
end

local function boxes()
    local b = Box.new(__K2L_ListOf(3, 4, 5))
    local s = 0
    b.calls = b.calls + 1
    for _, i in ipairs(b.items) do
        if i == 5 then
            return "stopped at " .. s .. " calls=" .. b.calls
        end
        s = s + i
    end
    return "done"
end

local function mapFirst()
    local b = Box.new(__K2L_ListOf(2))
    local ____result_4
    do
        if b.items:isEmpty() then
            ____result_4 = nil
            goto ____inline_end_1
        end
        local ____result_5
        do
            local it = b.items:get(0)
            if it > 1 then
                return "big"
            else
                ____result_5 = it
            end
        end
        ____result_4 = ____result_5
        ::____inline_end_1::
    end
    local r = ____result_4
    return "r=" .. __K2L_Str(r)
end

local function sumTest()
    local xs = __K2L_ReadOnlyListOf(1, 2, 3, 4, 5)
    local skipped = -1
    local s = sumUntil(xs, 7, function(it)
        skipped = it
    end)
    local ____result_6
    do
        local total = 0
        for _, v in ipairs(xs) do
            if total + v > 100 then
                do return "never" end
                ____result_6 = total
                goto ____inline_end_2
            end
            total = total + v
        end
        ____result_6 = total
        ::____inline_end_2::
    end
    local t = ____result_6
    local ____result_7
    do
        local total = 0
        for _, v in ipairs(xs) do
            if total + v > 3 then
                do return "skip " .. v end
                ____result_7 = total
                goto ____inline_end_3
            end
            total = total + v
        end
        ____result_7 = total
        ::____inline_end_3::
    end
    local u = ____result_7
    return s .. " " .. skipped .. " " .. t .. " " .. u
end

local function outer(f)
    print("outer>")
    inner(f)
    print("<outer")
end

function inner(g)
    print(" inner>")
    g()
    print(" <inner")
end

local function nested()
    local log = ""
    print("outer>")
    print(" inner>")
    log = log .. "a"
    print("outer>")
    print(" inner>")
    log = log .. "b"
    if #log > 1 then
        return "ret " .. log
    end
    print(" <inner")
    print("<outer")
    print(" <inner")
    print("<outer")
    return "end " .. log
end

local function swap(a, b, use)
    local t = a
    local u = b
    use(u, t)
end

local function swaps()
    local a = 1
    local b = 2
    local out = ""
    do
        local t = b
        local u = a
        out = out .. u .. "," .. t .. ";"
        if u == 99 then
            return "no"
        end
    end
    swap(a, b, function(a2, b2)
        out = out .. a2 .. "," .. b2 .. ";"
    end)
    local t = 10
    local u = 20
    do
        local ____t = t
        local ____u = u
        out = out .. ____u .. "-" .. ____t .. ";"
        if ____t < 0 then
            return "neg"
        end
    end
    return out
end

local function hygiene()
    local t = 5
    local u = 6
    local acc = 0
    do
        local ____t_1 = u
        local ____u_1 = t
        acc = acc + (____u_1 * 10 + ____t_1 + t + u)
        if acc < 0 then
            return -1
        end
    end
    return acc
end

local function loopWith(n, body)
    local i = 0
    while i < n do
        body(i)
        i = i + 1
    end
end

local function loops()
    local i = 100
    local out = ""
    do
        local ____i = 0
        while ____i < 4 do
            do
                local k = ____i
                out = out .. k .. i .. " "
                if k == 2 then
                    return out .. "stop"
                end
            end
            ____i = ____i + 1
        end
    end
    return out
end

local function runAll(kept, wrapped, plain)
    plain()
    return function()
        kept()
        wrapped()
    end
end

local function mixed()
    local s = ""
    local ____result_8
    do
        local kept = function()
            s = s .. "k"
        end
        local wrapped = function()
            s = s .. "w"
        end
        s = s .. "p"
        if s == "x" then
            return "x"
        end
        ____result_8 = function()
            kept()
            wrapped()
        end
    end
    local f = ____result_8
    f()
    f()
    return s
end

local function guarded(f)
    local ____ok, ____result_9 = pcall(function()
        f()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_9)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            return "caught " .. __K2L_Str(e.message)
        else
            error(____error, 0)
        end
    end
    return "ok"
end

local function guards(mode)
    local ____result_10
    do
        local ____ok_1, ____result_11, ____returned_1 = pcall(function()
            if mode == 1 then
                return true, "early"
            end
            if mode == 2 then
                error(__K2L_IllegalStateException.new("two"))
            end
        end)
        if ____ok_1 then
            if ____result_11 then
                return ____returned_1
            end
        else
            local ____error_1 = __K2L_ToThrowable(____result_11)
            if __K2L_InstanceOf(____error_1, __K2L_Exception) then
                local e = ____error_1
                ____result_10 = "caught " .. __K2L_Str(e.message)
                goto ____inline_end_4
            else
                error(____error_1, 0)
            end
        end
        ____result_10 = "ok"
        ::____inline_end_4::
    end
    local r = ____result_10
    return "r=" .. r
end

local function order(xs)
    local log = __K2L_ListOf()
    local function note(s)
        log:add(s)
        return #s
    end
    local total = note("a") + firstOr(xs, note("bb"), function(it)
        note("c")
        return it > 1
    end) * note("ddd")
    local flag = xs:isEmpty() or firstOr(xs, 0, function(it) return it > 100 end) == 0
    return total .. " " .. tostring(flag) .. " " .. __K2L_Str(log)
end

local function withBang(____this, f)
    return f(____this) .. "!"
end

local function letIf(____this_1, cond, f)
    return cond and f(____this_1) or ____this_1
end

local function receivers()
    local a = withBang("hi", function(____this_2) return ____this_2:upper() end)
    local b = letIf("x", true, function(it) return it .. "y" end)
    local ____result_12
    if false then
        local ____result_13
        do return "never" end
        ____result_12 = ____result_13
    else
        ____result_12 = "x"
    end
    local c = ____result_12
    return a .. " " .. b .. " " .. c
end

local Animal = __K2L_Class("Animal")

function Animal:____init(name)
    self.name = name
end

local Dog = __K2L_Class("Dog", Animal)

function Dog:____init(name)
    Animal.____init(self, name)
end

local Cat = __K2L_Class("Cat", Animal)

function Cat:____init(name)
    Animal.____init(self, name)
end

local function reified()
    local items = __K2L_ReadOnlyListOf(Dog.new("d"), Cat.new("c"), "s", 4, Dog.new("e"), true)
    local out = __K2L_ListOf()
    local ____result_14
    do
        local n = 0
        for _, i in ipairs(items) do
            if __K2L_InstanceOf(i, Dog) then
                n = n + 1
            end
        end
        ____result_14 = n
    end
    out:add(tostring(____result_14))
    local ____result_15
    do
        local n = 0
        for _, i in ipairs(items) do
            if __K2L_InstanceOf(i, Animal) then
                n = n + 1
            end
        end
        ____result_15 = n
    end
    out:add(tostring(____result_15))
    local ____result_16
    do
        local n = 0
        for _, i in ipairs(items) do
            if type(i) == "string" then
                n = n + 1
            end
        end
        ____result_16 = n
    end
    out:add(tostring(____result_16))
    local ____result_17
    do
        local n = 0
        for _, i in ipairs(items) do
            if math.type(i) == "integer" then
                n = n + 1
            end
        end
        ____result_17 = n
    end
    out:add(tostring(____result_17))
    local ____result_18
    do
        local n = 0
        for _, i in ipairs(items) do
            if type(i) == "boolean" then
                n = n + 1
            end
        end
        ____result_18 = n
    end
    out:add(tostring(____result_18))
    local ____result_19
    do
        for _, i in ipairs(items) do
            if __K2L_InstanceOf(i, Cat) then
                ____result_19 = i
                goto ____inline_end_5
            end
        end
        ____result_19 = nil
        ::____inline_end_5::
    end
    local ____receiver = ____result_19
    out:add(__K2L_Str(____receiver and ____receiver.name))
    local ____result_20
    do
        for _, i in ipairs(items) do
            if math.type(i) == "integer" then
                ____result_20 = i
                goto ____inline_end_6
            end
        end
        ____result_20 = nil
        ::____inline_end_6::
    end
    out:add(__K2L_Str(____result_20))
    local ____result_21
    do
        for _, i in ipairs(items) do
            if type(i) == "boolean" then
                ____result_21 = i
                goto ____inline_end_7
            end
        end
        ____result_21 = nil
        ::____inline_end_7::
    end
    out:add(__K2L_Str(____result_21))
    local ____result_22
    do
        local x = Dog.new("x")
        ____result_22 = __K2L_InstanceOf(x, Dog) and "yes" or "no"
    end
    out:add(____result_22)
    local ____result_23
    do
        local x = Dog.new("x")
        ____result_23 = __K2L_InstanceOf(x, Cat) and "yes" or "no"
    end
    out:add(____result_23)
    local ____result_24
    do
        local x = Dog.new("z")
        ____result_24 = __K2L_InstanceOf(x, Dog) and x or nil
    end
    local ____receiver_1 = ____result_24
    out:add(__K2L_Str(____receiver_1 and ____receiver_1.name))
    local ____result_25
    do
        local x = Cat.new("z")
        ____result_25 = __K2L_InstanceOf(x, Dog) and x or nil
    end
    out:add(__K2L_Str(____result_25))
    local ____result_26
    do
        local ____result_27
        do
            local n = 0
            for _, i in ipairs(items) do
                if __K2L_InstanceOf(i, Animal) then
                    n = n + 1
                end
            end
            ____result_27 = n
        end
        local ____result_28
        do
            local n = 0
            for _, i in ipairs(items) do
                if type(i) == "string" then
                    n = n + 1
                end
            end
            ____result_28 = n
        end
        ____result_26 = ____result_27 .. "/" .. ____result_28
    end
    out:add(____result_26)
    return out:joinToString(",")
end

local function elsewhere(stopAt)
    local a = ____tools.attempt(3, function(n)
        if n < 2 then
            return nil
        else
            return "n=" .. n
        end
    end)
    local ____result_29
    do
        local ____result_30
        if a == "never" then
            return "returned early"
        end
        ____result_30 = nil
        local v = ____result_30
        if v == nil then
            ____result_29 = ____tools.decorate("none")
            goto ____inline_end_8
        end
        ____result_29 = v
        ::____inline_end_8::
    end
    local b = ____result_29
    local c = ____tools.fallback("none", function() return "given" end)
    local ____result_31
    do
        for i = 0, 2 do
            local ____result_32
            if i == 9 then
                return "nine"
            else
                ____result_32 = i == 2 and "two" or nil
            end
            local r = ____result_32
            if r ~= nil then
                ____result_31 = r
                goto ____inline_end_9
            end
        end
        ____result_31 = nil
        ::____inline_end_9::
    end
    local d = ____result_31
    local seen = ""
    do
        local items = __K2L_ReadOnlyListOf("a", "b", "c", "d")
        local ____i_1 = 0
        for _, item in ipairs(items) do
            local ____result_33
            do
                local i = ____i_1
                seen = seen .. i .. item
                if item == stopAt then
                    return "stopped " .. seen
                end
                ____result_33 = true
            end
            if not ____result_33 then
                break
            end
            ____i_1 = ____i_1 + 1
        end
    end
    local ____result_34
    do
        local keys = __K2L_ReadOnlyListOf("x", "y", "x")
        local counts = __K2L_MapOf()
        for _, k in ipairs(keys) do
            local ____result_35
            if k == "z" then
                return "z!"
            else
                ____result_35 = k
            end
            local mapped = ____result_35
            counts:set(mapped, (counts:get(mapped) or 0) + 1)
        end
        ____result_34 = counts
    end
    local counts = ____result_34
    return __K2L_Str(a) .. " " .. b .. " " .. c .. " " .. __K2L_Str(d) .. " " .. seen .. " " .. __K2L_Str(counts)
end

local Tracker = __K2L_Class("Tracker")

function Tracker:____init(name)
    self.name = name
    self.count = 0
end

function Tracker:visit(n, f)
    for i = 0, n - 1 do
        self.count = self.count + 1
        f(self, i)
    end
end

function Tracker:apply2(f)
    local r = f(self)
    return r + self.count
end

function Tracker:id()
    return self.name
end

local Client = __K2L_Class("Client")

function Client:____init(label)
    self.label = label
    self.other = Tracker.new("other")
end

function Client:plain()
    local out = ""
    self.other:visit(2, function(____this_3, i)
        out = out .. i .. ____this_3.name .. ";"
    end)
    return out
end

function Client:run()
    local out = ""
    do
        local ____this_4 = self.other
        for ____i_2 = 0, 2 do
            ____this_4.count = ____this_4.count + 1
            out = out .. ____i_2 .. ":" .. ____this_4.name .. ":" .. self.label .. ";"
            if ____i_2 == 1 then
                return out .. "early"
            end
        end
    end
    local ____result_36
    do
        local ____this_5 = self.other
        local ____result_37
        if ____this_5.count > 10 then
            return "big"
        end
        ____result_37 = ____this_5.count * 2 + #self.label
        local r = ____result_37
        ____result_36 = r + ____this_5.count
    end
    local x = ____result_36
    return out .. " " .. x .. " " .. self.other.count
end

local function tap(____this_6, f)
    f(____this_6)
    return ____this_6
end

local function mapNotNullFirst(xs, f)
    for _, x in ipairs(xs) do
        local r = f(x)
        if r ~= nil then
            return r
        end
    end
    return nil
end

local function labeled(xs)
    local ____result_38
    do
        for _, x in ipairs(xs) do
            local ____result_39
            do
                if x == "skip" then
                    ____result_39 = nil
                    goto ____inline_end_10
                end
                if x == "stop" then
                    return "stopped"
                end
                ____result_39 = #x
                ::____inline_end_10::
            end
            local r = ____result_39
            if r ~= nil then
                ____result_38 = r
                goto ____inline_end_11
            end
        end
        ____result_38 = nil
        ::____inline_end_11::
    end
    local r = ____result_38
    return "r=" .. __K2L_Str(r)
end

local function chain()
    local sb = __K2L_StringBuilder.new()
    local t = tap(tap(Tracker.new("t"), function(____this_7)
        ____this_7.count = 5
    end), function(____this_8)
        sb:append(tostring(____this_8.count))
    end)
    return sb:toString() .. t.count
end

local function whenUse(n)
    local v
    if n == 0 then
        local ____result_40
        do
            local xs = __K2L_SingletonListOf("a")
            for _, x in ipairs(xs) do
                local ____result_41
                if n == 0 then
                    return "zero"
                else
                    ____result_41 = 1
                end
                local r = ____result_41
                if r ~= nil then
                    ____result_40 = r
                    goto ____inline_end_12
                end
            end
            ____result_40 = nil
            ::____inline_end_12::
        end
        v = ____result_40
    else
        v = mapNotNullFirst(__K2L_SingletonListOf("abc"), function(it) return #it end)
    end
    return "v=" .. __K2L_Str(v)
end

local function main()
    print(findBig(__K2L_ReadOnlyListOf(1, 2, 5, 9)))
    print(findBig(__K2L_ReadOnlyListOf(1, 2, 3)))
    print(findBig(__K2L_ReadOnlyListOf(1, 60, 3)))
    print(counter())
    print(shadow())
    print(early(true))
    print(early(false))
    print(boxes())
    print(mapFirst())
    print(sumTest())
    print(nested())
    print(swaps())
    print(hygiene())
    print(loops())
    print(mixed())
    print(receivers())
    print(guards(0))
    print(guards(1))
    print(guards(2))
    print(order(__K2L_ReadOnlyListOf(1, 2, 3)))
    print(order(__K2L_ReadOnlyListOf()))
    print(reified())
    print(Client.new("L"):run())
    print(Client.new("L"):plain())
    print(labeled(__K2L_ReadOnlyListOf("skip", "abc")))
    print(labeled(__K2L_ReadOnlyListOf("skip", "stop", "abc")))
    print(labeled(__K2L_ReadOnlyListOf()))
    print(chain())
    print(whenUse(0))
    print(whenUse(1))
    print(elsewhere("c"))
    print(elsewhere("zzz"))
end

main()
return {firstOr = firstOr, twice = twice, withLog = withLog, findBig = findBig, counter = counter, shadow = shadow, early = early, Box = Box, sumUntil = sumUntil, boxes = boxes, mapFirst = mapFirst, sumTest = sumTest, outer = outer, inner = inner, nested = nested, swap = swap, swaps = swaps, hygiene = hygiene, loopWith = loopWith, loops = loops, runAll = runAll, mixed = mixed, guarded = guarded, guards = guards, order = order, withBang = withBang, letIf = letIf, receivers = receivers, Animal = Animal, Dog = Dog, Cat = Cat, reified = reified, elsewhere = elsewhere, Tracker = Tracker, Client = Client, tap = tap, mapNotNullFirst = mapNotNullFirst, labeled = labeled, chain = chain, whenUse = whenUse}
-- ==== tools/tools.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_MapOf = ____lualib.__K2L_MapOf

local prefix = "tools"

local function decorate(s)
    return prefix .. ":" .. s
end

local function attempt(times, block)
    for i = 0, times - 1 do
        local r = block(i)
        if r ~= nil then
            return r
        end
    end
    return nil
end

local function fallback(default, compute)
    local v = compute()
    if v == nil then
        return decorate(default)
    end
    return v
end

local function eachIndexedWhile(items, step)
    local i = 0
    for _, item in ipairs(items) do
        if not step(i, item) then
            break
        end
        i = i + 1
    end
end

local function tally(keys, key)
    local counts = __K2L_MapOf()
    for _, k in ipairs(keys) do
        local mapped = key(k)
        counts:set(mapped, (counts:get(mapped) or 0) + 1)
    end
    return counts
end

return {prefix = prefix, decorate = decorate, attempt = attempt, fallback = fallback, eachIndexedWhile = eachIndexedWhile, tally = tally}
