local ____lualib = require("lualib_bundle")
local __K2L_Class = ____lualib.__K2L_Class
local __K2L_DataClass = ____lualib.__K2L_DataClass
local __K2L_Exception = ____lualib.__K2L_Exception
local __K2L_IllegalArgumentException = ____lualib.__K2L_IllegalArgumentException
local __K2L_IllegalStateException = ____lualib.__K2L_IllegalStateException
local __K2L_InstanceOf = ____lualib.__K2L_InstanceOf
local __K2L_List = ____lualib.__K2L_List
local __K2L_ListOf = ____lualib.__K2L_ListOf
local __K2L_ListWrap = ____lualib.__K2L_ListWrap
local __K2L_Map = ____lualib.__K2L_Map
local __K2L_MapOf = ____lualib.__K2L_MapOf
local __K2L_Pair = ____lualib.__K2L_Pair
local __K2L_RunCatching = ____lualib.__K2L_RunCatching
local __K2L_RunMain = ____lualib.__K2L_RunMain
local __K2L_SimpleName = ____lualib.__K2L_SimpleName
local __K2L_Str = ____lualib.__K2L_Str
local __K2L_StringContains = ____lualib.__K2L_StringContains
local __K2L_StringIsBlank = ____lualib.__K2L_StringIsBlank
local __K2L_StringStartsWith = ____lualib.__K2L_StringStartsWith
local __K2L_StringToDouble = ____lualib.__K2L_StringToDouble
local __K2L_StringToInt = ____lualib.__K2L_StringToInt
local __K2L_StringToIntOrNull = ____lualib.__K2L_StringToIntOrNull
local __K2L_StringTrim = ____lualib.__K2L_StringTrim
local __K2L_Text = ____lualib.__K2L_Text
local __K2L_ToThrowable = ____lualib.__K2L_ToThrowable

local Either = __K2L_Class("generics.result.Either")
Either.Left = __K2L_Class("generics.result.Either$Left", nil, Either)

function Either.Left.new(____error)
    return setmetatable({error = ____error}, Either.Left)
end

__K2L_DataClass(Either.Left, {"error"})
Either.Right = __K2L_Class("generics.result.Either$Right", nil, Either)

function Either.Right.new(value)
    return setmetatable({value = value}, Either.Right)
end

__K2L_DataClass(Either.Right, {"value"})

function Either:right(a)
    return Either.Right.new(a)
end

function Either:left(e)
    return Either.Left.new(e)
end

function Either:catching(block)
    local ____ok, ____result, ____returned = pcall(function()
        return true, Either.Right.new(block())
    end)
    if ____ok then
        if ____result then
            return ____returned
        end
    else
        local ____error = __K2L_ToThrowable(____result)
        if __K2L_InstanceOf(____error, __K2L_Exception) then
            local e = ____error
            return Either.Left.new(e)
        else
            error(____error, 0)
        end
    end
end

local function map(self, f)
    local ____mt = getmetatable(self)
    if ____mt == Either.Left then
        return self
    elseif ____mt == Either.Right then
        return Either.Right.new(f(self.value))
    end
end

local function flatMap(____this, f)
    local ____mt_1 = getmetatable(____this)
    if ____mt_1 == Either.Left then
        return ____this
    elseif ____mt_1 == Either.Right then
        return f(____this.value)
    end
end

local function mapLeft(____this_1, f)
    local ____mt_2 = getmetatable(____this_1)
    if ____mt_2 == Either.Left then
        return Either.Left.new(f(____this_1.error))
    elseif ____mt_2 == Either.Right then
        return ____this_1
    end
end

local function fold(____this_2, ifLeft, ifRight)
    local ____mt_3 = getmetatable(____this_2)
    if ____mt_3 == Either.Left then
        return ifLeft(____this_2.error)
    elseif ____mt_3 == Either.Right then
        return ifRight(____this_2.value)
    end
end

local ____lambda_1 = function(it) return it end
local function getOrElse(____this_3, default)
    return fold(____this_3, function(it) return default end, ____lambda_1)
end

local function sequence(____this_4)
    local out = __K2L_List.new()
    for ____i = 1, ____this_4.size do
        local e = ____this_4[____i]
        local ____mt_4 = getmetatable(e)
        if ____mt_4 == Either.Left then
            return e
        elseif ____mt_4 == Either.Right then
            out:add(e.value)
        end
    end
    return Either.Right.new(out)
end

local Validated = __K2L_Class("generics.result.Validated")
Validated.Valid = __K2L_Class("generics.result.Validated$Valid", Validated)

function Validated.Valid.new(value)
    return setmetatable({value = value}, Validated.Valid)
