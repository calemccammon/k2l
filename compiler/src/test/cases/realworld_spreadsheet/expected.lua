local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareBy = ____lualib.__K2L_CompareBy
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashMapOf = ____lualib.__K2L_HashMapOf
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_IntRange = ____lualib.__K2L_IntRange
local __K2L_IterableBase = ____lualib.__K2L_IterableBase
local __K2L_IteratorBuilder = ____lualib.__K2L_IteratorBuilder
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_LazyObject = ____lualib.__K2L_LazyObject
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Num = ____lualib.__K2L_Num
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Regex = ____lualib.__K2L_Regex
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SetOf = ____lualib.__K2L_SetOf
local __K2L_SortedMapOf = ____lualib.__K2L_SortedMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringFormat = ____lualib.__K2L_StringFormat
local __K2L_StringLastIndexOf = ____lualib.__K2L_StringLastIndexOf
local __K2L_StringToDoubleOrNull = ____lualib.__K2L_StringToDoubleOrNull
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToList = ____lualib.__K2L_StringToList
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized

local Area
local Col = __K2L_Class("sheet.Col")
__K2L_ClassInfo(Col, "sheet.Col", "sheet.Col", "class")
__K2L_CompanionInfo(Col, "sheet.Col.Companion", "sheet.Col$Companion", "Companion")

function Col:____init(index)
    self.index = index
end

function Col.new(index)
    return setmetatable({index = index}, Col)
end

function Col:getLetters()
    return Col:toLetters(self.index)
end

function Col:toString()
    return "Col(index=" .. self.index .. ")"
end

function Col:hashCode()
    return self.index
end

function Col:equals(other)
    return getmetatable(other) == Col and self.index == other.index
end

