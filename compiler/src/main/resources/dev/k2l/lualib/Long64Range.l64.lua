-- requires: Collections, Long64, Long64Ext
-- LongRange, LongProgression and ULongRange objects with --long64 emulate: IntRange with the bounds and the step compared and
-- added with the emulated operators, so they may be boxes (Long.MAX_VALUE - 2..Long.MAX_VALUE). A loop over a range literal
-- does not create one; see Long64Ext.range.
local __K2L_LongRange = __K2L_Class("kotlin.ranges.LongRange", __K2L_IntRange)

do

local L = __K2L_Long64
local X = __K2L_Long64X

local function compare(self)
    return self.unsigned and L.ucmp or L.cmp
end

local function numeric(self)
    return type(self.first) == "number" and type(self.last) == "number" and type(self.step) == "number"
end

function __K2L_LongRange:____init(first, last, step, unsigned)
    self.first, self.last, self.step, self.unsigned = first, last, step or 1, unsigned or false
end

-- `first until bound`: the range up to bound - 1, which is empty when bound is the smallest value
function __K2L_LongRange.untilOf(first, bound, unsigned)
    if bound == (unsigned and 0 or L.MIN) then
        return __K2L_LongRange.new(1, 0, 1, unsigned)
    end
    return __K2L_LongRange.new(first, L.sub(bound, 1), 1, unsigned)
end

function __K2L_LongRange:____array()
    if numeric(self) then
        return __K2L_IntRange.____array(self)
    end
    local first, count, step = X.rangeOf(self)
    local out, current = {}, first
    for k = 1, count do
        out[k] = current
        current = L.add(current, step)
    end
    return out, count
end

function __K2L_LongRange:isEmpty()
    local order = compare(self)(self.first, self.last)
    if L.lt(0, self.step) then
        return order > 0
    end
    return order < 0
end

function __K2L_LongRange:contains(value)
    local c = compare(self)
    local step, first = self.step, self.first
    if L.lt(0, step) then
        return c(value, first) >= 0 and c(value, self.last) <= 0 and L.urem(L.sub(value, first), step) == 0
    end
    return c(value, first) <= 0 and c(value, self.last) >= 0 and L.urem(L.sub(first, value), L.neg(step)) == 0
end

-- A progression's last element is the last one it reaches: (1L..10L step 3L).last is 10, (1L..10L step 2L).last is 9.
function __K2L_LongRange:withStep(step)
    if L.lt(step, 1) then
        error(__K2L_IllegalArgumentException.new("Step must be positive, was: " .. L.str(step) .. "."))
    end
    local descending = L.lt(self.step, 0)
    local last = self.last
    if not self:isEmpty() then
        local remainder = L.urem(descending and L.sub(self.first, last) or L.sub(last, self.first), step)
        last = descending and L.add(last, remainder) or L.sub(last, remainder)
    end
    return __K2L_LongRange.new(self.first, last, descending and L.neg(step) or step, self.unsigned)
end

function __K2L_LongRange:reversed()
    return __K2L_LongRange.new(self.last, self.first, L.neg(self.step), self.unsigned)
end

function __K2L_LongRange:toString()
    local text = self.unsigned and L.ustr or L.str
    local step = self.step
    if step == 1 then
        return text(self.first) .. ".." .. text(self.last)
    elseif L.lt(0, step) then
        return text(self.first) .. ".." .. text(self.last) .. " step " .. L.str(step)
    end
    return text(self.first) .. " downTo " .. text(self.last) .. " step " .. L.str(L.neg(step))
end

function __K2L_LongRange:equals(other)
    return getmetatable(other) == __K2L_LongRange and (self:isEmpty() and other:isEmpty() or
        self.first == other.first and self.last == other.last and self.step == other.step)
end

end
