-- ==== main.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_Str = ____lualib.__K2L_Str

local ____Employees = require("staff.Employees")
local ____Payroll = require("pay.Payroll")
local Contractor = __K2L_Class("corp.Contractor", nil, ____Employees.Payable)
__K2L_ClassInfo(Contractor, "corp.Contractor", "corp.Contractor", "class")

function Contractor:____init(company, monthly)
    self.company = company
    self.monthly = monthly
end

function Contractor:getMonthly()
    return self.monthly
end

function Contractor:getCurrency()
    return "GBP"
end

function Contractor:toString()
    return "Contractor(" .. self.company .. ")"
end

local function printTrace(title)
    print(title .. ":")
    local ____list = ____Employees.trace
    for ____i = 1, ____list.size do
        local it = ____list[____i]
        print("  " .. it)
    end
    ____Employees.trace:clear()
end

local function main()
    local ada = ____Employees.Lead.new("Ada", 120000)
    printTrace("lead")
    local bo = ____Employees.Engineer.new("Bo", 72000, 2)
    local cy = ____Employees.Engineer.new("Cy", 60000)
    printTrace("engineers")
    local dee = ____Employees.intern(____Employees.Employee, "Dee", bo)
    printTrace("intern")
    local eng = ____Employees.Manager.new("Eve", 96000, __K2L_ReadOnlyListOf(ada, bo, cy))
    eng:plusAssign(dee)
    local ceo = ____Employees.Manager.new("Fay", 180000)
    ceo:plusAssign(eng)
    ceo:plusAssign(____Employees.Intern.new("Gus"))
    printTrace("managers")
    local ____list_1 = ceo:report()
    local ____mod = ____list_1.____modCount
    for ____i_1 = 1, ____list_1.size do
        local it = ____list_1[____i_1];
        (function(____p1) return print(__K2L_Str(____p1)) end)(it)
        if ____list_1.____modCount ~= ____mod and ____list_1:____comodified(____i_1) then
            break
        end
    end
    print("headcount " .. ceo:getHeadcount() .. ", everyone: " .. __K2L_Str(ceo:everyone():map(function(it) return it.tag end):toList()))
    print(tostring(eng:contains(dee)) .. " " .. tostring(ceo:contains(dee)) .. " " .. tostring(eng:contains(ceo)) .. " " .. ada:payslip() .. " | " .. bo:payslip(3) .. " | " .. ceo:payslip(12))
    print("titles: " .. __K2L_Str(ceo:everyone():map(__K2L_PropertyRef.new("title", "corp/staff/Employee.title", function(receiver) return receiver:getTitle() end)):toList()))
    print("currencies: " .. __K2L_Str(__K2L_ReadOnlyListOf(ada, bo, Contractor.new("Acme", 9000)):map(function(it) return it:getCurrency() end)))
    local ledger = ____Payroll.Ledger.new()
    ledger:add(ada, ____Payroll.Raise.new(10), ____Payroll.Bonus.new(500, "launch"))
    ledger:add(bo, ____Payroll.Bonus.new(200, "on call"), ____Payroll.Deduction.new(150, "laptop"), ____Payroll.Bonus.new(100, "referral"))
    ledger:add(dee, ____Payroll.Raise.new(5, "good start"))
    local payroll = ____Payroll.Payroll.new(ledger)
    for _, it in ceo:everyone():filter(function(it) return ledger:get(it):isNotEmpty() end):iter() do
        print(payroll:explain(it))
    end
    print(__K2L_Str(payroll:run(ceo:everyone():asIterable())))
    local ____arg = payroll:getBonuses()
    local ____result
    ____result = ledger:get(bo):filter(function(x)
        return __K2L_InstanceOf(x, ____Payroll.Bonus)
    end):sumOf(function(it) return it.amount end)
    local ____arg_1 = ____result
    local ____result_1
    ____result_1 = ledger:get(bo):filter(function(x)
        return __K2L_InstanceOf(x, ____Payroll.Deduction)
    end):sumOf(function(it) return it.amount end)
    print("bonuses " .. ____arg .. ", bo's bonuses " .. ____arg_1 .. ", deductions " .. ____result_1)
    local other = ____Employees.Engineer.new("Ada", 1)
    print(tostring(ada:equals(other)) .. " " .. tostring(ada:equals(ada)) .. " " .. __K2L_ReadOnlySetOf(ada, bo, ada, cy).size .. " " .. tostring(ada:hashCode() == __K2L_Hash("ADA-100")))
    printTrace("other")
    local byTitle = ceo:everyone():groupBy(function(it) return __K2L_KClassOfValue(it).simpleName end):mapValues(function(____destructured)
        local v = ____destructured.value
        return v:map(function(it) return it.name end)
    end)
    print(__K2L_Str(byTitle))
    local ctor = ____Employees.Intern.new
    local bound = function(...) return ada:payslip(...) end
    print(ctor("Hal"):getTitle() .. " " .. bound(7) .. " " .. __K2L_Str(__K2L_ReadOnlyListOf(1, 2):map(function(...) return ada:payslip(...) end)))
    print(__K2L_IDiv(36000, 12))
