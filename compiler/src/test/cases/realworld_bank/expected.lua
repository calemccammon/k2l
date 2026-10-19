local ____lualib = require("lualib_bundle")
local __K2L_CastFail = ____lualib.__K2L_CastFail
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_CompanionInfo = ____lualib.__K2L_CompanionInfo
local __K2L_Compare = ____lualib.__K2L_Compare
local __K2L_CompareByDescending = ____lualib.__K2L_CompareByDescending
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_HashSetOf = ____lualib.__K2L_HashSetOf
local __K2L_IDiv = ____lualib.__K2L_IDiv
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_JavaClass = ____lualib.__K2L_JavaClass
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_Lazy = ____lualib.__K2L_Lazy
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_NoSuchElementException = ____lualib.__K2L_NoSuchElementException
local __K2L_NotNull = ____lualib.__K2L_NotNull
local __K2L_ObservableProperty = ____lualib.__K2L_ObservableProperty
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringPadEnd = ____lualib.__K2L_StringPadEnd
local __K2L_StringPadStart = ____lualib.__K2L_StringPadStart
local __K2L_StringSplit = ____lualib.__K2L_StringSplit
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ThenBy = ____lualib.__K2L_ThenBy
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Triple = ____lualib.__K2L_Triple
local __K2L_UnsupportedOperationException = ____lualib.__K2L_UnsupportedOperationException
local __K2L_VetoableProperty = ____lualib.__K2L_VetoableProperty

local Customer
local Money = __K2L_Class("bank.Money")
__K2L_ClassInfo(Money, "bank.Money", "bank.Money", "class")
__K2L_CompanionInfo(Money, "bank.Money.Companion", "bank.Money$Companion", "Companion")
Money.____comparable = true

function Money:____init(cents)
    self.cents = cents
end

function Money:plus(other)
    return Money.new(self.cents + other.cents)
end

function Money:minus(other)
    return Money.new(self.cents - other.cents)
end

function Money:times(factor)
    return Money.new(self.cents * factor)
end

function Money:unaryMinus()
    return Money.new(-self.cents)
end

function Money:compareTo(other)
    return __K2L_Compare(self.cents, other.cents)
end

function Money:getIsNegative()
    return self.cents < 0
end

function Money:toString()
    local sign = self.cents < 0 and "-" or ""
    local abs = math.abs(self.cents)
    return sign .. "$" .. __K2L_IDiv(abs, 100) .. "." .. __K2L_StringPadStart(tostring(math.fmod(abs, 100)), 2, "0")
end

function Money:hashCode()
    return __K2L_Hash(self.cents)
end

function Money:equals(other)
    return getmetatable(other) == Money and self.cents == other.cents
end

Money.____companion = true

function Money:of(amount)
    local ____value = __K2L_StringSplit(amount, ".")
    local ____result
    ____result = __K2L_Pair.new(____value:get(0), ____value:getOrElse(1, function(it) return "0" end))
    local ____destructured = ____result
    local whole, frac = ____destructured.first, ____destructured.second
    return Money.new(__K2L_StringToInt(whole, nil, true) * 100 + __K2L_StringToInt(__K2L_Text.take(__K2L_StringPadEnd(frac, 2, "0"), 2), nil, true))
end

function Money:____initCompanion()
    self.ZERO = Money.new(0)
end

Money:____initCompanion()

local function getDollars(self)
    return Money.new(self * 100)
end

local InsufficientFunds = __K2L_Class("bank.InsufficientFunds", __K2L_Exception)
__K2L_ClassInfo(InsufficientFunds, "bank.InsufficientFunds", "bank.InsufficientFunds", "class")

function InsufficientFunds:____init(account, requested, available)
    __K2L_Exception.____init(self, "account " .. account .. ": requested " .. __K2L_Str(requested) .. " but only " .. __K2L_Str(available) .. " available")
    self.account = account
    self.requested = requested
    self.available = available
end

