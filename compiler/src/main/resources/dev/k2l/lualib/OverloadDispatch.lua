-- requires: Equals
-- A program's class overriding one overload of a library member whose overloads are a single Lua method that dispatches
-- on its arguments keeps the other overloads working: the class's method is wrapped.

-- removeAll/retainAll(elements) overridden: `removeAll { predicate }` (MutableIterable.removeAll) removes through the
-- iterator, as the stdlib does for a collection that is not an ArrayList.
local function __K2L_DispatchPredicate(cls, name)
    local own = cls[name]
    local keep = name == "retainAll"
    cls[name] = function(self, elements)
        if type(elements) ~= "function" then
            return own(self, elements)
        end
        local changed = false
        local it = self:iterator()
        while it:hasNext() do
            if (elements(it:next()) and true or false) ~= keep then
                it:remove()
                changed = true
            end
        end
        return changed
    end
end

-- A map's remove(key) or remove(key, value) overridden: `remove(key, value)` calls the class's own two-argument remove (the
-- method `valueRemove`) if it has one, else removes the entry only when its value equals `value`, as Map's default does.
local function __K2L_DispatchMapRemove(cls, valueRemove)
    local own = cls.remove
    cls.remove = function(self, key, ...)
        if select("#", ...) == 0 then
            return own(self, key)
        end
        local value = ...
        if valueRemove ~= nil then
            return self[valueRemove](self, key, value)
        end
        local current = self:get(key)
        if not __K2L_Equals(current, value) or (current == nil and not self:containsKey(key)) then
            return false
        end
        own(self, key)
        return true
    end
end
