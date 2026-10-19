-- ==== http/Http.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyMapOf = ____lualib.__K2L_ReadOnlyMapOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringEndsWith = ____lualib.__K2L_StringEndsWith
local __K2L_StringEqualsIgnoreCase = ____lualib.__K2L_StringEqualsIgnoreCase
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Method = __K2L_Class("web.http.Method")
__K2L_ClassInfo(Method, "web.http.Method", "web.http.Method", "class")

function Method:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Method:toString()
    return self.name
end

function Method:compareTo(other)
    return self.ordinal - other.ordinal
end

Method.GET = Method.new("GET", 0)
Method.POST = Method.new("POST", 1)
Method.PUT = Method.new("PUT", 2)
Method.DELETE = Method.new("DELETE", 3)
Method.____values = {Method.GET, Method.POST, Method.PUT, Method.DELETE}
local Request = __K2L_Class("web.http.Request")
__K2L_ClassInfo(Request, "web.http.Request", "web.http.Request", "class")

function Request:____init(method, path, headers, body)
    if headers == nil then
        headers = __K2L_ReadOnlyMapOf()
    end
    if body == nil then
        body = ""
    end
    self.method = method
    self.path = path
    self.headers = headers
    self.body = body
    self.____segments_delegate = __K2L_Lazy(function()
        return __K2L_StringSplit(__K2L_Text.trimChars(self.path, 3, "/"), "/"):filter(function(it) return #it > 0 end)
    end)
end

function Request:getSegments()
    return self.____segments_delegate:getValue()
end

function Request:header(name)
    local ____receiver = self.headers:getEntries():firstOrNull(function(it)
        return __K2L_StringEqualsIgnoreCase(it.key, name)
    end)
    return ____receiver and ____receiver.value
end

function Request:withHeader(name, value)
    return Request.new(self.method, self.path, self.headers:plus(__K2L_Pair.new(name, value)), self.body)
end

function Request:toString()
    return "Request(method=" .. __K2L_Str(self.method) .. ", path=" .. self.path .. ", headers=" .. __K2L_Str(self.headers) .. ", body=" .. self.body .. ")"
end

function Request:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.method) + __K2L_Hash(self.path)) + __K2L_Hash(self.headers)) + __K2L_Hash(self.body))
end

function Request:equals(other)
    return getmetatable(other) == Request and self.method == other.method and self.path == other.path and __K2L_Equals(self.headers, other.headers) and self.body == other.body
end

local Response = __K2L_Class("web.http.Response")
__K2L_ClassInfo(Response, "web.http.Response", "web.http.Response", "class")

function Response:____init(status, body, headers)
    if headers == nil then
        headers = __K2L_ReadOnlyMapOf()
    end
    self.status = status
    self.body = body
    self.headers = headers
end

function Response:getOk()
    local ____value = self.status
    return ____value >= 200 and ____value <= 299
end

function Response:toString()
    return "Response(status=" .. self.status .. ", body=" .. self.body .. ", headers=" .. __K2L_Str(self.headers) .. ")"
end

function Response:hashCode()
    return __K2L_ToInt32(31 * __K2L_ToInt32(31 * __K2L_Hash(self.status) + __K2L_Hash(self.body)) + __K2L_Hash(self.headers))
end

function Response:equals(other)
    return getmetatable(other) == Response and self.status == other.status and self.body == other.body and __K2L_Equals(self.headers, other.headers)
end

Response.Companion = __K2L_Class("web.http.Response$Companion")
__K2L_ClassInfo(Response.Companion, "web.http.Response.Companion", "web.http.Response$Companion", "class")

function Response.Companion:ok(body)
    return Response.new(200, body)
end

function Response.Companion:notFound(path)
    return Response.new(404, "no route for " .. path)
end

function Response.Companion:error(status, message)
    return Response.new(status, message)
end

local Handler = __K2L_Class("web.http.Handler")
__K2L_ClassInfo(Handler, "web.http.Handler", "web.http.Handler", "interface")
local HttpException = __K2L_Class("web.http.HttpException", __K2L_RuntimeException)
__K2L_ClassInfo(HttpException, "web.http.HttpException", "web.http.HttpException", "class")

function HttpException:____init(status, message)
    __K2L_RuntimeException.____init(self, message)
    self.status = status
end

local Params = __K2L_Class("web.http.Params")
__K2L_ClassInfo(Params, "web.http.Params", "web.http.Params", "class")

function Params:____init(values)
    self.values = values
end

