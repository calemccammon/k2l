local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Response = __K2L_Class("Response")

function Response.new(status, body, note)
    return setmetatable({status = status, body = body, note = note}, Response)
end

function Response:getOk()
    local ____value = self.status
    return ____value >= 200 and ____value <= 299
end

__K2L_DataClass(Response, {"status", "body", "note"})
Response.Companion = __K2L_Class("Response$Companion")

function Response.Companion:____init()
    self.note = "companion note"
end

function Response.Companion:ok(body)
    return Response.new(200, body)
end

function Response.Companion:copy(r)
    return Response.new(r.status, r.body .. "!", r.note)
end

function Response.Companion:toString()
    return "Response.Companion"
end

Response.Companion:____init()
local Counter = __K2L_Class("Counter")

function Counter.new(count)
    return setmetatable({count = count}, Counter)
end

function Counter:count__1(by)
    return self.count + by
end

Counter.Companion = __K2L_Class("Counter$Companion")

function Counter.Companion:____init()
    self.count = 100
end

function Counter.Companion:count__1()
    local ____old = self.count
    self.count = self.count + 1
    return ____old
end

Counter.Companion:____init()

local function main()
    local r = Response.Companion:ok("hi")
    print(__K2L_Str(r) .. " " .. tostring(r:getOk()) .. " " .. __K2L_Str(r.note) .. " " .. Response.Companion.note .. " " .. __K2L_Str(Response.Companion:copy(r)) .. " " .. __K2L_Str(Response.Companion))
    local c = Counter.new(1)
    print(c.count .. " " .. c:count__1(5) .. " " .. Counter.Companion:count__1() .. " " .. Counter.Companion:count__1() .. " " .. Counter.Companion.count)
    local companion = Response.Companion
    print(__K2L_Str(companion))
end

__K2L_RunMain(main)
return {Response = Response, Counter = Counter}