local TransferFailed = __K2L_Class("bank.TransferFailed", __K2L_RuntimeException)
__K2L_ClassInfo(TransferFailed, "bank.TransferFailed", "bank.TransferFailed", "class")

function TransferFailed:____init(message, cause)
    __K2L_RuntimeException.____init(self, message, cause)
end

local Auditable = __K2L_Class("bank.Auditable")
__K2L_ClassInfo(Auditable, "bank.Auditable", "bank.Auditable", "interface")

function Auditable:audit(entry)
    self:getAuditLog():add("[" .. self:getAuditLog().size + 1 .. "] " .. entry)
end

local AuditTrail = __K2L_Class("bank.AuditTrail", nil, Auditable)
__K2L_ClassInfo(AuditTrail, "bank.AuditTrail", "bank.AuditTrail", "class")

function AuditTrail:____init()
    self.auditLog = __K2L_ListOf()
end

function AuditTrail:getAuditLog()
    return self.auditLog
end

local Kind = __K2L_Class("bank.Kind")
__K2L_ClassInfo(Kind, "bank.Kind", "bank.Kind", "class")

function Kind:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Kind:toString()
    return self.name
end

function Kind:compareTo(other)
    return self.ordinal - other.ordinal
end

Kind.CHECKING = Kind.new("CHECKING", 0)
Kind.SAVINGS = Kind.new("SAVINGS", 1)
Kind.CREDIT = Kind.new("CREDIT", 2)
Kind.____values = {Kind.CHECKING, Kind.SAVINGS, Kind.CREDIT}
local Account = __K2L_Class("bank.Account", nil, Auditable)
__K2L_ClassInfo(Account, "bank.Account", "bank.Account", "class")

function Account:____init(id, owner, trail)
    if trail == nil then
        trail = AuditTrail.new()
    end
    self.id = id
    self.owner = owner
    self.____delegate_Auditable = trail
    self.overdraftLimit = Money.ZERO
    self.____balance_delegate = __K2L_ObservableProperty(Money.ZERO, function(_, old, new)
        if not old:equals(new) then
            self:audit("balance " .. __K2L_Str(old) .. " -> " .. __K2L_Str(new))
        end
    end)
    self.____frozen_delegate = __K2L_VetoableProperty(false, function(_, old, new)
        return not old or new or self.owner.verified
    end)
end

Account.____balance_property = __K2L_PropertyRef.new("balance", "bank/Account.balance")

function Account:getBalance()
    return self.____balance_delegate:getValue(self, Account.____balance_property)
end

function Account:setBalance(value)
    self.____balance_delegate:setValue(self, Account.____balance_property, value)
end

Account.____frozen_property = __K2L_PropertyRef.new("frozen", "bank/Account.frozen")

function Account:getFrozen()
    return self.____frozen_delegate:getValue(self, Account.____frozen_property)
end

function Account:setFrozen(value)
    self.____frozen_delegate:setValue(self, Account.____frozen_property, value)
end

function Account:deposit(amount)
    if not (not amount:getIsNegative() and not amount:equals(Money.ZERO)) then
        error(__K2L_IllegalArgumentException.new("deposit must be positive, was " .. __K2L_Str(amount)))
    end
    if self:getFrozen() then
        error(__K2L_IllegalStateException.new("account " .. self.id .. " is frozen"))
    end
    self:setBalance(self:getBalance():plus(amount))
end

function Account:withdraw(amount)
    if self:getFrozen() then
        error(__K2L_IllegalStateException.new("account " .. self.id .. " is frozen"))
    end
    if __K2L_Compare(self:getBalance():minus(amount), self.overdraftLimit:unaryMinus()) < 0 then
        error(InsufficientFunds.new(self.id, amount, self:getBalance():plus(self.overdraftLimit)))
    end
    self:setBalance(self:getBalance():minus(amount))
end

function Account:monthEnd() end

function Account:toString()
    return self:getKind().name:lower() .. " " .. self.id .. " (" .. self.owner.name .. "): " .. __K2L_Str(self:getBalance())