function Params:get(name)
    local ____value_1 = self.values:get(name)
    if ____value_1 == nil then
        error(HttpException.new(400, "missing parameter " .. name))
    end
    return ____value_1
end

function Params:int(name)
    local ____value_2 = __K2L_StringToIntOrNull(self:get(name))
    if ____value_2 == nil then
        error(HttpException.new(400, "parameter " .. name .. " is not a number: " .. self:get(name)))
    end
    return ____value_2
end

function Params:toString()
    return __K2L_Str(self.values)
end

local function match(pattern, path)
    local parts = __K2L_StringSplit(__K2L_Text.trimChars(pattern, 3, "/"), "/"):filter(function(it) return #it > 0 end)
    if parts.size ~= path.size then
        return nil
    end
    local values = __K2L_MapOf()
    local ____list = parts:zip(path)
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local ____item = ____list[____i]
        local p, s = ____item.first, ____item.second
        if __K2L_StringStartsWith(p, "{") and __K2L_StringEndsWith(p, "}") then
            local ____key = __K2L_Text.substring(p, 1, #p - 1)
            values:set(____key, s)
        elseif p ~= s then
            return nil
        end
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    return Params.new(values)
end

return {Method = Method, Request = Request, Response = Response, Handler = Handler, HttpException = HttpException, Params = Params, match = match}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringToInt = ____lualib.__K2L_StringToInt

local ____Http = require("http.Http")
local ____Middleware = require("middleware.Middleware")
local Router = __K2L_Class("web.Router")
__K2L_ClassInfo(Router, "web.Router", "web.Router", "class")

function Router:____init()
    self.routes = __K2L_ListOf()
    self.handler = __K2L_FunInterface(____Http.Handler, "handle", function(req)
        local ____list = self.routes
        local ____mod = ____list.____modCount
        for ____i = 1, ____list.size do
            local route = ____list[____i]
            do
                if route.method ~= req.method then
                    goto ____continue
                end
                local ____value = ____Http.match(route.pattern, req:getSegments())
                if ____value == nil then
                    goto ____continue
                end
                local params = ____value
                return route.action(req, params)
            end
            ::____continue::
            if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
                break
            end
        end
        return ____Http.Response.Companion:notFound(req.path)
    end)
end

Router.Route = __K2L_Class("web.Router$Route")
__K2L_ClassInfo(Router.Route, "web.Router.Route", "web.Router$Route", "class")

function Router.Route:____init(method, pattern, action)
    self.method = method
    self.pattern = pattern
    self.action = action
end

function Router:get(pattern, action)
    self:add(____Http.Method.GET, pattern, action)
end

function Router:post(pattern, action)
    self:add(____Http.Method.POST, pattern, action)
end

function Router:add(method, pattern, action)
    self.routes:add(Router.Route.new(method, pattern, action))
end

local UserStore = __K2L_Class("web.UserStore")
__K2L_ClassInfo(UserStore, "web.UserStore", "web.UserStore", "class")

function UserStore:____init()
    self.users = __K2L_MapOf(__K2L_Pair.new(1, "ada"), __K2L_Pair.new(2, "grace"))
    self.nextId = 3
end

function UserStore:find(id)
    local ____value_1 = self.users:get(id)
    if ____value_1 == nil then
        error(____Http.HttpException.new(404, "user " .. id .. " not found"))
    end
    return ____value_1
end

function UserStore:add(name)
    if __K2L_StringIsBlank(name) then
        error(__K2L_IllegalArgumentException.new("empty name"))
    end
    local ____object = self.users
    local ____key = self.nextId
    ____object:set(____key, name)
    local ____old = self.nextId
    self.nextId = self.nextId + 1
    return ____old
end

function UserStore:list()
    return self.users:getValues():sorted()
end

local function routes(store)
    local ____value_2 = Router.new()
    ____value_2:get("/health", function(_, _)
        return ____Http.Response.Companion:ok("up")
    end)
    ____value_2:get("/users", function(_, _)
        return ____Http.Response.Companion:ok(store:list():joinToString())
    end)
    ____value_2:get("/users/{id}", function(_, p)
        return ____Http.Response.Companion:ok(store:find(p:int("id")))
    end)
    ____value_2:get("/users/{id}/greeting/{lang}", function(_, p)
        local name = store:find(p:int("id"))
        local greeting
        local ____subject = p:get("lang")
        if ____subject == "en" then
            greeting = "Hello"
        elseif ____subject == "fr" then
            greeting = "Bonjour"
        elseif ____subject == "de" then
            greeting = "Hallo"
        else
            error(____Http.HttpException.new(400, "unknown language " .. p:get("lang")))
        end
        return ____Http.Response.Companion:ok(greeting .. ", " .. name .. "!")
    end)
    ____value_2:post("/users", function(req, _)
        return ____Http.Response.new(201, "created " .. store:add(req.body))
    end)
    ____value_2:get("/crash/{n}", function(_, p)
        return ____Http.Response.Companion:ok(tostring(__K2L_IDiv(100, __K2L_StringToInt(p:get("n")))))
    end)
    return ____value_2
end

local function andThen(self, g)
    return function(a) return g(self(a)) end
end

local function curry(f)
    return function(a)
        return function(b) return f(a, b) end
    end
end

local function main()
    local log = __K2L_ListOf()
    local ____destructured = ____Middleware.counting()
    local counter, counts = ____destructured.first, ____destructured.second
    local cache = ____Middleware.Cache.new(2)
    local store = UserStore.new()
    local chain = ____Middleware.____then(____Middleware.____then(____Middleware.compose(____Middleware.logging(log), ____Middleware.errors, counter, ____Middleware.auth("s3cret")), cache.middleware), ____Middleware.header("X-Path", function(____this)
        return __K2L_Str(____this.method) .. ":" .. ____this:getSegments().size
    end))
    local app = ____Middleware.wrap(chain, routes(store).handler)
    local token = __K2L_SingletonMapOf(__K2L_Pair.new("Authorization", "Bearer s3cret"))
    local requests = __K2L_ReadOnlyListOf(____Http.Request.new(____Http.Method.GET, "/health"), ____Http.Request.new(____Http.Method.GET, "/users"), ____Http.Request.new(____Http.Method.GET, "/users", token), ____Http.Request.new(____Http.Method.GET, "/users/1", token), ____Http.Request.new(____Http.Method.GET, "/users/1", token), ____Http.Request.new(____Http.Method.GET, "/users/9", token), ____Http.Request.new(____Http.Method.GET, "/users/x", token), ____Http.Request.new(____Http.Method.GET, "/users/2/greeting/fr", token), ____Http.Request.new(____Http.Method.GET, "/users/2/greeting/es", token), ____Http.Request.new(____Http.Method.POST, "/users", token, "linus"), ____Http.Request.new(____Http.Method.POST, "/users", token, " "), ____Http.Request.new(____Http.Method.GET, "/users", token), ____Http.Request.new(____Http.Method.GET, "/crash/0", token), ____Http.Request.new(____Http.Method.GET, "/crash/zero", token), ____Http.Request.new(____Http.Method.DELETE, "/users/1", token))
    local ____mod_1 = requests.____modCount
    for ____i_1 = 1, requests.size do
        local r = requests[____i_1]
        local res = app:handle(r)
        local extra = res.headers:getEntries():joinToString(" ", nil, nil, nil, nil, function(it) return it.key .. "=" .. it.value end)
        print(__K2L_Str(r.method) .. " " .. r.path .. " -> " .. res.status .. " " .. res.body .. (#extra == 0 and "" or " [" .. extra .. "]"))
        if requests.____modCount ~= ____mod_1 and requests:____comodified(____i_1) then
            break
        end
    end
    print("log: " .. __K2L_Str(log:take(6)) .. " ... " .. log.size .. " lines")
    print("counts: " .. __K2L_Str(counts()))
    print(cache:stats(function(____this_1, size)
        return "cache hits=" .. ____this_1.hits .. " misses=" .. ____this_1.misses .. " size=" .. size
    end))
    local parse = function(____p1) return __K2L_StringToInt(____p1) end
    local double = andThen(andThen(andThen(parse, function(it) return it * 2 end), function(____p1) return tostring(____p1) end), function(it) return "<" .. it .. ">" end)
    print(double("21"))
    local add = curry(function(a, b) return a + b end)
    local add10 = add(10)
    print(add10(5) .. " " .. add(1)(2) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(1, 2, 3):map(add10)))
    local twice = function(f)
        return function(x) return f(f(x)) end
    end
    print(twice(add10)(0))
    local requestsByMethod = requests:groupingBy(function(it) return it.method end):eachCount()
    print(__K2L_Str(requestsByMethod))
end

main()
return {Router = Router, UserStore = UserStore, routes = routes, andThen = andThen, curry = curry}
-- ==== middleware/Middleware.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_FunInterface = ____lualib.__K2L_FunInterface
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_NumberFormatException = ____lualib.__K2L_NumberFormatException
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____Http = require("http.Http")

local function compose(...)
    local layers = __K2L_ArrayOf(...)
    return function(inner)
        return layers:foldRight(inner, function(layer, acc) return layer(acc) end)
    end
end

local function ____then(self, ____next)
    return function(h) return self(____next(h)) end
end

local function wrap(____this, handler)
    return ____this(handler)
end

local function logging(log, tag)
    if tag == nil then
        tag = "log"
    end
    return function(____next)
        return __K2L_FunInterface(____Http.Handler, "handle", function(req)
            log:add(tag .. "> " .. __K2L_Str(req.method) .. " " .. req.path)
            local res = ____next:handle(req)
            log:add(tag .. "< " .. res.status)
            return res
        end)
    end
end

local function auth(token, publicPrefixes)
    if publicPrefixes == nil then
        publicPrefixes = __K2L_ReadOnlySetOf("/health")
    end
    return function(____next)
        return __K2L_FunInterface(____Http.Handler, "handle", function(req)
            if publicPrefixes:any(function(it) return __K2L_StringStartsWith(req.path, it) end) then
                return ____next:handle(req)
            elseif req:header("Authorization") == "Bearer " .. token then
                return ____next:handle(req:withHeader("X-User", "admin"))
            else
                return ____Http.Response.Companion:error(401, "unauthorized")
            end
        end)
    end
end

local errors = function(____next)
    return __K2L_FunInterface(____Http.Handler, "handle", function(req)
        local ____ok, ____result, ____returned = pcall(function()
            return true, ____next:handle(req)
        end)
        if ____ok then
            if ____result then
                return ____returned
            end
        else
            local ____error = __K2L_ToThrowable(____result)
            if __K2L_InstanceOf(____error, ____Http.HttpException) then
                local e = ____error
                return ____Http.Response.Companion:error(e.status, e.message or "error")
            elseif __K2L_InstanceOf(____error, __K2L_NumberFormatException) then
                local e = ____error
                return ____Http.Response.Companion:error(400, "bad number: " .. __K2L_Str(e.message))
            elseif __K2L_InstanceOf(____error, __K2L_RuntimeException) then
                local e = ____error
                return ____Http.Response.Companion:error(500, __K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
            else
                error(____error, 0)
            end
        end
    end)
end

local function counting()
    local counts = __K2L_SortedMapOf()
    local middleware = function(____next)
        return __K2L_FunInterface(____Http.Handler, "handle", function(req)
            local ____key = req.path
            counts:set(____key, (counts:get(req.path) or 0) + 1)
            return ____next:handle(req)
        end)
    end
    return __K2L_Pair.new(middleware, function() return counts:toMap() end)
end

local Cache = __K2L_Class("web.middleware.Cache")
__K2L_ClassInfo(Cache, "web.middleware.Cache", "web.middleware.Cache", "class")

function Cache:____init(capacity)
    self.capacity = capacity
    self.entries = __K2L_Map.new()
    self.hits = 0
    self.misses = 0
    self.middleware = function(____next)
        return __K2L_FunInterface(____Http.Handler, "handle", function(req)
            if req.method.name ~= "GET" then
                return ____next:handle(req)
            end
            local ____receiver = self.entries:get(req.path)
            if ____receiver ~= nil then
                local ____result_1
                self.hits = self.hits + 1
                return ____Http.Response.new(____receiver.status, ____receiver.body, ____receiver.headers:plus(__K2L_Pair.new("X-Cache", "hit")))
            end
            self.misses = self.misses + 1
            local ____value = ____next:handle(req)
            if ____value:getOk() then
                local ____object = self.entries
                local ____key_1 = req.path
                ____object:set(____key_1, ____value)
                if self.entries.size > self.capacity then
                    self.entries:remove(self.entries:getKeys():first())
                end
            end
            return ____value
        end)
    end
end

function Cache:stats(block)
    return block(self, self.entries.size)
end

local function header(name, value)
    return function(____next)
        return __K2L_FunInterface(____Http.Handler, "handle", function(req)
            local res = ____next:handle(req)
            return ____Http.Response.new(res.status, res.body, res.headers:plus(__K2L_Pair.new(name, value(req))))
        end)
    end
end

return {compose = compose, ____then = ____then, wrap = wrap, logging = logging, auth = auth, errors = errors, counting = counting, Cache = Cache, header = header}
