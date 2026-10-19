-- requires: Class, Exceptions
-- A port of java.util.TimSort (and ComparableTimSort, the same algorithm calling compareTo): Arrays.sort,
-- Collections.sort and Kotlin's sortedWith/sortBy/sorted() of objects use it on the JVM, so comparators run in the same
-- order and as often as there. `__K2L_TimSort(a, lo, hi, compare)` sorts a[lo], ..., a[hi - 1] in place; `compare(x, y)`
-- returns a number. Indices are absolute positions in the 1-based array: every computation the JDK does on them is
-- invariant under the shift (midpoints use the sum of two indices, which shifts by two).
local __K2L_TimSort

do

local MIN_MERGE = 32
local MIN_GALLOP = 7

local floor = math.floor

-- System.arraycopy, including overlapping ranges of one array
local function copy(src, srcPos, dst, dstPos, n)
    if src == dst and dstPos > srcPos then
        for i = n - 1, 0, -1 do
            dst[dstPos + i] = src[srcPos + i]
        end
    else
        for i = 0, n - 1 do
            dst[dstPos + i] = src[srcPos + i]
        end
    end
end

local function binarySort(a, lo, hi, start, c)
    if start == lo then
        start = start + 1
    end
    while start < hi do
        local pivot = a[start]
        local left, right = lo, start
        while left < right do
            local mid = floor((left + right) / 2)
            if c(pivot, a[mid]) < 0 then
                right = mid
            else
                left = mid + 1
            end
        end
        for i = start, left + 1, -1 do
            a[i] = a[i - 1]
        end
        a[left] = pivot
        start = start + 1
    end
end

local function reverseRange(a, lo, hi)
    hi = hi - 1
    while lo < hi do
        a[lo], a[hi] = a[hi], a[lo]
        lo, hi = lo + 1, hi - 1
    end
end

local function countRunAndMakeAscending(a, lo, hi, c)
    local runHi = lo + 1
    if runHi == hi then
        return 1
    end
    runHi = runHi + 1
    if c(a[runHi - 1], a[lo]) < 0 then
        while runHi < hi and c(a[runHi], a[runHi - 1]) < 0 do
            runHi = runHi + 1
        end
        reverseRange(a, lo, runHi)
    else
        while runHi < hi and c(a[runHi], a[runHi - 1]) >= 0 do
            runHi = runHi + 1
        end
    end
    return runHi - lo
end

local function minRunLength(n)
    local r = 0
    while n >= MIN_MERGE do
        r = r + n % 2 -- once 1, stays 1: the JDK ORs the shifted-off bits
        if r > 1 then
            r = 1
        end
        n = floor(n / 2)
    end
    return n + r
end

-- Where `key` goes in a[base .. base + len - 1]: before the equal elements (gallopLeft) or after them (gallopRight).
local function gallopLeft(key, a, base, len, hint, c)
    local lastOfs, ofs = 0, 1
    if c(key, a[base + hint]) > 0 then
        local maxOfs = len - hint
        while ofs < maxOfs and c(key, a[base + hint + ofs]) > 0 do
            lastOfs = ofs
            ofs = ofs * 2 + 1
        end
        if ofs > maxOfs then
            ofs = maxOfs
        end
        lastOfs, ofs = lastOfs + hint, ofs + hint
    else
        local maxOfs = hint + 1
        while ofs < maxOfs and c(key, a[base + hint - ofs]) <= 0 do
            lastOfs = ofs
            ofs = ofs * 2 + 1
        end
        if ofs > maxOfs then
            ofs = maxOfs
        end
        lastOfs, ofs = hint - ofs, hint - lastOfs
    end
    lastOfs = lastOfs + 1
    while lastOfs < ofs do
        local m = lastOfs + floor((ofs - lastOfs) / 2)
        if c(key, a[base + m]) > 0 then
            lastOfs = m + 1
        else
            ofs = m
        end
    end
    return ofs
end

local function gallopRight(key, a, base, len, hint, c)
    local ofs, lastOfs = 1, 0
    if c(key, a[base + hint]) < 0 then
        local maxOfs = hint + 1
        while ofs < maxOfs and c(key, a[base + hint - ofs]) < 0 do
            lastOfs = ofs
            ofs = ofs * 2 + 1
        end
        if ofs > maxOfs then
            ofs = maxOfs
        end
        lastOfs, ofs = hint - ofs, hint - lastOfs
    else
        local maxOfs = len - hint
        while ofs < maxOfs and c(key, a[base + hint + ofs]) >= 0 do
            lastOfs = ofs
            ofs = ofs * 2 + 1
        end
        if ofs > maxOfs then
            ofs = maxOfs
        end
        lastOfs, ofs = lastOfs + hint, ofs + hint
    end
    lastOfs = lastOfs + 1
    while lastOfs < ofs do
        local m = lastOfs + floor((ofs - lastOfs) / 2)
        if c(key, a[base + m]) < 0 then
            ofs = m
        else
            lastOfs = m + 1
        end
    end
    return ofs