end

function Account:equals(other)
    return __K2L_InstanceOf(other, Account) and other.id == self.id
end

function Account:hashCode()
    return __K2L_Hash(self.id)
end

function Account:getAuditLog(...)
    return self.____delegate_Auditable:getAuditLog(...)
end

function Account:audit(...)
    return self.____delegate_Auditable:audit(...)
end

local Checking = __K2L_Class("bank.Checking", Account)
__K2L_ClassInfo(Checking, "bank.Checking", "bank.Checking", "class")

function Checking:____init(id, owner)
    Account.____init(self, id, owner)
    self.kind = Kind.CHECKING
    self.overdraftLimit = getDollars(50)
    self.fees = Money.ZERO
end

function Checking:getKind()
    return self.kind
end

function Checking:withdraw(amount)
    Account.withdraw(self, amount)
    if self:getBalance():getIsNegative() then
        self.fees = self.fees:plus(getDollars(5))
        self:audit("overdraft fee")
    end
end

function Checking:monthEnd()
    if not self.fees:equals(Money.ZERO) then
        Account.withdraw(self, self.fees)
        self.fees = Money.ZERO
    end
end

local Savings = __K2L_Class("bank.Savings", Account)
__K2L_ClassInfo(Savings, "bank.Savings", "bank.Savings", "class")

function Savings:____init(id, owner, ratePercent)
    Account.____init(self, id, owner)
    self.ratePercent = ratePercent
    self.withdrawalsThisMonth = 0
end

function Savings:getKind()
    return Kind.SAVINGS
end

function Savings:withdraw(amount)
    if self.withdrawalsThisMonth >= 2 then
        error(__K2L_IllegalStateException.new("savings " .. self.id .. ": withdrawal limit reached"))
    end
    Account.withdraw(self, amount)
    self.withdrawalsThisMonth = self.withdrawalsThisMonth + 1
end

function Savings:monthEnd()
    local interest = Money.new(__K2L_IDiv(__K2L_IDiv(self:getBalance().cents * self.ratePercent, 100), 12))
    if __K2L_Compare(interest, Money.ZERO) > 0 then
        self:deposit(interest)
    end
    self.withdrawalsThisMonth = 0
end

Customer = __K2L_Class("bank.Customer")
__K2L_ClassInfo(Customer, "bank.Customer", "bank.Customer", "class")