end

main()
return {Contractor = Contractor, printTrace = printTrace}
-- ==== pay/Payroll.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_ArrayOf = ____lualib.__K2L_ArrayOf
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ToInt32 = ____lualib.__K2L_ToInt32

local Adjustment = __K2L_Class("corp.pay.Adjustment")
__K2L_ClassInfo(Adjustment, "corp.pay.Adjustment", "corp.pay.Adjustment", "interface")
local Bonus = __K2L_Class("corp.pay.Bonus", nil, Adjustment)
__K2L_ClassInfo(Bonus, "corp.pay.Bonus", "corp.pay.Bonus", "class")

function Bonus:____init(amount, reason)
    self.amount = amount
    self.reason = reason
end

function Bonus:toString()
    return "Bonus(amount=" .. self.amount .. ", reason=" .. self.reason .. ")"
end

function Bonus:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.amount) + __K2L_Hash(self.reason))
end

function Bonus:equals(other)
    return getmetatable(other) == Bonus and self.amount == other.amount and self.reason == other.reason
end

local Deduction = __K2L_Class("corp.pay.Deduction", nil, Adjustment)
__K2L_ClassInfo(Deduction, "corp.pay.Deduction", "corp.pay.Deduction", "class")

function Deduction:____init(amount, reason)
    self.amount = amount
    self.reason = reason
end

function Deduction:toString()
    return "Deduction(amount=" .. self.amount .. ", reason=" .. self.reason .. ")"
end

function Deduction:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.amount) + __K2L_Hash(self.reason))
end

function Deduction:equals(other)
    return getmetatable(other) == Deduction and self.amount == other.amount and self.reason == other.reason
end

local Raise = __K2L_Class("corp.pay.Raise", nil, Adjustment)
__K2L_ClassInfo(Raise, "corp.pay.Raise", "corp.pay.Raise", "class")

function Raise:____init(percent, reason)
    if reason == nil then
        reason = "annual review"
    end
    self.percent = percent
    self.reason = reason
end

function Raise:toString()
    return "Raise(percent=" .. self.percent .. ", reason=" .. self.reason .. ")"
end

function Raise:hashCode()
    return __K2L_ToInt32(31 * __K2L_Hash(self.percent) + __K2L_Hash(self.reason))
end

function Raise:equals(other)
    return getmetatable(other) == Raise and self.percent == other.percent and self.reason == other.reason
end

local Ledger = __K2L_Class("corp.pay.Ledger")
__K2L_ClassInfo(Ledger, "corp.pay.Ledger", "corp.pay.Ledger", "class")

function Ledger:____init()
    self.entries = __K2L_Map.new()
end

function Ledger:get(p)
    return self.entries:get(p) or __K2L_ReadOnlyListOf()
end

function Ledger:add(p, ...)
    local adjustments = __K2L_ArrayOf(...)
    self.entries:getOrPut(p, function() return __K2L_ListOf() end):addAll(adjustments)
end

function Ledger:payees()
    return self.entries:getKeys()
end

local Payroll = __K2L_Class("corp.pay.Payroll")
__K2L_ClassInfo(Payroll, "corp.pay.Payroll", "corp.pay.Payroll", "class")

function Payroll:____init(ledger)
    self.ledger = ledger
end