end

local function brokenContract()
    error(__K2L_IllegalArgumentException.new("Comparison method violates its general contract!"))
end

-- The merge state: the array, the comparator, minGallop and the stack of pending runs.
local function mergeLo(ts, base1, len1, base2, len2)
    local a, c = ts.a, ts.c
    local tmp = {}
    local cursor1, cursor2, dest = 1, base2, base1
    copy(a, base1, tmp, cursor1, len1)
    a[dest] = a[cursor2]
    dest, cursor2 = dest + 1, cursor2 + 1
    len2 = len2 - 1
    if len2 == 0 then
        copy(tmp, cursor1, a, dest, len1)
        return
    end
    if len1 == 1 then
        copy(a, cursor2, a, dest, len2)
        a[dest + len2] = tmp[cursor1]
        return
    end
    local minGallop = ts.minGallop
    while true do
        local count1, count2 = 0, 0
        local done = false
        repeat
            if c(a[cursor2], tmp[cursor1]) < 0 then
                a[dest] = a[cursor2]
                dest, cursor2 = dest + 1, cursor2 + 1
                count2, count1 = count2 + 1, 0
                len2 = len2 - 1
                if len2 == 0 then
                    done = true
                    break
                end
            else
                a[dest] = tmp[cursor1]
                dest, cursor1 = dest + 1, cursor1 + 1
                count1, count2 = count1 + 1, 0
                len1 = len1 - 1
                if len1 == 1 then
                    done = true
                    break
                end
            end
        until count1 >= minGallop or count2 >= minGallop -- (count1 | count2) < minGallop: one of them is 0
        if done then
            break
        end
        repeat
            count1 = gallopRight(a[cursor2], tmp, cursor1, len1, 0, c)
            if count1 ~= 0 then
                copy(tmp, cursor1, a, dest, count1)
                dest, cursor1, len1 = dest + count1, cursor1 + count1, len1 - count1
                if len1 <= 1 then
                    done = true
                    break
                end
            end
            a[dest] = a[cursor2]
            dest, cursor2 = dest + 1, cursor2 + 1
            len2 = len2 - 1
            if len2 == 0 then
                done = true
                break
            end
            count2 = gallopLeft(tmp[cursor1], a, cursor2, len2, 0, c)
            if count2 ~= 0 then
                copy(a, cursor2, a, dest, count2)
                dest, cursor2, len2 = dest + count2, cursor2 + count2, len2 - count2
                if len2 == 0 then
                    done = true
                    break
                end
            end
            a[dest] = tmp[cursor1]
            dest, cursor1 = dest + 1, cursor1 + 1
            len1 = len1 - 1
            if len1 == 1 then
                done = true
                break
            end
            minGallop = minGallop - 1
        until not (count1 >= MIN_GALLOP or count2 >= MIN_GALLOP)
        if done then
            break
        end
        if minGallop < 0 then
            minGallop = 0
        end
        minGallop = minGallop + 2
    end
    ts.minGallop = minGallop < 1 and 1 or minGallop
    if len1 == 1 then
        copy(a, cursor2, a, dest, len2)
        a[dest + len2] = tmp[cursor1]
    elseif len1 == 0 then
        brokenContract()
    else
        copy(tmp, cursor1, a, dest, len1)
    end
end

