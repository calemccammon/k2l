local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_IndexError = ____lualib.__K2L_IndexError
local __K2L_IsLetterOrDigit = ____lualib.__K2L_IsLetterOrDigit
local __K2L_IsWhitespace = ____lualib.__K2L_IsWhitespace
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StrByte = ____lualib.__K2L_StrByte
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringLines = ____lualib.__K2L_StringLines
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_StringTrimEnd = ____lualib.__K2L_StringTrimEnd
local __K2L_StringTrimStart = ____lualib.__K2L_StringTrimStart
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local unquote
local ConfigError = __K2L_Class("ConfigError", __K2L_RuntimeException)

function ConfigError:____init(msg, line)
    if line == nil then
        line = 0
    end
    __K2L_RuntimeException.____init(self, line > 0 and "line " .. line .. ": " .. msg or msg)
    self.line = line
end

local RawConfig = __K2L_Class("RawConfig")

function RawConfig:____init()
    self.sections = __K2L_MapOf()
    self.order = __K2L_ListOf()
end

local ____lambda_1 = function() return __K2L_MapOf() end
local ____lambda_2 = function(it)
    return __K2L_IsLetterOrDigit[it] == true or it == "_" or it == "-"
end
local function parseIni(text)
    local cfg = RawConfig.new()
    local section = "general"
    local lastKey = nil
    local header = __K2L_Regex.new("^\\[\\s*([\\w.-]+)\\s*]$", "^%[%s*([%w_%.%-]+)%s*%]$")
    local ____list = __K2L_StringLines(text)
    for idx = 0, ____list.size - 1 do
        local rawLine = ____list[idx + 1]
        local n = idx + 1
        local line = __K2L_StringTrimEnd(rawLine)
        local trimmed = __K2L_StringTrimStart(line)
        if #trimmed == 0 or (0 >= 0 and __K2L_StrByte(trimmed, 0 + 1) or __K2L_IndexError(0, #trimmed, "string")) == 59 or (0 >= 0 and __K2L_StrByte(trimmed, 0 + 1) or __K2L_IndexError(0, #trimmed, "string")) == 35 then
            lastKey = nil
        elseif __K2L_IsWhitespace[0 >= 0 and 0 < #line and line:sub(0 + 1, 0 + 1) or __K2L_IndexError(0, #line, "string")] == true and lastKey ~= nil then
            local map = cfg.sections:getValue(section)
            local ____destructured = map:getValue(lastKey)
            local old, at = ____destructured.first, ____destructured.second
            local ____key_1 = lastKey
            map:set(____key_1, __K2L_Pair.new(old .. " " .. trimmed, at))
        elseif __K2L_StringStartsWith(trimmed, "[") then
            local ____receiver = header:matchEntire(trimmed)
            local ____receiver_1 = ____receiver and ____receiver.groupValues
            local ____receiver_2 = ____receiver_1 and ____receiver_1:get(1)
            local ____value = ____receiver_2 and ____receiver_2:lower()
            if ____value == nil then
                error(ConfigError.new("bad section header '" .. trimmed .. "'", n))
            end
            section = ____value
            if not cfg.sections:containsKey(section) then
                cfg.order:add(section)
            end
            cfg.sections:getOrPut(section, ____lambda_1)
            lastKey = nil
        else
            local eq = __K2L_Text.indexOfAny(trimmed, __K2L_ArrayOf("=", ":"))
            if eq <= 0 then
                error(ConfigError.new("expected key = value, got '" .. trimmed .. "'", n))
            end
            local key = __K2L_StringTrim(__K2L_Text.substring(trimmed, 0, eq)):lower()
            if not __K2L_StringToList(key):all(____lambda_2) then
                error(ConfigError.new("invalid key '" .. key .. "'", n))
            end
            local value = __K2L_StringTrim(__K2L_Text.substring(trimmed, eq + 1))
            if #value >= 2 and __K2L_Text.first(value) == "\"" and __K2L_Text.last(value) == "\"" then
                value = unquote(__K2L_Text.substring(value, 1, #value - 1), n)
            else
                value = __K2L_StringTrimEnd(__K2L_Text.substringBefore(__K2L_Text.substringBefore(value, " ;"), " #"))
            end
            if not cfg.sections:containsKey(section) then
                cfg.order:add(section)
                local ____object = cfg.sections
                local ____key = section
                ____object:set(____key, __K2L_MapOf())
            end
            local ____object_1 = cfg.sections:getValue(section)
            ____object_1:set(key, __K2L_Pair.new(value, n))
            lastKey = key
        end
    end
    return cfg
end

function unquote(s, line)
    local ____builder = __K2L_StringBuilder.new()
    do
        local i = 0
        while i < #s do
            do
                local ____old = i
                i = i + 1
                local c = ____old >= 0 and ____old < #s and s:sub(____old + 1, ____old + 1) or __K2L_IndexError(____old, #s, "string")
                if c ~= "\\" then
                    ____builder:append(c)
                    goto ____continue
                end
                if i >= #s then
                    error(ConfigError.new("dangling backslash", line))
                end
                local ____old_1 = i
                i = i + 1
                local e = ____old_1 >= 0 and ____old_1 < #s and s:sub(____old_1 + 1, ____old_1 + 1) or __K2L_IndexError(____old_1, #s, "string")
                if e == "n" then
                    ____builder:append("\n")
                elseif e == "t" then
                    ____builder:append("\t")
                elseif e == "$" then
                    ____builder:append("$\000")
                elseif e == "\\" or e == "\"" then
                    ____builder:append(e)
                else
                    error(ConfigError.new("unknown escape \\" .. e, line))
                end
            end
            ::____continue::
        end
    end
    return ____builder:toString()
end

local Resolver = __K2L_Class("Resolver")

function Resolver:____init(raw, env)
    self.raw = raw
    self.env = env
    self.cache = __K2L_Map.new()
    self.stack = __K2L_ArrayDeque.new()
    self.ref = __K2L_Regex.new("\\$\\{([^}]*)}", "%${([^%}]*)}")
end

function Resolver:get(section, key)
    local full = section .. "." .. key
    local ____receiver_3 = self.cache:get(full)
    if ____receiver_3 ~= nil then
        local ____result
        return ____receiver_3
    end
    if self.stack:contains(full) then
        error(ConfigError.new("interpolation cycle: " .. self.stack:dropWhile(function(it) return it ~= full end):plus(full):joinToString(" -> ")))
    end
    local ____receiver_4 = self.raw.sections:get(section)
    local ____value_1 = ____receiver_4 and ____receiver_4:get(key)
    if ____value_1 == nil then
        error(ConfigError.new("missing key '" .. full .. "'"))
    end
    local value, line = ____value_1.first, ____value_1.second
    self.stack:addLast(full)
    local ____ok, ____result_1, ____returned = pcall(function()
        local out = self.ref:replace(value, function(m)
            return self:lookup(section, __K2L_StringTrim(m.groupValues:get(1)), line)
        end)
        local ____object_2 = self.cache
        ____object_2:set(full, out)
        return true, out
    end)
    self.stack:removeLast()
    if not ____ok then
        error(____result_1, 0)
    end
    if ____result_1 then
        return ____returned
    end
end

function Resolver:lookup(section, expr, line)
    if #expr == 0 then
        error(ConfigError.new("empty reference", line))
    elseif __K2L_StringStartsWith(expr, "env:") then
        local spec = __K2L_Text.removePrefix(expr, "env:")
        local name = __K2L_Text.substringBefore(spec, ":-")
        local ____value_2 = self.env:get(name)
        if ____value_2 == nil then
            local ____temp
            if __K2L_StringContains(spec, ":-") then
                ____temp = __K2L_Text.substringAfter(spec, ":-")
            else
                error(ConfigError.new("environment variable " .. name .. " is not set", line))
            end
            ____value_2 = ____temp
        end
        return ____value_2
    elseif __K2L_StringContains(expr, ".") then
        return self:get(__K2L_Text.substringBeforeLast(expr, "."):lower(), __K2L_Text.substringAfterLast(expr, "."):lower())
    else
        return self:get(section, expr:lower())
    end
end

function Resolver:resolved(section)
    local ____receiver_5 = self.raw.sections:get(section)
    local ____receiver_6 = ____receiver_5 and ____receiver_5:getKeys()
    local ____result_3
    if ____receiver_6 ~= nil then
        local ____result_2 = __K2L_Map.new()
        local ____items, ____n = ____receiver_6:____array()
        for ____i = 1, ____n do
            local it = ____items[____i]
            local ____value_3 = __K2L_StringReplace(self:get(section, it), "$\000", "$")
            ____result_2:put(it, ____value_3)
        end
        ____result_3 = ____result_2
    end
    return ____result_3 or __K2L_MapOf()
end

local ServerSettings = __K2L_Class("ServerSettings")

function ServerSettings:____init(values)
    self.values = values
    self.____host_delegate = __K2L_Lazy(function() return self.values:get("host") or "localhost" end)
    self.____port_delegate = __K2L_Lazy(function()
        local ____receiver_7 = self.values:get("port")
        local ____receiver_8 = ____receiver_7 and __K2L_StringToIntOrNull(____receiver_7)
        local ____value_4 = ____receiver_8 and (____receiver_8 >= 1 and ____receiver_8 <= 65535 and ____receiver_8 or nil)
        if ____value_4 == nil then
            error(ConfigError.new("port must be 1..65535, was '" .. __K2L_Str(self.values:get("port")) .. "'"))
        end
        return ____value_4
    end)
    self.____debug_delegate = __K2L_Lazy(function()
        local ____receiver_9 = self.values:get("debug")
        local ____subject = ____receiver_9 and ____receiver_9:lower()
        if ____subject == nil or ____subject == "false" or ____subject == "no" or ____subject == "off" or ____subject == "0" then
            return false
        elseif ____subject == "true" or ____subject == "yes" or ____subject == "on" or ____subject == "1" then
            return true
        else
            error(ConfigError.new("not a boolean: " .. __K2L_Str(self.values:get("debug"))))
        end
    end)
    self.____timeouts_delegate = __K2L_Lazy(function()
        local ____list_1 = __K2L_StringSplit(self.values:get("timeouts") or "", ",")
        local ____out = {}
        local ____count = 0
        local ____items_1, ____n_1 = ____list_1:____array()
        for ____i_1 = 1, ____n_1 do
            local it = ____items_1[____i_1]
            if not __K2L_StringIsBlank(it) then
                ____count = ____count + 1
                ____out[____count] = it
            end
        end
        local ____list_2 = __K2L_ListWrap(____out, ____count)
        local ____out_1 = {}
        local ____count_1 = 0
        local ____items_2, ____n_2 = ____list_2:____array()
        for ____i_2 = 1, ____n_2 do
            local it = ____items_2[____i_2]
            ____count_1 = ____count_1 + 1
            ____out_1[____count_1] = __K2L_StringToDouble(__K2L_StringTrim(it))
        end
        return __K2L_ListWrap(____out_1, ____count_1)
    end)
end

function ServerSettings:getHost()
    return self.____host_delegate:getValue()
end

function ServerSettings:getPort()
    return self.____port_delegate:getValue()
end

function ServerSettings:getDebug()
    return self.____debug_delegate:getValue()
end

function ServerSettings:getTimeouts()
    return self.____timeouts_delegate:getValue()
end

function ServerSettings:toString()
    return "Server(" .. self:getHost() .. ":" .. self:getPort() .. " debug=" .. tostring(self:getDebug()) .. " timeouts=" .. __K2L_Str(self:getTimeouts()) .. ")"
end

local base = __K2L_Text.trimIndent("\n; global settings\napp = shop\nversion = 2.3.1\nhome = /srv/" .. "$" .. "{app}\n\n[database]\nhost = db.internal\nport = 5432\nurl = postgres://" .. "$" .. "{user}@" .. "$" .. "{host}:" .. "$" .. "{port}/" .. "$" .. "{general.app}\nuser = " .. "$" .. "{env:DB_USER:-app}\npassword = \"s3cr\\" .. "$" .. "t \\\"quoted\\\"\"\n\n[server]\nhost = 0.0.0.0\nport = 8080\ndebug = off\ntimeouts = 1.5, 3,\n   10.25\nbanner: Welcome to " .. "$" .. "{general.app} v" .. "$" .. "{general.version} ; trailing comment\nlogdir = " .. "$" .. "{general.home}/logs\n\n[paths]\na = " .. "$" .. "{b}\nb = " .. "$" .. "{c}\nc = " .. "$" .. "{a}\n")
local overlay = __K2L_Text.trimIndent("\n[server]\nport = 9090\ndebug = YES\n")

local ____lambda_3 = function() return __K2L_MapOf() end
local ____lambda_4 = function()
    return Resolver.new(parseIni("x = ${env:NOPE}"), __K2L_MapOf()):get("general", "x")
end
local ____lambda_5 = function()
    return ServerSettings.new(__K2L_MapOf(__K2L_Pair.new("port", "70000"))):getPort()
end
local ____lambda_6 = function()
    return ServerSettings.new(__K2L_MapOf(__K2L_Pair.new("debug", "maybe"))):getDebug()
end
local function main()
    local raw = parseIni(base)
    local over = parseIni(overlay)
    local ____map = over.sections
    local ____keys, ____values, ____n_3 = ____map:____arrays()
    for ____i_3 = 1, ____n_3 do
        local name, values = ____keys[____i_3], ____values[____i_3]
        raw.sections:getOrPut(name, ____lambda_3):putAll(values)
    end
    print("sections: " .. __K2L_Str(raw.order))
    local r = Resolver.new(raw, __K2L_MapOf(__K2L_Pair.new("HOME", "/root")))
    local ____list_3 = __K2L_ListOf("general", "database", "server")
    for ____i_5 = 1, ____list_3.size do
        local s = ____list_3[____i_5]
        print("[" .. s .. "]")
        local ____collection = r:resolved(s)
        local ____items_3, ____n_4 = ____collection:____entryArray()
        for ____i_4 = 1, ____n_4 do
            local ____entry = ____items_3[____i_4]
            do
                local k, v = ____entry.key, ____entry.value
                print("  " .. k .. " = " .. __K2L_StringReplace(v, "\n", "\\n"))
            end
        end
    end
    local server = ServerSettings.new(r:resolved("server"))
    print(__K2L_Str(server))
    print("timeout total = " .. server:getTimeouts():sum(0.0))
    local ____receiver_10 = __K2L_RunCatching(function() return r:get("paths", "a") end):exceptionOrNull()
    print(__K2L_Str(____receiver_10 and ____receiver_10.message))
    local ____receiver_11 = __K2L_RunCatching(function() return r:get("database", "nope") end):exceptionOrNull()
    print(__K2L_Str(____receiver_11 and ____receiver_11.message))
    local ____receiver_12 = __K2L_RunCatching(____lambda_4):exceptionOrNull()
    print(__K2L_Str(____receiver_12 and ____receiver_12.message))
    local ____receiver_13 = __K2L_RunCatching(____lambda_5):exceptionOrNull()
    print(__K2L_Str(____receiver_13 and ____receiver_13.message))
    local ____receiver_14 = __K2L_RunCatching(____lambda_6):exceptionOrNull()
    print(__K2L_Str(____receiver_14 and ____receiver_14.message))
    local broken = __K2L_ListOf("[bad header", "novalue", "k ey = 1", "s = \"bad \\q\"", "[ok]\n\n = 3", "r = ${}")
    for ____i_7 = 1, broken.size do
        local text = broken[____i_7]
        local msg
        local ____ok_1, ____result_4 = pcall(function()
            local cfg = parseIni(text)
            local res = Resolver.new(cfg, __K2L_MapOf())
            msg = __K2L_Str(cfg.sections:flatMap(function(____destructured_1)
                local s, m = ____destructured_1.key, ____destructured_1.value
                local ____list_4 = m:getKeys()
                local ____out_2 = {}
                local ____count_2 = 0
                local ____items_4, ____n_5 = ____list_4:____array()
                for ____i_6 = 1, ____n_5 do
                    local it = ____items_4[____i_6]
                    ____count_2 = ____count_2 + 1
                    ____out_2[____count_2] = res:get(s, it)
                end
                return __K2L_ListWrap(____out_2, ____count_2)
            end))
        end)
        if not ____ok_1 then
            local ____error_1 = __K2L_ToThrowable(____result_4)
            if getmetatable(____error_1) == ConfigError then
                local e = ____error_1
                msg = "ConfigError(" .. __K2L_Str(e.message) .. ")"
            else
                error(____error_1, 0)
            end
        end
        print(__K2L_StringReplace(text, "\n", "|") .. " => " .. msg)
    end
end

__K2L_RunMain(main)
return {ConfigError = ConfigError, RawConfig = RawConfig, parseIni = parseIni, unquote = unquote, Resolver = Resolver, ServerSettings = ServerSettings, base = base, overlay = overlay}