function Payroll:net(e)
    local pay = e:getMonthly()
    local ____list = self.ledger:get(e)
    local ____mod = ____list.____modCount
    for ____i = 1, ____list.size do
        local adj = ____list[____i]
        if __K2L_InstanceOf(adj, Raise) then
            pay = pay + __K2L_IDiv(pay * adj.percent, 100)
        elseif __K2L_InstanceOf(adj, Bonus) then
            pay = pay + adj.amount
        elseif __K2L_InstanceOf(adj, Deduction) then
            pay = pay - adj.amount
        end
        if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
            break
        end
    end
    return pay
end

function Payroll:run(people)
    return people:associate(function(it)
        return __K2L_Pair.new(it.name, self:net(it))
    end)
end

function Payroll:explain(e)
    local parts = self.ledger:get(e):map(function(it)
        if __K2L_InstanceOf(it, Bonus) then
            return "+" .. it.amount .. " (" .. it.reason .. ")"
        elseif __K2L_InstanceOf(it, Deduction) then
            return "-" .. it.amount .. " (" .. it.reason .. ")"
        elseif __K2L_InstanceOf(it, Raise) then
            return "+" .. it.percent .. "% (" .. it.reason .. ")"
        end
    end)
    return e.name .. ": " .. e:getMonthly() .. parts:joinToString("", nil, nil, nil, nil, function(it) return " " .. it end) .. " = " .. self:net(e)
end

function Payroll:getBonuses()
    return self.ledger:payees():sumOf(function(e)
        local ____result
        do
            local ____this = self.ledger
            ____result = ____this:get(e):filter(function(x) return __K2L_InstanceOf(x, Bonus) end):sumOf(function(it) return it.amount end)
        end
        return ____result
    end)
end

return {Adjustment = Adjustment, Bonus = Bonus, Deduction = Deduction, Raise = Raise, Ledger = Ledger, Payroll = Payroll}
-- ==== staff/Employees.lua ====
local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_DoubleToInt = ____lualib.__K2L_DoubleToInt
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_SequenceBuilder = ____lualib.__K2L_SequenceBuilder
local __K2L_SingletonListOf = ____lualib.__K2L_SingletonListOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text

local trace = __K2L_ListOf()
local Payable = __K2L_Class("corp.staff.Payable")
__K2L_ClassInfo(Payable, "corp.staff.Payable", "corp.staff.Payable", "interface")

function Payable:getCurrency()
    return "EUR"
end

function Payable:payslip(month)
    if month == nil then
        month = 1
    end
    return month .. ": " .. self:getMonthly() .. " " .. self:getCurrency()
end

local Reportable = __K2L_Class("corp.staff.Reportable")
__K2L_ClassInfo(Reportable, "corp.staff.Reportable", "corp.staff.Reportable", "interface")
local Employee = __K2L_Class("corp.staff.Employee", nil, Payable, Reportable)
__K2L_ClassInfo(Employee, "corp.staff.Employee", "corp.staff.Employee", "class")
__K2L_CompanionInfo(Employee, "corp.staff.Employee.Companion", "corp.staff.Employee$Companion", "Companion")

function Employee:____init(name, baseSalary)
    self.name = name
    self.baseSalary = baseSalary
    self.title = "employee"
    local ____old = Employee.nextBadge
    Employee.nextBadge = Employee.nextBadge + 1
    self.badge = ____old
    self.tag = __K2L_Text.take(self.name, 3):upper() .. "-" .. self.badge
    trace:add("Employee(" .. self.name .. ") title=" .. self:getTitle())
end

function Employee:____init1(name)
    Employee.____init(self, name, 36000)
    trace:add("Employee secondary(" .. name .. ")")
end

function Employee.new1(name)
    local self = setmetatable({}, Employee)
    self:____init1(name)
    return self
end

function Employee:getTitle()
    return self.title
end

function Employee:getMonthly()
    return __K2L_IDiv(self.baseSalary, 12)
end

function Employee:report(indent)
    if indent == nil then
        indent = ""
    end
    return __K2L_SingletonListOf(indent .. __K2L_Str(self))
end

function Employee:toString()
    return __K2L_Str(__K2L_KClassOfValue(self).simpleName) .. "(" .. self.name .. ", " .. self:getTitle() .. ", " .. self:getMonthly() .. ")"
end

function Employee:equals(other)
    return __K2L_InstanceOf(other, Employee) and other.tag == self.tag
end

function Employee:hashCode()
    return __K2L_Hash(self.tag)
end

function Employee:resetBadges()
    self.nextBadge = 100
end