local function mergeHi(ts, base1, len1, base2, len2)
    local a, c = ts.a, ts.c
    local tmp = {}
    local tmpBase = 1
    copy(a, base2, tmp, tmpBase, len2)
    local cursor1, cursor2, dest = base1 + len1 - 1, tmpBase + len2 - 1, base2 + len2 - 1
    a[dest] = a[cursor1]
    dest, cursor1 = dest - 1, cursor1 - 1
    len1 = len1 - 1
    if len1 == 0 then
        copy(tmp, tmpBase, a, dest - (len2 - 1), len2)
        return
    end
    if len2 == 1 then
        dest, cursor1 = dest - len1, cursor1 - len1
        copy(a, cursor1 + 1, a, dest + 1, len1)
        a[dest] = tmp[cursor2]
        return
    end
    local minGallop = ts.minGallop
    while true do
        local count1, count2 = 0, 0
        local done = false
        repeat
            if c(tmp[cursor2], a[cursor1]) < 0 then
                a[dest] = a[cursor1]
                dest, cursor1 = dest - 1, cursor1 - 1
                count1, count2 = count1 + 1, 0
                len1 = len1 - 1
                if len1 == 0 then
                    done = true
                    break
                end
            else
                a[dest] = tmp[cursor2]
                dest, cursor2 = dest - 1, cursor2 - 1
                count2, count1 = count2 + 1, 0
                len2 = len2 - 1
                if len2 == 1 then
                    done = true
                    break
                end
            end
        until count1 >= minGallop or count2 >= minGallop
        if done then
            break
        end
        repeat
            count1 = len1 - gallopRight(tmp[cursor2], a, base1, len1, len1 - 1, c)
            if count1 ~= 0 then
                dest, cursor1, len1 = dest - count1, cursor1 - count1, len1 - count1
                copy(a, cursor1 + 1, a, dest + 1, count1)
                if len1 == 0 then
                    done = true
                    break
                end
            end
            a[dest] = tmp[cursor2]
            dest, cursor2 = dest - 1, cursor2 - 1
            len2 = len2 - 1
            if len2 == 1 then
                done = true
                break
            end
            count2 = len2 - gallopLeft(a[cursor1], tmp, tmpBase, len2, len2 - 1, c)
            if count2 ~= 0 then
                dest, cursor2, len2 = dest - count2, cursor2 - count2, len2 - count2
                copy(tmp, cursor2 + 1, a, dest + 1, count2)
                if len2 <= 1 then
                    done = true
                    break
                end
            end
            a[dest] = a[cursor1]
            dest, cursor1 = dest - 1, cursor1 - 1
            len1 = len1 - 1
            if len1 == 0 then
                done = true
                break
            end
            minGallop = minGallop - 1
        until not (count1 >= MIN_GALLOP or count2 >= MIN_GALLOP)
        if done then
            break
        end
        if minGallop < 0 then
            minGallop = 0
        end
        minGallop = minGallop + 2
    end
    ts.minGallop = minGallop < 1 and 1 or minGallop
    if len2 == 1 then
        dest, cursor1 = dest - len1, cursor1 - len1
        copy(a, cursor1 + 1, a, dest + 1, len1)
        a[dest] = tmp[cursor2]
    elseif len2 == 0 then
        brokenContract()
    else
        copy(tmp, tmpBase, a, dest - (len2 - 1), len2)
    end
end

-- Merges the runs at stack positions i and i + 1 (0-based, as in the JDK).
local function mergeAt(ts, i)
    local a, c, runBase, runLen = ts.a, ts.c, ts.runBase, ts.runLen
    local base1, len1 = runBase[i], runLen[i]
    local base2, len2 = runBase[i + 1], runLen[i + 1]
    runLen[i] = len1 + len2
    if i == ts.stackSize - 3 then
        runBase[i + 1], runLen[i + 1] = runBase[i + 2], runLen[i + 2]
    end
    ts.stackSize = ts.stackSize - 1
    local k = gallopRight(a[base2], a, base1, len1, 0, c)
    base1, len1 = base1 + k, len1 - k
    if len1 == 0 then
        return
    end
    len2 = gallopLeft(a[base1 + len1 - 1], a, base2, len2, len2 - 1, c)
    if len2 == 0 then
        return
    end
    if len1 <= len2 then
        mergeLo(ts, base1, len1, base2, len2)
    else
        mergeHi(ts, base1, len1, base2, len2)
    end
end

local function mergeCollapse(ts)
    local runLen = ts.runLen
    while ts.stackSize > 1 do
        local n = ts.stackSize - 2
        if n > 0 and runLen[n - 1] <= runLen[n] + runLen[n + 1] or n > 1 and runLen[n - 2] <= runLen[n] + runLen[n - 1] then
            if runLen[n - 1] < runLen[n + 1] then
                n = n - 1
            end
        elseif runLen[n] > runLen[n + 1] then
            break
        end
        mergeAt(ts, n)
    end
end

local function mergeForceCollapse(ts)
    local runLen = ts.runLen
    while ts.stackSize > 1 do
        local n = ts.stackSize - 2
        if n > 0 and runLen[n - 1] < runLen[n + 1] then
            n = n - 1
        end
        mergeAt(ts, n)
    end
end

function __K2L_TimSort(a, lo, hi, c)
    local nRemaining = hi - lo
    if nRemaining < 2 then
        return
    end
    if nRemaining < MIN_MERGE then
        local initRunLen = countRunAndMakeAscending(a, lo, hi, c)
        binarySort(a, lo, hi, lo + initRunLen, c)
        return
    end
    local ts = {a = a, c = c, minGallop = MIN_GALLOP, runBase = {}, runLen = {}, stackSize = 0}
    local minRun = minRunLength(nRemaining)
    repeat
        local runLen = countRunAndMakeAscending(a, lo, hi, c)
        if runLen < minRun then
            local force = nRemaining <= minRun and nRemaining or minRun
            binarySort(a, lo, lo + force, lo + runLen, c)
            runLen = force
        end
        ts.runBase[ts.stackSize], ts.runLen[ts.stackSize] = lo, runLen
        ts.stackSize = ts.stackSize + 1
        mergeCollapse(ts)
        lo, nRemaining = lo + runLen, nRemaining - runLen
    until nRemaining == 0
    mergeForceCollapse(ts)
end

end
