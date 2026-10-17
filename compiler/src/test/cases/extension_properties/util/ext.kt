package app.util

val String.lastChar: Char get() = this[length - 1]

var MutableList<Int>.head: Int
    get() = this[0]
    set(value) {
        this[0] = value
    }

class Counter(var count: Int)

var Counter.double: Int
    get() = count * 2
    set(value) {
        count = value / 2
    }