function Customer:____init(name, email)
    self.name = name
    self.email = email
    self.verified = false
    self.____initials_delegate = __K2L_Lazy(function()
        print("  (computing initials of " .. self.name .. ")")
        return __K2L_StringSplit(self.name, " "):filter(function(it) return #it > 0 end):joinToString("", nil, nil, nil, nil, function(it) return __K2L_Text.first(it):upper() end)
    end)
end

function Customer:getEmail()
    return self.email
end

function Customer:setEmail(value)
    if not __K2L_StringContains(value, "@") then
        error(__K2L_IllegalArgumentException.new("invalid email '" .. value .. "'"))
    end
    self.email = __K2L_StringTrim(value):lower()
end

function Customer:getInitials()
    return self.____initials_delegate:getValue()
end

local Bank = __K2L_Class("bank.Bank")
__K2L_ClassInfo(Bank, "bank.Bank", "bank.Bank", "class")

function Bank:____init(name)
    self.name = name
    self.accounts = __K2L_MapOf()
    self.nextNumber = 1
    self.transfers = __K2L_ListOf()
end

function Bank:open(owner, kind, rate)
    if rate == nil then
        rate = 2
    end
    local ____arg = __K2L_Text.first(kind.name)
    local ____old = self.nextNumber
    self.nextNumber = self.nextNumber + 1
    local id = ____arg .. "-" .. __K2L_StringPadStart(tostring(____old), 3, "0")
    local account
    if kind == Kind.CHECKING then
        account = Checking.new(id, owner)
    elseif kind == Kind.SAVINGS then
        account = Savings.new(id, owner, rate)
    elseif kind == Kind.CREDIT then
        error(__K2L_UnsupportedOperationException.new("credit accounts are not offered"))
    end
    local ____object = self.accounts
    ____object:set(id, account)
    return account
end

function Bank:get(id)
    return self.accounts:get(id)
end

function Bank:transfer(from, to, amount)
    local ____value_1 = self:get(from)
    if ____value_1 == nil then
        error(__K2L_NoSuchElementException.new("unknown account " .. from))
    end
    local source = ____value_1
    local ____value_2 = self:get(to)
    if ____value_2 == nil then
        error(__K2L_NoSuchElementException.new("unknown account " .. to))
    end
    local target = ____value_2
    local ____ok, ____result_1 = pcall(function()
        source:withdraw(amount)
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result_1)
        if __K2L_InstanceOf(____error, InsufficientFunds) then
            local e = ____error
            error(TransferFailed.new("transfer " .. from .. " -> " .. to .. " failed", e))
        else
            error(____error, 0)
        end
    end
    target:deposit(amount)
    self.transfers:add(__K2L_Triple.new(from, to, amount))
end

function Bank:monthEnd()
    local ____collection = self.accounts:getValues()
    local ____items, ____n = ____collection:____array()
    local ____mod = ____collection.____modCount
    for ____i = 1, ____n do
        local it = ____items[____i];
        (function(self, ...) return self:monthEnd(...) end)(it)
        if ____collection.____modCount ~= ____mod and ____collection:____comodified(____i, ____n) then
            break
        end
    end
end

function Bank:totalHoldings()
    return self.accounts:getValues():fold(Money.ZERO, function(acc, a) return acc:plus(a:getBalance()) end)
end

function Bank:report()
    return self.accounts:getValues():sortedWith(__K2L_ThenBy(__K2L_CompareByDescending(function(it) return it:getBalance() end), function(it) return it.id end)):map(function(it) return it:toString() end)
end

function Bank:getByOwner()
    return self.accounts:getValues():groupBy(function(it) return it.owner.name end, function(it) return it.id end)
end

local function main()
    local bank = Bank.new("Lua Savings & Loan")
    local alice = Customer.new("Alice  van Dyke", "ALICE@example.com")
    local bob = Customer.new("bob", "bob@example.com")
    print("initials: " .. alice:getInitials() .. " " .. alice:getInitials())
    local ____ok_1, ____result_2 = pcall(function()
        bob:setEmail("not-an-email")
    end)
    if not ____ok_1 then
        local ____error_1 = __K2L_ToThrowable(____result_2)
        if __K2L_InstanceOf(____error_1, __K2L_IllegalArgumentException) then
            local e = ____error_1
            print("rejected: " .. __K2L_Str(e.message))
        else
            error(____error_1, 0)
        end
    end
    alice:setEmail("  Alice@Example.COM ")
    print("email: " .. alice:getEmail())
    local a1 = bank:open(alice, Kind.CHECKING)
    local a2 = bank:open(alice, Kind.SAVINGS, 12)
    local b1 = bank:open(bob, Kind.CHECKING)
    __K2L_RunCatching(function() return bank:open(bob, Kind.CREDIT) end):onFailure(function(it)
        print(__K2L_Str(__K2L_KClassOfValue(it).simpleName) .. ": " .. __K2L_Str(it.message))
    end)
    a1:deposit(Money:of("120.5"))
    a2:deposit(getDollars(1000))
    b1:deposit(Money:of("15.25"))
    bank:transfer(a2.id, b1.id, getDollars(200))
    b1:withdraw(getDollars(240))
    local ____ok_2, ____result_3 = pcall(function()
        bank:transfer(b1.id, a1.id, getDollars(100))
    end)
    if not ____ok_2 then
        local ____error_2 = __K2L_ToThrowable(____result_3)
        if __K2L_InstanceOf(____error_2, TransferFailed) then
            local e = ____error_2
            local ____cast = e.cause
            if not __K2L_InstanceOf(____cast, InsufficientFunds) then
                __K2L_CastFail(____cast, "bank.InsufficientFunds", "bank.InsufficientFunds")
            end
            local cause = ____cast
            print(__K2L_Str(e.message) .. ": " .. __K2L_Str(cause.message) .. " [requested " .. __K2L_Str(cause.requested) .. "]")
        else
            error(____error_2, 0)
        end
    end
    local ____list = __K2L_ReadOnlyListOf(function()
        a2:withdraw(getDollars(1))
    end, function()
        a2:withdraw(getDollars(1))
    end, function()
        a1:deposit(Money.ZERO)
    end, function()
        bank:transfer("X-1", a1.id, getDollars(1))
    end)
    local ____mod_1 = ____list.____modCount
    for ____i_1 = 1, ____list.size do
        local op = ____list[____i_1]
        do
            local ____ok_3, ____result_4 = pcall(function()
                op()
            end)
            if not ____ok_3 then
                local ____error_3 = __K2L_ToThrowable(____result_4)
                if __K2L_InstanceOf(____error_3, __K2L_Exception) then
                    local e = ____error_3
                    print("error " .. __K2L_Str(__K2L_JavaClass(__K2L_KClassOfValue(e)).simpleName or "") .. ": " .. __K2L_Str(e.message))
                else
                    error(____error_3, 0)
                end
            end
        end
        if ____list.____modCount ~= ____mod_1 and ____list:____comodified(____i_1) then
            break
        end
    end
    b1:setFrozen(true)
    b1:setFrozen(false)
    print("bob frozen after unfreeze attempt: " .. tostring(b1:getFrozen()))
    bob.verified = true
    b1:setFrozen(false)
    print("bob frozen after verification: " .. tostring(b1:getFrozen()))
    bank:monthEnd()
    local ____list_1 = bank:report()
    local ____mod_2 = ____list_1.____modCount
    for ____i_2 = 1, ____list_1.size do
        local it = ____list_1[____i_2];
        (function(____p1) return print(__K2L_Str(____p1)) end)(it)
        if ____list_1.____modCount ~= ____mod_2 and ____list_1:____comodified(____i_2) then
            break
        end
    end
    print("holdings: " .. __K2L_Str(bank:totalHoldings()))
    print("owners: " .. __K2L_Str(bank:getByOwner()))
    print("transfers: " .. __K2L_Str(bank.transfers:map(function(____destructured_1)
        local f, t, m = ____destructured_1.first, ____destructured_1.second, ____destructured_1.third
        return f .. ">" .. t .. ":" .. __K2L_Str(m)
    end)))
    print("b1 audit:")
    local ____list_2 = b1:getAuditLog()
    for ____i_3 = 1, ____list_2.size do
        local it = ____list_2[____i_3]
        print("  " .. it)
    end
    local ____arg_1 = a2:getAuditLog().size
    if not __K2L_InstanceOf(a2, Savings) then
        __K2L_CastFail(a2, "bank.Savings", "bank.Savings")
    end
    print("a2 audit size: " .. ____arg_1 .. ", savings withdrawals: " .. a2.withdrawalsThisMonth)
    local set = __K2L_HashSetOf(a1, __K2L_NotNull(bank:get(a1.id)), b1)
    print("distinct accounts: " .. set.size .. ", max money: " .. __K2L_Str(__K2L_ReadOnlyListOf(getDollars(3), Money:of("3.01"), getDollars(5):unaryMinus()):max()))
    print(Money:of("7.5"):times(3):equals(Money:of("22.50")))
end

main()
return {Money = Money, getDollars = getDollars, InsufficientFunds = InsufficientFunds, TransferFailed = TransferFailed, Auditable = Auditable, AuditTrail = AuditTrail, Kind = Kind, Account = Account, Checking = Checking, Savings = Savings, Customer = Customer, Bank = Bank}