function Col:toLetters(i, acc)
    if acc == nil then
        acc = ""
    end
    return i < 0 and acc or self:toLetters((i >= 0 and i // 26 or 0 - -i // 26) - 1, string.char(("A"):byte() + (i >= 0 and i % 26 or 0 - -i % 26)) .. acc)
end

local ____lambda_1 = function(acc, c)
    return acc * 26 + (c:byte() - ("A"):byte() + 1)
end
function Col:parse(s)
    return Col.new(__K2L_StringToList(s):fold(0, ____lambda_1) - 1)
end

local Ref = __K2L_Class("sheet.Ref")
__K2L_ClassInfo(Ref, "sheet.Ref", "sheet.Ref", "class")
__K2L_CompanionInfo(Ref, "sheet.Ref.Companion", "sheet.Ref$Companion", "Companion")
Ref.____comparable = true

function Ref:____init(col, row)
    self.col = col
    self.row = row
end

function Ref.new(col, row)
    return setmetatable({col = col, row = row}, Ref)
end

function Ref:toString()
    return self.col:getLetters() .. self.row
end

local ____lambda_2 = function(it) return it.row end
local ____lambda_3 = function(it) return it.col.index end
function Ref:compareTo(other)
    return __K2L_CompareBy(____lambda_2, ____lambda_3)(self, other)
end

function Ref:rangeTo(other)
    return Area.new(self, other)
end

function Ref:hashCode()
    return (31 * __K2L_Hash(self.col) + self.row + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Ref:equals(other)
    return getmetatable(other) == Ref and self.col:equals(other.col) and self.row == other.row
end

Ref.____companion = true

function Ref:parse(s)
    local ____value = self.PATTERN:matchEntire(__K2L_StringTrim(s):upper())
    if ____value == nil then
        error(__K2L_IllegalArgumentException.new("bad reference '" .. s .. "'"))
    end
    local m = ____value
    local ____destructured = m.destructured
    local letters, digits = ____destructured[1], ____destructured[2]
    return Ref.new(Col:parse(letters), __K2L_StringToInt(digits))
end

function Ref:____initCompanion()
    self.PATTERN = __K2L_Regex.new("([A-Z]+)([0-9]+)")
end

__K2L_LazyObject(Ref, "____initCompanion")
Area = __K2L_Class("sheet.Area", __K2L_IterableBase)
__K2L_ClassInfo(Area, "sheet.Area", "sheet.Area", "class")
Area.____readOnly = true

function Area:____init(from, to)
    self.from = from
    self.to = to
end

function Area:iterator()
    return __K2L_IteratorBuilder(function(____this)
        for r = math.min(self.from.row, self.to.row), math.max(self.from.row, self.to.row) do
            for c = math.min(self.from.col.index, self.to.col.index), math.max(self.from.col.index, self.to.col.index) do
                ____this:yield(Ref.new(Col.new(c), r))
            end
        end
    end)
end

function Area:toString()
    return __K2L_Str(self.from) .. ":" .. __K2L_Str(self.to)
end

local function component1(self)
    return self.col:getLetters()
end

local function component2(____this_1)
    return ____this_1.row
end

local Formula = __K2L_Class("sheet.Formula")
__K2L_ClassInfo(Formula, "sheet.Formula", "sheet.Formula", "class")
Formula.Const = __K2L_Class("sheet.Formula$Const", Formula)
__K2L_ClassInfo(Formula.Const, "sheet.Formula.Const", "sheet.Formula$Const", "class")

function Formula.Const:____init(value)
    self.value = value
end

function Formula.Const.new(value)
    return setmetatable({value = value}, Formula.Const)
end

function Formula.Const:refs()
    return __K2L_ReadOnlySetOf()
end

function Formula.Const:toString()
    return __K2L_Str(self.value)
end

Formula.Cell = __K2L_Class("sheet.Formula$Cell", Formula)
__K2L_ClassInfo(Formula.Cell, "sheet.Formula.Cell", "sheet.Formula$Cell", "class")

function Formula.Cell:____init(ref)
    self.ref = ref
end

function Formula.Cell.new(ref)
    return setmetatable({ref = ref}, Formula.Cell)
end

function Formula.Cell:refs()
    return __K2L_ReadOnlySetOf(self.ref)
end

function Formula.Cell:toString()
    return self.ref:toString()
end

Formula.Op = __K2L_Class("sheet.Formula$Op", Formula)
__K2L_ClassInfo(Formula.Op, "sheet.Formula.Op", "sheet.Formula$Op", "class")

function Formula.Op:____init(op, left, right)
    self.op = op
    self.left = left
    self.right = right
end

function Formula.Op.new(op, left, right)
    return setmetatable({op = op, left = left, right = right}, Formula.Op)
end

function Formula.Op:refs()
    return self.left:refs():plusAll(self.right:refs())
end

function Formula.Op:toString()
    return "(" .. __K2L_Str(self.left) .. " " .. self.op .. " " .. __K2L_Str(self.right) .. ")"
end

Formula.Fn = __K2L_Class("sheet.Formula$Fn", Formula)
__K2L_ClassInfo(Formula.Fn, "sheet.Formula.Fn", "sheet.Formula$Fn", "class")

function Formula.Fn:____init(name, area)
    self.name = name
    self.area = area
end

function Formula.Fn.new(name, area)
    return setmetatable({name = name, area = area}, Formula.Fn)
end

function Formula.Fn:refs()
    return self.area:toSet()
end

function Formula.Fn:toString()
    return self.name .. "(" .. __K2L_Str(self.area) .. ")"
end

local CycleException = __K2L_Class("sheet.CycleException", __K2L_RuntimeException)
__K2L_ClassInfo(CycleException, "sheet.CycleException", "sheet.CycleException", "class")

function CycleException:____init(path)
    __K2L_RuntimeException.____init(self, "cycle: " .. path:joinToString(" -> "))
    self.path = path
end

local function plus(____this_2, other)
    return Formula.Op.new("+", ____this_2, other)
end

local function times(____this_3, other)
    return Formula.Op.new("*", ____this_3, other)
end

local function parseFormula(text)
    local t = __K2L_StringTrim(text)
    local ____receiver = __K2L_StringToDoubleOrNull(t)
    if ____receiver ~= nil then
        local ____result
        return Formula.Const.new(____receiver)
    end
    local ____receiver_1 = __K2L_Regex.new("(SUM|AVG|MAX)\\((\\w+):(\\w+)\\)"):matchEntire(t)
    if ____receiver_1 ~= nil then
        local ____result_1
        do
            local ____destructured_1 = ____receiver_1.destructured
            local name, a, b = ____destructured_1[1], ____destructured_1[2], ____destructured_1[3]
            return Formula.Fn.new(name, Ref:parse(a):rangeTo(Ref:parse(b)))
        end
    end
    local ____list = __K2L_ReadOnlyListOf("+", "-", "*", "/")
    for ____i = 1, ____list.size do
        local op = ____list[____i]
        local i = __K2L_StringLastIndexOf(t, op)
        if i > 0 then
            return Formula.Op.new(op, parseFormula(__K2L_Text.substring(t, 0, i)), parseFormula(__K2L_Text.substring(t, i + 1)))
        end
    end
    return Formula.Cell.new(Ref:parse(t))
end

local Sheet = __K2L_Class("sheet.Sheet")
__K2L_ClassInfo(Sheet, "sheet.Sheet", "sheet.Sheet", "class")

function Sheet:____init()
    self.formulas = __K2L_SortedMapOf()
    self.values = __K2L_HashMapOf()
    self.evaluations = 0
end

function Sheet:set(ref, formula)
    local ____object = self.formulas
    local ____key = Ref:parse(ref)
    ____object:set(____key, parseFormula(formula))
end

function Sheet:get(ref)
    return self.values:get(Ref:parse(ref)) or 0.0
end

function Sheet:get__1(area)
    return area:map(function(it) return self.values:get(it) or 0.0 end)
end

function Sheet:order()
    local done = __K2L_SetOf()
    local visiting = __K2L_ListOf()
    local function visit(r)
        if done:contains(r) then
            return
        end
        if visiting:contains(r) then
            error(CycleException.new(visiting:dropWhile(function(it) return not it:equals(r) end):plus(r)))
        end
        visiting:add(r)
        local ____receiver_2 = self.formulas:get(r)
        local ____receiver_3 = ____receiver_2 and ____receiver_2:refs()
        local ____receiver_4 = ____receiver_3 and ____receiver_3:sorted()
        if ____receiver_4 ~= nil then
            local ____mod = ____receiver_4.____modCount
            for ____i_1 = 1, ____receiver_4.size do
                local it = ____receiver_4[____i_1]
                visit(it)
                if ____receiver_4.____modCount ~= ____mod and ____receiver_4:____comodified(____i_1) then
                    break
                end
            end
        end
        visiting:removeAt(visiting.size - 1)
        done:add(r)
    end
    local ____collection = self.formulas:getKeys()
    local ____items, ____n = ____collection:____array()
    local ____mod_1 = ____collection.____modCount
    for ____i_2 = 1, ____n do
        local it = ____items[____i_2]
        visit(it)
        if ____collection.____modCount ~= ____mod_1 and ____collection:____comodified(____i_2, ____n) then
            break
        end
    end
    return done:filter(function(it) return self.formulas:containsKey(it) end)
end

function Sheet:recalc()
    self.lastOrder = self:order()
    self.values:clear()
    local ____list_1 = self.lastOrder or __K2L_Uninitialized("lastOrder")
    local ____mod_2 = ____list_1.____modCount
    for ____i_3 = 1, ____list_1.size do
        local ref = ____list_1[____i_3]
        local ____object_1 = self.values
        ____object_1:set(ref, self:eval(self.formulas:getValue(ref)))
        if ____list_1.____modCount ~= ____mod_2 and ____list_1:____comodified(____i_3) then
            break
        end
    end
end

function Sheet:eval(f)
    self.evaluations = self.evaluations + 1
    local ____mt = getmetatable(f)
    if ____mt == Formula.Const then
        return f.value
    elseif ____mt == Formula.Cell then
        return self.values:get(f.ref) or 0.0
    elseif ____mt == Formula.Op then
        local ____destructured_2 = __K2L_Pair.new(self:eval(f.left), self:eval(f.right))
        local l, r = ____destructured_2.first, ____destructured_2.second
        local ____subject_1 = f.op
        if ____subject_1 == "+" then
            return l + r
        elseif ____subject_1 == "-" then
            return l - r
        elseif ____subject_1 == "*" then
            return l * r
        elseif ____subject_1 == "/" then
            return r == 0.0 and 0.0 / 0.0 or l / r
        else
            error(__K2L_IllegalStateException.new("unknown operator " .. f.op))
        end
    elseif ____mt == Formula.Fn then
        local xs = self:get__1(f.area)
        local ____subject = f.name
        if ____subject == "SUM" then
            return xs:sum(0.0)
        elseif ____subject == "AVG" then
            return xs:average()
        elseif ____subject == "MAX" then
            return xs:maxOrNull() or 0.0
        else
            error(__K2L_IllegalStateException.new("unknown function " .. f.name))
        end
    end
end

local ____lambda_4 = function(it) return it.row end
function Sheet:render(area)
    local rows = area:groupBy(____lambda_4)
    return rows:getEntries():joinToString("\n", nil, nil, nil, nil, function(____destructured_3)
        local row, refs = ____destructured_3.key, ____destructured_3.value
        return __K2L_StringFormat("%3d | ", row) .. refs:joinToString(" ", nil, nil, nil, nil, function(it)
            return __K2L_StringFormat("%8.2f", self.values:get(it) or 0.0)
        end)
    end)
end

function Sheet:describe()
    return self.formulas:map(function(____destructured_4)
        local ref, f = ____destructured_4.key, ____destructured_4.value
        return __K2L_Str(ref) .. " = " .. __K2L_Str(f)
    end)
end

local ____lambda_5 = function(it) return Col.new(it):getLetters() end
local ____lambda_6 = function(it) return Col:toLetters(it) end
local ____lambda_7 = function(it) return Col:parse(it).index end
local ____lambda_8 = function() return Ref:parse("1A") end
local ____lambda_9 = function(____p1) return print(__K2L_Str(____p1)) end
local ____lambda_10 = function(it) return __K2L_Str(it) end
local function main()
    print(__K2L_Str(__K2L_IntRange.new(0, 3):map(____lambda_5):plusAll(__K2L_ReadOnlyListOf(25, 26, 27, 51, 52, 701, 702):map(____lambda_6))))
    print(__K2L_Str(__K2L_ReadOnlyListOf("A", "Z", "AA", "AZ", "ZZ", "AAA"):map(____lambda_7)))
    local ____destructured_5 = Ref:parse("bc12")
    local letters, row = ____destructured_5.col, ____destructured_5.row
    print(__K2L_Str(letters) .. " " .. row .. " " .. tostring(__K2L_Compare(Ref:parse("C3"), Ref:parse("A4")) < 0) .. " " .. __K2L_Str(Ref:parse("A1"):rangeTo(Ref:parse("B2")):toList()))
    local ____receiver_5 = __K2L_RunCatching(____lambda_8):exceptionOrNull()
    print(__K2L_Str(____receiver_5 and ____receiver_5.message))
    local s = Sheet.new()
    s:set("A1", "10")
    s:set("A2", "32.5")
    s:set("A3", "SUM(A1:A2)")
    s:set("B1", "A1*2")
    s:set("B2", "B1+A3")
    s:set("B3", "AVG(A1:B2)")
    s:set("C1", "MAX(A1:B3)")
    s:set("C2", "C1/A4")
    s:set("C3", "B3-A1-1")
    s:recalc()
    local ____list_2 = s:describe()
    local ____mod_3 = ____list_2.____modCount
    for ____i_4 = 1, ____list_2.size do
        local it = ____list_2[____i_4];
        (____lambda_9)(it)
        if ____list_2.____modCount ~= ____mod_3 and ____list_2:____comodified(____i_4) then
            break
        end
    end
    print("order: " .. __K2L_Str(s.lastOrder or __K2L_Uninitialized("lastOrder")))
    print(s:render(Ref:parse("A1"):rangeTo(Ref:parse("C3"))))
    print("C2 is NaN: " .. tostring(__K2L_Num.isNaN(s:get("C2"))) .. ", evaluations=" .. s.evaluations)
    print(__K2L_Str(s:get__1(Ref:parse("A1"):rangeTo(Ref:parse("A3"))):map(____lambda_10)))
    local built = times(plus(Formula.Const.new(2.0), Formula.Cell.new(Ref:parse("A1"))), Formula.Const.new(3.0))
    print(__K2L_Str(built) .. " refs=" .. __K2L_Str(built:refs()))
    s:set("A1", "C3")
    local ____ok, ____result_2 = pcall(function()
        s:recalc()
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_2)
        if getmetatable(____error) == CycleException then
            local e = ____error
            print(__K2L_Str(e.message) .. " (length " .. e.path.size .. ")")
        else
            error(____error, 0)
        end
    end
    local fresh = Sheet.new()
    local ____receiver_6 = __K2L_RunCatching(function()
        return fresh.lastOrder or __K2L_Uninitialized("lastOrder")
    end):exceptionOrNull()
    local ____receiver_7 = ____receiver_6 and __K2L_JavaClass(__K2L_KClassOfValue(____receiver_6))
    print(__K2L_Str(____receiver_7 and (____receiver_7.simpleName or "")))
end

main()
return {Col = Col, Ref = Ref, Area = Area, component1 = component1, component2 = component2, Formula = Formula, CycleException = CycleException, plus = plus, times = times, parseFormula = parseFormula, Sheet = Sheet}
