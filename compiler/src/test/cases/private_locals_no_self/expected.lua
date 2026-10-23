local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_NULL_ARGUMENT = ____lualib.__K2L_NULL_ARGUMENT
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_Str = ____lualib.__K2L_Str

Status = __K2L_Class("ui.Status")
local shown, labels

local function format(name)
    return "[" .. name .. "]"
end

function Status.____init()
    shown = 0
    labels = __K2L_ListOf()
end

function Status.Show(name)
    shown = shown + 1
    labels:add(format(name))
end

function Status.Summary()
    return shown .. ": " .. labels:joinToString()
end

Status.____init()
Window = __K2L_Class("ui.Window")
local prefix

local function mark(self, state)
    self.opened = state
end

local function describe(self, w)
    return w.title .. (w.opened and " (open)" or "")
end

function Window:____init(title)
    if rawget(self, "Open") == nil then
        self.Open = function(...) return getmetatable(self).Open(self, ...) end
    end
    if rawget(self, "IsOpen") == nil then
        self.IsOpen = function(...)
            return getmetatable(self).IsOpen(self, ...)
        end
    end
    if rawget(self, "Describe") == nil then
        self.Describe = function(...)
            return getmetatable(self).Describe(self, ...)
        end
    end
    self.title = title
    self.opened = false
end

function Window:Open()
    mark(self, true)
end

function Window:IsOpen()
    return self.opened
end

function Window:Describe()
    return describe(self, self)
end

function Window.Make(name)
    return Window.new(prefix .. name)
end

function Window.____initCompanion()
    prefix = "win:"
end

Window.____initCompanion()
Slot = __K2L_Class("ui.Slot")

function Slot.new(id, item, note)
    if item == nil then
        item = "empty"
    end
    if note == nil then
        note = "none"
    elseif note == __K2L_NULL_ARGUMENT then
        note = nil
    end
    return setmetatable({id = id, item = item, note = note}, Slot)
end

__K2L_DataClass(Slot, {"id", "item", "note"})

local function main()
    Status.Show("hp")
    Status.Show("mana")
    print(Status.Summary())
    local w = Window.Make("bag")
    w.Open()
    print(w.IsOpen())
    print(w.Describe())
    local open = function(...) return w.Open(...) end
    open()
    print(__K2L_Str(Slot.new(1)))
    print(__K2L_Str(Slot.new(2, nil, __K2L_NULL_ARGUMENT)))
    local ____source = Slot.new(3, "sword")
    print(Slot.new(____source.id, ____source.item, __K2L_NULL_ARGUMENT):equals(Slot.new(3, "sword", __K2L_NULL_ARGUMENT)))
end

__K2L_RunMain(main)