end

__K2L_DataClass(Validated.Valid, {"value"})
Validated.Invalid = __K2L_Class("generics.result.Validated$Invalid", Validated)

function Validated.Invalid.new(errors)
    return setmetatable({errors = errors}, Validated.Invalid)
end

__K2L_DataClass(Validated.Invalid, {"errors"})

function Validated:map(f)
    local ____mt_5 = getmetatable(self)
    if ____mt_5 == Validated.Valid then
        return Validated.Valid.new(f(self.value))
    elseif ____mt_5 == Validated.Invalid then
        return self
    end
end

function Validated:toEither()
    local ____mt_6 = getmetatable(self)
    if ____mt_6 == Validated.Valid then
        return Either.Right.new(self.value)
    elseif ____mt_6 == Validated.Invalid then
        return Either.Left.new(self.errors)
    end
end

local ____lambda_2 = function(x) return getmetatable(x) == Validated.Invalid end
local function zip(a, b, f)
    if getmetatable(a) == Validated.Valid and getmetatable(b) == Validated.Valid then
        return Validated.Valid.new(f(a.value, b.value))
    else
        local ____list = __K2L_ListOf(a, b):filter(____lambda_2)
        local ____out = {}
        local ____count = 0
        local ____items, ____n = ____list:____array()
        for ____i_1 = 1, ____n do
            local it = ____items[____i_1]
            local ____inner, ____m = it.errors:____array()
            for ____j = 1, ____m do
                ____count = ____count + 1
                ____out[____count] = ____inner[____j]
            end
        end
        return Validated.Invalid.new(__K2L_ListWrap(____out, ____count))
    end
end

local ____lambda_3 = function(x, y) return __K2L_Pair.new(x, y) end
local function zip__1(a, b, c, f)
    return zip(zip(a, b, ____lambda_3), c, function(____destructured, z)
        local x, y = ____destructured.first, ____destructured.second
        return f(x, y, z)
    end)
end

local function valid(____this_5)
    return Validated.Valid.new(____this_5)
end

local function invalid(____this_6)
    return Validated.Invalid.new(__K2L_ListOf(____this_6))
end

local Field = __K2L_Class("generics.result.Field")

function Field:____init(name, ordinal)
    self.name = name
    self.ordinal = ordinal
end

function Field:toString()
    return self.name
end

function Field:compareTo(other)
    return self.ordinal - other.ordinal
end

Field.NAME = Field.new("NAME", 0)
Field.AGE = Field.new("AGE", 1)
Field.EMAIL = Field.new("EMAIL", 2)
Field.____values = {Field.NAME, Field.AGE, Field.EMAIL}
local FieldError = __K2L_Class("generics.result.FieldError")

function FieldError.new(field, message)
    return setmetatable({field = field, message = message}, FieldError)
end

function FieldError:toString()
    return self.field.name:lower() .. ": " .. self.message
end

__K2L_DataClass(FieldError, {"field", "message"})
local User = __K2L_Class("generics.result.User")

function User.new(name, age, email)
    return setmetatable({name = name, age = age, email = email}, User)
end

__K2L_DataClass(User, {"name", "age", "email"})

