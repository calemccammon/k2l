local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_ClassInfo = ____lualib.__K2L_ClassInfo
local __K2L_Hash = ____lualib.__K2L_Hash
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_KClassOfValue = ____lualib.__K2L_KClassOfValue
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_PropertyRef = ____lualib.__K2L_PropertyRef
local __K2L_ReadOnlyListOf = ____lualib.__K2L_ReadOnlyListOf
local __K2L_ReadOnlySetOf = ____lualib.__K2L_ReadOnlySetOf
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RuntimeException = ____lualib.__K2L_RuntimeException
local __K2L_SingletonMapOf = ____lualib.__K2L_SingletonMapOf
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable
local __K2L_Uninitialized = ____lualib.__K2L_Uninitialized
local __K2L_UninitializedPropertyAccessException = ____lualib.__K2L_UninitializedPropertyAccessException

local ____exports = {}
local UserId = __K2L_Class("UserId")
__K2L_ClassInfo(UserId, "UserId", "UserId", "class")

function UserId:____init(raw)
    self.raw = raw
    if not (self.raw >= 0) then
        error(__K2L_IllegalArgumentException.new("negative id " .. self.raw))
    end
end

function UserId:getNext()
    return UserId.new(self.raw + 1)
end

function UserId:describe()
    return "user#" .. self.raw
end

function UserId:toString()
    return "UserId(raw=" .. self.raw .. ")"
end

function UserId:hashCode()
    return self.raw
end

function UserId:equals(other)
    return getmetatable(other) == UserId and self.raw == other.raw
end

local Email = __K2L_Class("Email")
__K2L_ClassInfo(Email, "Email", "Email", "class")

function Email:____init(address)
    self.address = address
end

function Email.new(address)
    return setmetatable({address = address}, Email)
end

function Email:getDomain()
    return __K2L_Text.substringAfter(self.address, "@")
end

function Email:toString()
    return "Email(address=" .. self.address .. ")"
end

function Email:hashCode()
    return __K2L_Hash(self.address)
end

function Email:equals(other)
    return getmetatable(other) == Email and self.address == other.address
end

local Account = __K2L_Class("Account")
__K2L_ClassInfo(Account, "Account", "Account", "class")

function Account:____init(id, email)
    self.id = id
    self.email = email
end

function Account.new(id, email)
    return setmetatable({id = id, email = email}, Account)
end

function Account:toString()
    return "Account(id=" .. __K2L_Str(self.id) .. ", email=" .. __K2L_Str(self.email) .. ")"
end

function Account:hashCode()
    return (31 * __K2L_Hash(self.id) + __K2L_Hash(self.email) + 0x80000000 & 0xFFFFFFFF) - 0x80000000
end

function Account:equals(other)
    return getmetatable(other) == Account and self.id:equals(other.id) and self.email:equals(other.email)
end

local Session = __K2L_Class("Session")
__K2L_ClassInfo(Session, "Session", "Session", "class")

function Session:login(account)
    self.user = account
end

function Session:status()
    return self.user ~= nil and "logged in as " .. (self.user or __K2L_Uninitialized("user")).email.address or "anonymous"
end

local ____lambda_1 = function() return UserId.new(-1) end
local ____lambda_2 = function(it) return it.raw end
local ____lambda_3 = function()
    return #(____exports.config or __K2L_Uninitialized("config"))
end
local function main()
    local a = UserId.new(7)
    print(__K2L_Str(a))
    print(a:equals(UserId.new(7)))
    print(a:hashCode() == __K2L_Hash(7))
    print(__K2L_ReadOnlySetOf(UserId.new(1), UserId.new(1), UserId.new(2)).size)
    print(__K2L_Str(__K2L_SingletonMapOf(__K2L_Pair.new(UserId.new(3), "x")):get(UserId.new(3))))
    print(__K2L_Str(a:getNext()) .. " " .. a:describe() .. " " .. Email.new("a@b.org"):getDomain())
    print(Account.new(UserId.new(1), Email.new("x@y.z")):equals(Account.new(UserId.new(1), Email.new("x@y.z"))))
    print(__K2L_Str(Account.new(UserId.new(1), Email.new("x@y.z"))))
    local ____receiver = __K2L_RunCatching(____lambda_1):exceptionOrNull()
    print(__K2L_Str(____receiver and ____receiver.message))
    print(__K2L_Str(__K2L_ReadOnlyListOf(UserId.new(3), UserId.new(1)):sortedBy(____lambda_2, true)))
    local s = Session.new()
    print(s:status())
    local ____ok, ____result = pcall(function()
        print(__K2L_Str(s.user or __K2L_Uninitialized("user")))
    end)
    if not ____ok then
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_UninitializedPropertyAccessException) then
            local e = ____error
            print(__K2L_Str(__K2L_KClassOfValue(e).simpleName) .. ": " .. __K2L_Str(e.message))
        else
            error(____error, 0)
        end
    end
    s:login(Account.new(UserId.new(9), Email.new("me@k2l.dev")))
    print(s:status())
    local ____receiver_1 = __K2L_RunCatching(function()
        return (s.tags or __K2L_Uninitialized("tags")).size
    end):exceptionOrNull()
    print(__K2L_Str(____receiver_1 and ____receiver_1.message))
    s.tags = __K2L_ListOf("a");
    (s.tags or __K2L_Uninitialized("tags")):add("b")
    print(__K2L_Str(s.tags or __K2L_Uninitialized("tags")))
    local ____receiver_2 = __K2L_RunCatching(____lambda_3):exceptionOrNull()
    print(__K2L_Str(____receiver_2 and ____receiver_2.message))
    ____exports.config = "ready"
    print(____exports.config or __K2L_Uninitialized("config"))
    local ____local
    local e = __K2L_RunCatching(function()
        return #(____local or __K2L_Uninitialized("local"))
    end):exceptionOrNull()
    print(__K2L_InstanceOf(e, __K2L_UninitializedPropertyAccessException) and __K2L_InstanceOf(e, __K2L_RuntimeException))
    ____local = "set"
    print(____local or __K2L_Uninitialized("local"))
end

____exports.UserId = UserId
____exports.Email = Email
____exports.Account = Account
____exports.Session = Session
main()
return ____exports
