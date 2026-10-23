local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Cmd = __K2L_Class("app.cmds.Cmd")
Cmd.Look = __K2L_Class("app.cmds.Cmd$Look", nil, Cmd)

function Cmd.Look:toString()
    return "Look"
end

function Cmd.Look:hashCode()
    return -1757645349
end

Cmd.Quit = __K2L_Class("app.cmds.Cmd$Quit", nil, Cmd)

function Cmd.Quit:toString()
    return "Quit"
end

function Cmd.Quit:hashCode()
    return -1757490805
end

Cmd.Say = __K2L_Class("app.cmds.Cmd$Say", nil, Cmd)

function Cmd.Say.new(text)
    return setmetatable({text = text}, Cmd.Say)
end

__K2L_DataClass(Cmd.Say, {"text"})
local Settings = __K2L_Class("app.cmds.Settings")

function Settings:____init()
    self.verbose = false
end

function Settings:toString()
    return "Settings"
end

function Settings:hashCode()
    return -1923970293
end

Settings:____init()
local Custom = __K2L_Class("app.cmds.Custom")

function Custom:toString()
    return "custom!"
end

function Custom:hashCode()
    return -1084427175
end

local function describe(c)
    if __K2L_Equals(c, Cmd.Look) then
        return "look"
    elseif __K2L_Equals(c, Cmd.Quit) then
        return "quit"
    elseif getmetatable(c) == Cmd.Say then
        return "say " .. c.text
    end
end

local function main()
    local cmds = __K2L_ListOf(Cmd.Look, Cmd.Say.new("hi"), Cmd.Quit, Cmd.Look)
    print(__K2L_Str(cmds))
    print(__K2L_Str(cmds:map(describe)))
    print(__K2L_Str(Settings) .. " " .. tostring(Settings.verbose) .. " " .. __K2L_Str(Custom))
    print(Cmd.Look:hashCode() == __K2L_Hash("app.cmds.Cmd.Look"))
    print(Cmd.Quit:hashCode())
    print(cmds:toSet().size)
    print(__K2L_Str(__K2L_MapOf(__K2L_Pair.new(Cmd.Look, 1), __K2L_Pair.new(Cmd.Quit, 2)):get(Cmd.Quit)))
    print(Cmd.Look == Cmd.Look and Cmd.Look ~= Cmd.Quit)
    print(#Cmd.Look:toString())
end

__K2L_RunMain(main)
return {Cmd = Cmd, Settings = Settings, Custom = Custom, describe = describe}