local ____lambda_4 = function(it) return it:upper() end
local function validateName(raw)
    if raw == nil or __K2L_StringIsBlank(raw) then
        return invalid(FieldError.new(Field.NAME, "required"))
    elseif #raw > 12 then
        return invalid(FieldError.new(Field.NAME, "too long (" .. #raw .. ")"))
    else
        return valid(__K2L_Text.replaceFirstChar(__K2L_StringTrim(raw), ____lambda_4))
    end
end

local function validateAge(raw)
    local ____value = raw and __K2L_StringToIntOrNull(raw)
    if ____value == nil then
        return invalid(FieldError.new(Field.AGE, "not a number: " .. __K2L_Str(raw)))
    end
    local n = ____value
    return n >= 0 and n <= 150 and valid(n) or invalid(FieldError.new(Field.AGE, "out of range: " .. n))
end

local function validateEmail(raw)
    local ____receiver = raw and (__K2L_StringContains(raw, "@") and not __K2L_StringStartsWith(raw, "@") and raw or nil)
    local ____receiver_1 = ____receiver and ____receiver:lower()
    return ____receiver_1 and valid(____receiver_1) or invalid(FieldError.new(Field.EMAIL, "invalid: " .. __K2L_Str(raw)))
end

local function parseUser(form)
    return zip__1(validateName(form:get("name")), validateAge(form:get("age")), validateEmail(form:get("email")), User.new)
end

local function parsePercent(s)
    return __K2L_RunCatching(function()
        local n = __K2L_StringToDouble(__K2L_StringTrim(__K2L_Text.removeSuffix(s, "%")))
        if not (n >= 0.0 and n <= 100.0) then
            error(__K2L_IllegalArgumentException.new("percent out of range: " .. n))
        end
        return n / 100
    end)
end

local ____lambda_5 = function(it)
    return "err(" .. __K2L_Str(__K2L_SimpleName(it)) .. ": " .. __K2L_Str(it.message) .. ")"
end
local function describe(____this_7, f)
    return ____this_7:fold(function(it) return "ok(" .. __K2L_Str(f(it)) .. ")" end, ____lambda_5)
end

local function divide(a, b)
    return b == 0 and Either:left("division by zero") or Either:right(a // b)
end

local ____lambda_6 = function(it) return divide(it, 2) end
local ____lambda_7 = function(it) return it * 3 end
local ____lambda_8 = function(it) return "error " .. it end
local ____lambda_9 = function(it) return "value " .. it end
local ____lambda_10 = function(it) return divide(it, 2) end
local ____lambda_11 = function(it) return it + 1 end
local ____lambda_12 = function(it) return it:upper() end
local ____lambda_13 = function() return __K2L_StringToInt("12x") end
local ____lambda_14 = function(it) return __K2L_SimpleName(it) end
local ____lambda_15 = function() return __K2L_StringToInt("12") end
local ____lambda_16 = function(it) return it * 2 end
local ____lambda_17 = function(x) return getmetatable(x) == Either.Right end
local ____lambda_18 = function(x) return getmetatable(x) == Either.Left end
local ____lambda_19 = function(it) return it.error end
local ____lambda_20 = function(it) return it.email end
local ____lambda_21 = function(it) return string.format("%.3f", it) end
local ____lambda_22 = function(it) return 0.0 end
local ____lambda_23 = function(it) return it + 1 end
local function main()
    print("== either")
    local chain = map(flatMap(divide(100, 5), ____lambda_6), ____lambda_7)
    print("chain=" .. __K2L_Str(chain) .. " fold=" .. fold(chain, ____lambda_8, ____lambda_9))
    local broken = mapLeft(map(flatMap(divide(1, 0), ____lambda_10), ____lambda_11), ____lambda_12)
    print("broken=" .. __K2L_Str(broken) .. " orElse=" .. getOrElse(broken, -1))
    local all = sequence(__K2L_ListOf(divide(10, 2), divide(9, 3), divide(8, 4)))
    local some = sequence(__K2L_ListOf(divide(10, 2), divide(9, 0), divide(8, 0)))
    print("all=" .. __K2L_Str(all) .. " some=" .. __K2L_Str(some))
    local caught = mapLeft(Either:catching(____lambda_13), ____lambda_14)
    local fine = map(Either:catching(____lambda_15), ____lambda_16)
    print("caught=" .. __K2L_Str(caught) .. " fine=" .. __K2L_Str(fine))
    local values = __K2L_ListOf(Either:right(1), Either:left("x"), Either:right("two"), Either:right(3.5))
    local ____list_1 = values:filter(____lambda_17)
    local ____out_1 = {}
    local ____count_1 = 0
    local ____items_1, ____n_1 = ____list_1:____array()
    for ____i_2 = 1, ____n_1 do
        local it = ____items_1[____i_2]
        ____count_1 = ____count_1 + 1
        ____out_1[____count_1] = it.value
    end
    print("rights=" .. __K2L_Str(__K2L_ListWrap(____out_1, ____count_1)))
    print("lefts=" .. values:filter(____lambda_18):joinToString(nil, nil, nil, nil, nil, ____lambda_19))
    print("== validated")
    local forms = __K2L_ListOf(__K2L_MapOf(__K2L_Pair.new("name", "ada"), __K2L_Pair.new("age", "36"), __K2L_Pair.new("email", "Ada@Example.org")), __K2L_MapOf(__K2L_Pair.new("name", ""), __K2L_Pair.new("age", "abc"), __K2L_Pair.new("email", "nope")), __K2L_MapOf(__K2L_Pair.new("name", "bartholomew-the-great"), __K2L_Pair.new("age", "200"), __K2L_Pair.new("email", "b@x.io")), __K2L_MapOf(__K2L_Pair.new("age", "41"), __K2L_Pair.new("email", "@x")))
    for ____i_3 = 1, forms.size do
        local form = forms[____i_3]
        local result = parseUser(form)
        local ____mt_7 = getmetatable(result)
        if ____mt_7 == Validated.Valid then
            print("valid " .. __K2L_Str(result.value))
        elseif ____mt_7 == Validated.Invalid then
            print("invalid " .. __K2L_Str(result.errors))
        end
    end
    local ____list_2 = forms:map(parseUser)
    local ____out_2 = {}
    local ____count_2 = 0
    local ____items_2, ____n_2 = ____list_2:____array()
    for ____i_4 = 1, ____n_2 do
        local v = ____items_2[____i_4]
        local ____result_1
        ____result_1 = v:map(____lambda_20)
        ____count_2 = ____count_2 + 1
        ____out_2[____count_2] = ____result_1
    end
    local ____list_3 = __K2L_ListWrap(____out_2, ____count_2)
    local ____out_3 = {}
    local ____count_3 = 0
    local ____items_3, ____n_3 = ____list_3:____array()
    for ____i_5 = 1, ____n_3 do
        local it = ____items_3[____i_5]
        local ____result_2
        do
            local ____receiver_2 = getmetatable(it) == Validated.Valid and it or nil
            ____result_2 = ____receiver_2 and (getmetatable(it) == Validated.Valid and it or nil).value
        end
        local ____value_1 = ____result_2
        if ____value_1 ~= nil then
            ____count_3 = ____count_3 + 1
            ____out_3[____count_3] = ____value_1
        end
    end
    local emails = __K2L_ListWrap(____out_3, ____count_3)
    print("emails=" .. __K2L_Str(emails))
    local asEither = mapLeft(parseUser(forms:get(1)):toEither(), function(errs)
        local ____result_3 = __K2L_Map.new()
        local ____items_4, ____n_4 = errs:____array()
        for ____i_6 = 1, ____n_4 do
            local it = ____items_4[____i_6]
            local ____value_2 = it.field
            local ____group = ____result_3:get(____value_2)
            if ____group == nil then
                ____group = __K2L_List.new()
                ____result_3:put(____value_2, ____group)
            end
            ____group:add(it.message)
        end
        return ____result_3
    end)
    print("either=" .. __K2L_Str(asEither))
    print("== result")
    local ____list_4 = __K2L_ListOf("50%", " 12.5 ", "150", "abc")
    for ____i_7 = 1, ____list_4.size do
        local s = ____list_4[____i_7]
        print(s .. " -> " .. describe(parsePercent(s), ____lambda_21))
    end
    local ____list_5 = __K2L_ListOf("10%", "20%", "x", "30%"):map(parsePercent)
    local ____out_4 = {}
    local ____count_4 = 0
    local ____items_5, ____n_5 = ____list_5:____array()
    for ____i_8 = 1, ____n_5 do
        local it = ____items_5[____i_8]
        local ____value_3 = it:getOrNull()
        if ____value_3 ~= nil then
            ____count_4 = ____count_4 + 1
            ____out_4[____count_4] = ____value_3
        end
    end
    local total = __K2L_ListWrap(____out_4, ____count_4):sum(0.0)
    print("total=" .. total)
    local recovered = parsePercent("oops"):recover(____lambda_22):map(____lambda_23)
    local mapped = parsePercent("40"):mapCatching(function(it)
        if not (it < 0.3) then
            error(__K2L_IllegalStateException.new("too high: " .. it))
        end
        return it
    end)
    local ____arg = recovered:getOrThrow()
    local ____receiver_3 = mapped:exceptionOrNull()
    print("recovered=" .. ____arg .. " mapped=" .. __K2L_Str(____receiver_3 and ____receiver_3.message) .. " isFailure=" .. tostring(mapped:isFailure()))
    local ____list_6 = __K2L_ListOf("1", "2", "z", "w"):map(parsePercent)
    local ____result_4
    local ____items_6, ____n_6 = ____list_6:____array()
    for ____i_9 = 1, ____n_6 do
        local it = ____items_6[____i_9]
        if it:isFailure() then
            ____result_4 = it
            break
        end
    end
    local firstFailure = ____result_4
    local ____receiver_4 = firstFailure and firstFailure:exceptionOrNull()
    print("first failure: " .. __K2L_Str(____receiver_4 and __K2L_SimpleName(____receiver_4)))
end

__K2L_RunMain(main)
return {Either = Either, map = map, flatMap = flatMap, mapLeft = mapLeft, fold = fold, getOrElse = getOrElse, sequence = sequence, Validated = Validated, zip = zip, zip__1 = zip__1, valid = valid, invalid = invalid, Field = Field, FieldError = FieldError, User = User, validateName = validateName, validateAge = validateAge, validateEmail = validateEmail, parseUser = parseUser, parsePercent = parsePercent, describe = describe, divide = divide}
