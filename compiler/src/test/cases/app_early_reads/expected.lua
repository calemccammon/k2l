local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

local Early = __K2L_Class("Early")

function Early:____init()
    self.y = 0
    self.label = "null"
    self.ready = false
    self.scale = 0.0
    self.x = self:compute()
    self.y = 5
    self.name = self:describe()
    self.label = "L"
    self.flag = self:check()
    self.ready = true
    self.ratio = self:half()
    self.scale = 2.0
    self.items = self:peek()
    self.list = __K2L_ListOf(1)
end

function Early:compute()
    return self.y + 1
end

function Early:describe()
    return "label=" .. self.label
end

function Early:check()
    return not self.ready
end

function Early:half()
    return self.scale / 2
end

function Early:peek()
    return self.list
end

local Widget = __K2L_Class("Widget")

function Widget:____init(id)
    self.id = id
    self.log = __K2L_ListOf()
    self.log:add(self:render())
end

function Widget:render()
    return "widget " .. self.id
end

local Button = __K2L_Class("Button", Widget)

function Button:____init(id)
    self.caption = "null"
    self.clicks = 0
    Widget.____init(self, id)
    self.caption = "OK"
    self.clicks = 3
end

function Button:render()
    return "button " .. self.id .. " [" .. self.caption .. "] clicks=" .. self.clicks
end

local Settings = __K2L_Class("Settings")

function Settings:____init()
    self.retries = 0
    self.verbose = false
    self.summary = self:summarize()
    self.retries = 3
    self.verbose = true
end

function Settings:summarize()
    return "retries=" .. self.retries .. " verbose=" .. tostring(self.verbose)
end

__K2L_LazyObject(Settings, "____init")

local function main()
    local e = Early.new()
    print(e.x .. " " .. e.y .. " " .. e.name .. " " .. tostring(e.flag) .. " " .. e.ratio .. " " .. __K2L_Str(e.items) .. " " .. __K2L_Str(e.list))
    local b = Button.new(7)
    print(__K2L_Str(b.log) .. " " .. b:render())
    print(Settings.summary .. " " .. Settings.retries)
end

__K2L_RunMain(main)
return {Early = Early, Widget = Widget, Button = Button, Settings = Settings}
