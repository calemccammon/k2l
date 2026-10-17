-- requires: Class, Str
-- kotlin.Lazy: runs the initializer on first access and remembers the value.
local LazyImpl = __K2L_Class("kotlin.SynchronizedLazyImpl")

function LazyImpl:____init(initializer)
    self.initializer = initializer
    self.initialized = false
end

function LazyImpl:getValue()
    if not self.initialized then
        self.value = self.initializer()
        self.initialized = true
        self.initializer = nil
    end
    return self.value
end

function LazyImpl:isInitialized()
    return self.initialized
end

function LazyImpl:toString()
    return self.initialized and __K2L_Str(self.value) or "Lazy value not initialized yet."
end

local function __K2L_Lazy(initializer)
    return LazyImpl.new(initializer)
end
