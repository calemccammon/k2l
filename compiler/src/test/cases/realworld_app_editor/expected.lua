-- ==== history/Commands.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayDeque = ____lualib.__K2L_ArrayDeque
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_IteratorOf = ____lualib.__K2L_IteratorOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringReplace = ____lualib.__K2L_StringReplace

local ____Document = require("text.Document")
local Command = __K2L_Class("editor.history.Command")

function Command:mergeWith(____next)
    return nil
end

local Insert = __K2L_Class("editor.history.Insert", nil, Command)

function Insert:____init(at, text)
    self.at = at
    self.text = text
end

function Insert.new(at, text)
    return setmetatable({at = at, text = text}, Insert)
end

function Insert:getLabel()
    return "insert '" .. __K2L_StringReplace(self.text, "\n", "\\n") .. "' at " .. __K2L_Str(self.at)
end

function Insert:apply(doc)
    return doc:insert(self.at, self.text)
end

function Insert:revert(doc)
    doc:delete(____Document.Selection.new(self.at, doc:endOf(self.at, self.text)))
    return self.at
end

function Insert:mergeWith(____next)
    if getmetatable(____next) == Insert and not __K2L_StringContains(self.text, "\n") and not __K2L_StringContains(____next.text, "\n") and ____next.at:equals(____Document.Pos.new(self.at.line, self.at.col + #self.text)) and ____next.text ~= " " then
        return Insert.new(self.at, self.text .. ____next.text)
    else
        return nil
    end
end

function Insert:toString()
    return "Insert(at=" .. __K2L_Str(self.at) .. ", text=" .. self.text .. ")"
end

function Insert:hashCode()
    return (31 * __K2L_Hash(self.at) + __K2L_Hash(self.text) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Insert:equals(other)
    return getmetatable(other) == Insert and self.at:equals(other.at) and self.text == other.text
end

local Delete = __K2L_Class("editor.history.Delete", nil, Command)

function Delete:____init(selection)
    self.selection = selection
    self.removed = nil
end

function Delete:getLabel()
    local ____arg = "delete " .. __K2L_Str(self.selection:getStart()) .. ".." .. __K2L_Str(self.selection:getEnd())
    local ____receiver = self.removed
    return ____arg .. (____receiver and " ('" .. ____receiver .. "')" or "")
end

function Delete:apply(doc)
    self.removed = doc:delete(self.selection)
    return self.selection:getStart()
end

function Delete:revert(doc)
    local ____arg_1 = self.selection:getStart()
    local ____value = self.removed
    if ____value == nil then
        error(__K2L_IllegalStateException.new("not applied: " .. self:getLabel()))
    end
    return doc:insert(____arg_1, ____value)
end

local Batch = __K2L_Class("editor.history.Batch", nil, Command)

function Batch:____init(label, parts)
    self.label = label
    self.parts = parts
end

function Batch.new(label, parts)
    return setmetatable({label = label, parts = parts}, Batch)
end

function Batch:getLabel()
    return self.label
end

function Batch:apply(doc)
    return self.parts:fold(____Document.Pos.new(0, 0), function(_, c) return c:apply(doc) end)
end

function Batch:revert(doc)
    return self.parts:asReversed():fold(____Document.Pos.new(0, 0), function(_, c) return c:revert(doc) end)
end

local Noop = __K2L_Class("editor.history.Noop", nil, Command)

function Noop:____init()
    self.label__Noop = "noop"
end

function Noop:getLabel()
    return self.label__Noop
end

function Noop:apply(doc)
    return ____Document.Pos.new(0, 0)
end

function Noop:revert(doc)
    return ____Document.Pos.new(0, 0)
end

Noop:____init()
local BoundedStack = __K2L_Class("editor.history.BoundedStack", __K2L_IterableBase)
BoundedStack.____readOnly = true

function BoundedStack:____init(limit)
    self.limit = limit
    self.items = __K2L_ArrayDeque.new()
end

function BoundedStack:getSize()
    return self.items.size
end

function BoundedStack:push(item)
    self.items:addLast(item)
    return self.items.size > self.limit and self.items:removeFirst() or nil
end

function BoundedStack:pop()
    return self.items:removeLastOrNull()
end

function BoundedStack:peek()
    return self.items:lastOrNull()
end

function BoundedStack:replaceTop(item)
    local ____object = self.items
    local ____key = self.items.size - 1
    ____object:set(____key, item)
end

function BoundedStack:clear()
    self.items:clear()
end

function BoundedStack:iterator()
    return __K2L_IteratorOf(self.items:asReversed())
end

local History = __K2L_Class("editor.history.History")

function History:____init(doc, limit)
    if limit == nil then
        limit = 50
    end
    self.doc = doc
    self.undo = BoundedStack.new(limit)
    self.redo = BoundedStack.new(limit)
    self.cursor = ____Document.Pos.new(0, 0)
    self.listeners = __K2L_ListOf()
end

function History:onChange(listener)
    self.listeners:add(listener)
end

function History:notify(event)
    local ____list = self.listeners
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        it(event)
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
end

function History:execute(command, merge)
    if merge == nil then
        merge = true
    end
    self.cursor = command:apply(self.doc)
    local top = self.undo:peek()
    local merged
    if merge and top ~= nil then
        merged = top:mergeWith(command)
    else
        merged = nil
    end
    if merged ~= nil then
        self.undo:replaceTop(merged)
    else
        local ____receiver_1 = self.undo:push(command)
        if ____receiver_1 ~= nil then
            self:notify("forgot " .. ____receiver_1:getLabel())
        end
    end
    self.redo:clear()
    self:notify("did " .. command:getLabel())
end

function History:undo__1()
    local ____value_1 = self.undo:pop()
    if ____value_1 == nil then
        return false
    end
    local c = ____value_1
    self.cursor = c:revert(self.doc)
    self.redo:push(c)
    self:notify("undid " .. c:getLabel())
    return true
end

function History:redo__1()
    local ____value_2 = self.redo:pop()
    if ____value_2 == nil then
        return false
    end
    local c = ____value_2
    self.cursor = c:apply(self.doc)
    self.undo:push(c)
    self:notify("redid " .. c:getLabel())
    return true
end

local ____lambda_1 = function(it) return it:getLabel() end
function History:getUndoLabels()
    return self.undo:map(____lambda_1)
end

local ____lambda_2 = function(it) return it:getLabel() end
function History:getRedoLabels()
    return self.redo:map(____lambda_2)
end

return {Command = Command, Insert = Insert, Delete = Delete, Batch = Batch, Noop = Noop, BoundedStack = BoundedStack, History = History}
-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_Equals = ____lualib.__K2L_Equals
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringReplace = ____lualib.__K2L_StringReplace
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local ____Commands = require("history.Commands")
local ____Document = require("text.Document")
local Macro = __K2L_Class("editor.Macro")

function Macro:____init(name)
    self.name = name
    self.steps = __K2L_ListOf()
end

function Macro:record(step)
    self.steps:add(step)
    return self
end

function Macro:play(history, times)
    if times == nil then
        times = 1
    end
    for it = 0, times - 1 do
        do
            local commands = self.steps:map(function(it) return it(history.cursor) end)
            history:execute(____Commands.Batch.new("macro " .. self.name, commands), false)
        end
    end
end

local function describe(c)
    local ____mt = getmetatable(c)
    if ____mt == ____Commands.Insert then
        return "Insert(" .. #c.text .. " chars)"
    elseif ____mt == ____Commands.Delete then
        return "Delete"
    elseif ____mt == ____Commands.Batch then
        return "Batch"
    elseif __K2L_Equals(c, ____Commands.Noop) then
        return "Noop"
    end
end

local function show(____this, title)
    print("-- " .. title .. " (rev " .. ____this.revision .. ", " .. ____this:getLineCount() .. " lines)")
    print(__K2L_Str(____this))
end

local ____lambda_1 = function(it)
    return ____Commands.Insert.new(____Document.Pos.new(it.line, 0), "* ")
end
local ____lambda_2 = function(p)
    return ____Commands.Insert.new(____Document.Pos.new(p.line, p.col + 2), ";")
end
local function main()
    local doc = ____Document.Editable.new("hello world\nsecond line")
    local events = __K2L_ListOf()
    local history = ____Commands.History.new(doc, 4)
    history:onChange(function(it)
        events:add(it)
    end)
    history:onChange(function(it)
        if __K2L_StringStartsWith(it, "forgot") then
            print("  ! " .. it)
        end
    end)
    show(doc, "start")
    history:execute(____Commands.Insert.new(____Document.Pos.new(0, 5), ","))
    history:execute(____Commands.Insert.new(____Document.Pos.new(0, 12), "!"))
    local ____chars = __K2L_StringToList("abc")
    for i = 0, ____chars.size - 1 do
        local ch = ____chars[i + 1]
        history:execute(____Commands.Insert.new(____Document.Pos.new(1, 11 + i), ch))
    end
    history:execute(____Commands.Insert.new(____Document.Pos.new(1, 14), " "))
    history:execute(____Commands.Insert.new(____Document.Pos.new(1, 15), "x"))
    show(doc, "typed")
    print("undo: " .. __K2L_Str(history:getUndoLabels()))
    history:execute(____Commands.Delete.new(____Document.Selection.new(____Document.Pos.new(0, 13), ____Document.Pos.new(1, 6))))
    show(doc, "joined")
    print("cursor " .. __K2L_Str(history.cursor) .. ", undo: " .. __K2L_Str(history:getUndoLabels()))
    while history:undo__1() do
        print("  undo -> " .. __K2L_StringReplace(doc:getText(), "\n", "|") .. " @" .. __K2L_Str(history.cursor))
    end
    print("redo: " .. __K2L_Str(history:getRedoLabels()))
    history:redo__1()
    history:redo__1()
    show(doc, "redone twice")
    history:execute(____Commands.Insert.new(____Document.Pos.new(2, 0), "\nthird\nfourth"))
    show(doc, "multi-line insert")
    local macro = Macro.new("bullet"):record(____lambda_1):record(____lambda_2)
    macro:play(history, 2)
    show(doc, "macro")
    history:undo__1()
    show(doc, "macro undone once")
    history:execute(____Commands.Noop)
    print("after noop redo: " .. __K2L_Str(history:getRedoLabels()) .. ", undo: " .. __K2L_Str(history:getUndoLabels()))
    print("events: " .. events.size)
    local ____list = events:takeLast(5)
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        print("  " .. it)
    end
    local sel = ____Document.Selection.new(____Document.Pos.new(3, 4), ____Document.Pos.new(1, 2))
    print("selection " .. __K2L_Str(sel:getStart()) .. ".." .. __K2L_Str(sel:getEnd()) .. " empty=" .. tostring(sel:getIsEmpty()) .. " " .. tostring(____Document.Selection.new(____Document.Pos.new(1, 1), ____Document.Pos.new(1, 1)):getIsEmpty()))
    print("extract: '" .. __K2L_StringReplace(doc:extract(doc:clamp(sel:getStart()), doc:clamp(sel:getEnd())), "\n", "|") .. "'")
    print("clamp: " .. __K2L_Str(doc:clamp(____Document.Pos.new(99, 99))) .. " " .. __K2L_Str(doc:clamp(____Document.Pos.new(-3, 2))))
    print(__K2L_Str(__K2L_ReadOnlyListOf(____Commands.Insert.new(____Document.Pos.new(0, 0), "x"), ____Commands.Delete.new(sel), ____Commands.Batch.new("b", __K2L_ReadOnlyListOf()), ____Commands.Noop):map(describe)))
    print(____Commands.Insert.new(____Document.Pos.new(1, 1), "ab"):equals(____Commands.Insert.new(____Document.Pos.new(1, 1), "ab")))
    local ____ok, ____result = pcall(function()
        ____Commands.Delete.new(sel):revert(doc)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_IllegalStateException) then
            local e = ____error
            print("error: " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    print(__K2L_Str(__K2L_ReadOnlyListOf(____Document.Pos.new(2, 1), ____Document.Pos.new(0, 9), ____Document.Pos.new(2, 0)):sorted()))
end

main()
return {Macro = Macro, describe = describe, show = show}
-- ==== text/Document.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringBuilder = ____lualib.__K2L_StringBuilder
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit

local Pos = __K2L_Class("editor.text.Pos")
Pos.____comparable = true

function Pos:____init(line, col)
    self.line = line
    self.col = col
end

function Pos.new(line, col)
    return setmetatable({line = line, col = col}, Pos)
end

local ____lambda_1 = function(it) return it.line end
local ____lambda_2 = function(it) return it.col end
function Pos:compareTo(other)
    return __K2L_CompareBy(____lambda_1, ____lambda_2)(self, other)
end

function Pos:toString()
    return self.line .. ":" .. self.col
end

function Pos:hashCode()
    return (31 * self.line + self.col + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Pos:equals(other)
    return getmetatable(other) == Pos and self.line == other.line and self.col == other.col
end

local Selection = __K2L_Class("editor.text.Selection")

function Selection:____init(anchor, head)
    self.anchor = anchor
    self.head = head
end

function Selection.new(anchor, head)
    return setmetatable({anchor = anchor, head = head}, Selection)
end

function Selection:getStart()
    return __K2L_Num.minOf(self.anchor, self.head)
end

function Selection:getEnd()
    return __K2L_Num.maxOf(self.anchor, self.head)
end

function Selection:getIsEmpty()
    return self.anchor:equals(self.head)
end

function Selection:toString()
    return "Selection(anchor=" .. __K2L_Str(self.anchor) .. ", head=" .. __K2L_Str(self.head) .. ")"
end

function Selection:hashCode()
    return (31 * __K2L_Hash(self.anchor) + __K2L_Hash(self.head) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Selection:equals(other)
    return getmetatable(other) == Selection and self.anchor:equals(other.anchor) and self.head:equals(other.head)
end

local Document = __K2L_Class("editor.text.Document")

local ____lambda_3 = function(it) return __K2L_StringBuilder.new(it) end
function Document:____init(text)
    if text == nil then
        text = ""
    end
    self.lines = __K2L_StringSplit(text, "\n"):map(____lambda_3):toMutableList()
    self.revision = 0
end

function Document:getLineCount()
    return self.lines.size
end

function Document:line(i)
    return self.lines:get(i):toString()
end

function Document:getText()
    return self.lines:joinToString("\n")
end

function Document:touch()
    self.revision = self.revision + 1
end

function Document:clamp(p)
    local line = __K2L_Num.coerceIn(p.line, 0, self.lines.size - 1)
    return Pos.new(line, __K2L_Num.coerceIn(p.col, 0, self.lines:get(line):getLength()))
end

local ____lambda_4 = function(i, l)
    return __K2L_StringPadStart(tostring(i + 1), 2) .. "| " .. __K2L_Str(l)
end
function Document:toString()
    return self.lines:mapIndexed(____lambda_4):joinToString("\n")
end

local Editable = __K2L_Class("editor.text.Editable", Document)

function Editable:____init(text)
    Document.____init(self, text)
end

function Editable:insert(at, s)
    local p = self:clamp(at)
    local parts = __K2L_StringSplit(s, "\n")
    local rest = self.lines:get(p.line):substring(p.col)
    self.lines:get(p.line):setLength(p.col)
    self.lines:get(p.line):append(parts:get(0))
    for i = 1, parts.size - 1 do
        self.lines:addAt(p.line + i, __K2L_StringBuilder.new(parts:get(i)))
    end
    local endLine = p.line + parts.size - 1
    local endCol = parts.size == 1 and p.col + #parts:get(0) or #parts:last()
    self.lines:get(endLine):append(__K2L_Str(rest))
    self:touch()
    return Pos.new(endLine, endCol)
end

function Editable:delete(sel)
    local ____destructured = __K2L_Pair.new(self:clamp(sel:getStart()), self:clamp(sel:getEnd()))
    local start, ____end = ____destructured.first, ____destructured.second
    local removed = self:extract(start, ____end)
    local tail = self.lines:get(____end.line):substring(____end.col)
    self.lines:get(start.line):setLength(start.col)
    self.lines:get(start.line):append(__K2L_Str(tail))
    for it = 0, ____end.line - start.line - 1 do
        self.lines:removeAt(start.line + 1)
    end
    self:touch()
    return removed
end

function Editable:extract(start, ____end)
    if start.line == ____end.line then
        return self.lines:get(start.line):substring(start.col, ____end.col)
    else
        local ____builder = __K2L_StringBuilder.new()
        ____builder:append(__K2L_Str(self.lines:get(start.line):substring(start.col)))
        for l = start.line + 1, ____end.line - 1 do
            ____builder:append("\n"):append(__K2L_Str(self.lines:get(l)))
        end
        ____builder:append("\n"):append(__K2L_Str(self.lines:get(____end.line):substring(0, ____end.col)))
        return ____builder:toString()
    end
end

function Editable:endOf(start, s)
    local parts = __K2L_StringSplit(s, "\n")
    return parts.size == 1 and Pos.new(start.line, start.col + #s) or Pos.new(start.line + parts.size - 1, #parts:last())
end

return {Pos = Pos, Selection = Selection, Document = Document, Editable = Editable}
