-- requires: Class, Collections, Compare, Pair, Strings, Exceptions
-- More of kotlin.collections and kotlin.text: isSorted and friends, Grouping's *To operations, Map.onEachIndexed/mapTo/
-- filterNotTo, Iterator.withIndex, and CharSequence's findAnyOf/findLastAnyOf/lastIndexOfAny/replaceIndent.
local __K2L_CollectionExtras = {}
local X = __K2L_CollectionExtras
local CompareValues = __K2L_CompareValues

------------------------------------------------------------------ isSorted

-- whether the elements from the generator `gen` (true, element per call) are in the order of `compare`
function X.isSortedGen(gen, compare)
    local more, previous = gen()
    if not more then
        return true
    end
    while true do
        local next, element = gen()
        if not next then
            return true
        end
        if compare(previous, element) > 0 then
            return false
        end
        previous = element
    end
end

local function elements(source)
    if source.____isSequence then
        return source:iter()
    end
    local arr, n = source:____array()
    local i = 0
    return function()
        i = i + 1
        if i <= n then
            return true, arr[i]
        end
    end
end

-- `kind`: "" (natural order), "Descending", "By", "ByDescending" or "With", with the selector or comparator `f`
function X.isSorted(source, kind, f)
    local compare
    if kind == "" then
        compare = CompareValues
    elseif kind == "Descending" then
        compare = function(a, b) return CompareValues(b, a) end
    elseif kind == "By" then
        compare = function(a, b) return CompareValues(f(a), f(b)) end
    elseif kind == "ByDescending" then
        compare = function(a, b) return CompareValues(f(b), f(a)) end
    else
        compare = f
    end
    return X.isSortedGen(elements(source), compare)
end

------------------------------------------------------------------ Grouping into a destination

-- aggregateTo(destination, operation(key, accumulator, element, first)): any MutableMap of the program or the lualib
function X.aggregateTo(grouping, destination, operation)
    local selector = grouping.keySelector
    for _, element in elements(grouping.source) do
        local key = selector(element)
        local accumulator = destination:get(key)
        local first = accumulator == nil and not destination:containsKey(key)
        destination:put(key, operation(key, accumulator, element, first))
    end
    return destination
end

function X.eachCountTo(grouping, destination)
    return X.aggregateTo(grouping, destination, function(_, count, _, first)
        return (first and 0 or count) + 1
    end)
end

-- foldTo(destination, initialValue, operation(accumulator, element)), or with `selects` the overload whose initial value
-- is initialValueSelector(key, element) and whose operation is (key, accumulator, element)
function X.foldTo(grouping, destination, initial, operation, selects)
    if selects then
        return X.aggregateTo(grouping, destination, function(key, accumulator, element, first)
            return operation(key, first and initial(key, element) or accumulator, element)
        end)
    end
    return X.aggregateTo(grouping, destination, function(_, accumulator, element, first)
        if first then
            accumulator = initial
        end
        return operation(accumulator, element)
    end)
end

function X.reduceTo(grouping, destination, operation)
    return X.aggregateTo(grouping, destination, function(key, accumulator, element, first)
        if first then
            return element
        end
        return operation(key, accumulator, element)
    end)
end

function X.sourceIterator(grouping)
    return grouping.source:iterator()
end

------------------------------------------------------------------ maps

local function eachEntry(map, action)
    local arr, n = map:getEntries():____array()
    for i = 1, n do
        action(arr[i], i - 1)
    end
end

function X.onEachIndexed(map, action)
    eachEntry(map, function(entry, i) action(i, entry) end)
    return map
end

function X.mapTo(map, destination, transform)
    eachEntry(map, function(entry) destination:add(transform(entry)) end)
    return destination
end

function X.filterNotTo(map, destination, predicate)
    eachEntry(map, function(entry)
        if not predicate(entry) then
            destination:put(entry.key, entry.value)
        end
    end)
    return destination
end

------------------------------------------------------------------ Iterator.withIndex

local IndexingIterator = __K2L_Class("kotlin.collections.IndexingIterator")

function IndexingIterator:hasNext()
    return self.source:hasNext()
end

function IndexingIterator:next()
    local index = self.index
    self.index = index + 1
    return __K2L_IndexedValue.new(index, self.source:next())
end

function X.withIndex(iterator)
    return setmetatable({source = iterator, index = 0}, IndexingIterator)
end

function X.copyIndexed(value, index, element)
    if index == nil then
        index = value.index
    end
    if element == nil then
        element = value.value
    end
    return __K2L_IndexedValue.new(index, element)
end

------------------------------------------------------------------ text

local Text = __K2L_Text

-- findAnyOf (last false) and findLastAnyOf: the first (last) index where one of `strings` occurs, and the first of them
-- that occurs there
function X.findAnyOf(s, strings, from, ignoreCase, last)
    local arr, n = strings:____array()
    local bestIndex, bestString = -1, nil
    for i = 1, n do
        local at
        if last then
            at = Text.lastIndexOf(s, arr[i], from, ignoreCase)
        else
            at = Text.indexOf(s, arr[i], from, ignoreCase)
        end
        if at >= 0 and (bestIndex < 0 or (last and at > bestIndex) or (not last and at < bestIndex)) then
            bestIndex, bestString = at, arr[i]
        end
    end
    if bestIndex < 0 then
        return nil
    end
    return __K2L_Pair.new(bestIndex, bestString)
end

-- lastIndexOfAny of strings or chars (one-character strings)
function X.lastIndexOfAny(s, candidates, from, ignoreCase)
    local found = X.findAnyOf(s, candidates, from, ignoreCase, true)
    return found ~= nil and found.first or -1
end

function X.onEachIndexedChars(s, chars, action)
    local arr, n = chars:____array()
    for i = 1, n do
        action(i - 1, arr[i])
    end
    return s
end

function X.filterCharsTo(chars, destination, predicate)
    local arr, n = chars:____array()
    for i = 1, n do
        if predicate(arr[i]) then
            destination:append(arr[i])
        end
    end
    return destination
end

-- replaceIndent(newIndent): trimIndent() with each line indented by newIndent
function X.replaceIndent(s, indent)
    local trimmed = Text.trimIndent(s)
    if indent == nil or indent == "" or trimmed == "" then
        return trimmed
    end
    return indent .. trimmed:gsub("\n", "\n" .. indent:gsub("%%", "%%%%"))
end

-- replaceIndentByMargin(newIndent, marginPrefix): a line with the margin loses it and gets newIndent, another line stays
-- as it is; a blank first or last line is dropped
function X.replaceIndentByMargin(s, indent, prefix)
    indent, prefix = indent or "", prefix or "|"
    if prefix:match("^%s*$") then
        error(__K2L_IllegalArgumentException.new("marginPrefix must be non-blank string."))
    end
    local lines = Text.lines(s)
    local arr, n = lines:____array()
    local out = {}
    for i = 1, n do
        local line = arr[i]
        local blank = line:match("^%s*$") ~= nil
        if not ((i == 1 or i == n) and blank) then
            local start = line:find("%S")
            if start ~= nil and line:sub(start, start + #prefix - 1) == prefix then
                out[#out + 1] = indent .. line:sub(start + #prefix)
            else
                out[#out + 1] = line
            end
        end
    end
    return table.concat(out, "\n")
end