function Employee:____initCompanion()
    self.DEFAULT_SALARY = 36000
    self.nextBadge = 100
end

Employee:____initCompanion()
local Engineer = __K2L_Class("corp.staff.Engineer", Employee)
__K2L_ClassInfo(Engineer, "corp.staff.Engineer", "corp.staff.Engineer", "class")

function Engineer:____init(name, salary, level)
    if level == nil then
        level = 1
    end
    Employee.____init(self, name, salary)
    self.level = level
    self.title__Engineer = "engineer L" .. self.level
    self.bonusRate = 0.1
    trace:add("Engineer(" .. name .. ") level=" .. self.level .. " bonus=" .. __K2L_Str(self:getBonusRate()))
end

function Engineer:getTitle()
    return self.title__Engineer or "null"
end

function Engineer:getBonusRate()
    return self.bonusRate
end

function Engineer:getMonthly()
    return Employee.getMonthly(self) + __K2L_DoubleToInt(Employee.getMonthly(self) * self:getBonusRate())
end

local Lead = __K2L_Class("corp.staff.Lead", Engineer)
__K2L_ClassInfo(Lead, "corp.staff.Lead", "corp.staff.Lead", "class")

function Lead:____init(name, salary)
    Engineer.____init(self, name, salary, 3)
    self.bonusRate__Lead = 0.25
    self.currency = "USD"
end

function Lead:getBonusRate()
    return self.bonusRate__Lead or 0.0
end

function Lead:getTitle()
    return "lead (" .. Engineer.getTitle(self) .. ")"
end

function Lead:getCurrency()
    return self.currency
end

function Lead:payslip(month)
    if month == nil then
        month = 1
    end
    return "lead " .. Payable.payslip(self, month)
end

local Intern = __K2L_Class("corp.staff.Intern", Employee)
__K2L_ClassInfo(Intern, "corp.staff.Intern", "corp.staff.Intern", "class")

function Intern:____init(name)
    Employee.____init1(self, name)
    self.title__Intern = "intern"
    self.mentor = nil
end

function Intern:getTitle()
    return self.title__Intern or "null"
end

function Intern:report(indent)
    if indent == nil then
        indent = ""
    end
    local ____arg = Employee.report(self, indent)
    local ____receiver = self.mentor
    return ____arg:plusAll(__K2L_ListOf(____receiver and indent .. "  mentored by " .. ____receiver.name):filterNotNull():toList())
end

local Manager = __K2L_Class("corp.staff.Manager", Employee)
__K2L_ClassInfo(Manager, "corp.staff.Manager", "corp.staff.Manager", "class")

function Manager:____init(name, salary, reports)
    if reports == nil then
        reports = __K2L_ReadOnlyListOf()
    end
    Employee.____init(self, name, salary)
    self.team = reports:toMutableList()
    self.title__Manager = "manager"
end

function Manager:getTitle()
    return self.title__Manager or "null"
end

function Manager:plusAssign(e)
    self.team:add(e)
end

function Manager:contains(e)
    return self.team:contains(e) or self.team:any(function(it)
        return __K2L_InstanceOf(it, Manager) and it:contains(e)
    end)
end

function Manager:report(indent)
    if indent == nil then
        indent = ""
    end
    return Employee.report(self, indent):plusAll(self.team:flatMap(function(it) return it:report(indent .. "  ") end))
end

function Manager:getHeadcount()
    return 1 + self.team:sumOf(function(it)
        return __K2L_InstanceOf(it, Manager) and it:getHeadcount() or 1
    end)
end

function Manager:everyone()
    return __K2L_SequenceBuilder(function(____this)
        ____this:yield(self)
        local ____list = self.team
        local ____mod = ____list.____modCount
        for ____i = 1, ____list.size do
            local e = ____list[____i]
            if __K2L_InstanceOf(e, Manager) then
                ____this:yieldAll(e:everyone())
            else
                ____this:yield(e)
            end
            if ____list.____modCount ~= ____mod and ____list:____comodified(____i) then
                break
            end
        end
    end)
end

local function intern(self, name, mentor)
    local ____value = Intern.new(name)
    ____value.mentor = mentor
    return ____value
end

return {trace = trace, Payable = Payable, Reportable = Reportable, Employee = Employee, Engineer = Engineer, Lead = Lead, Intern = Intern, Manager = Manager, intern = intern}
