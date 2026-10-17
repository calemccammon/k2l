package app

import app.util.Counter
import app.util.double
import app.util.head
import app.util.lastChar

// Plain getters on different receivers
val String.wordCount: Int get() = split(" ").size
val Int.squared: Int get() = this * this
val Int.isEven: Boolean get() = this % 2 == 0

// Same property name on two receivers
val String.size2: Int get() = length * 2
val List<Int>.size2: Int get() = size * 2

// A function with the accessor's name
fun getTwice(): Int = 2
val String.twice: String get() = this + this
fun getTwice(x: Int): Int = x * 2

// Generic and nullable receivers
val <T> List<T>.second: T get() = this[1]
val <T> List<T>.penultimate: T?
    get() = if (size >= 2) this[size - 2] else null
val String?.orDash: String get() = this ?: "-"
val String?.safeLength: Int get() = this?.length ?: -1

class Box(var value: Int, val name: String)

var Box.doubled: Int
    get() = value * 2
    set(v) {
        value = v / 2
    }

val Box.label: String get() = "$name=$value"

// A block-bodied getter with return
val Int.sign: String
    get() {
        if (this < 0) return "negative"
        if (this == 0) return "zero"
        return "positive"
    }

var counter = 0

var Int.tracked: Int
    get() = this + counter
    set(v) {
        counter += v
    }

fun Box.describe(): String = "$label doubled=$doubled"

fun makeBox(): Box {
    println("makeBox")
    return Box(10, "made")
}

fun main() {
    println("hello".lastChar)
    println("a b c".wordCount)
    println(7.squared)
    println(4.isEven)
    println(3.isEven)
    println("abc".size2)
    println(listOf(1, 2, 3).size2)
    println("ab".twice)
    println(getTwice())
    println(getTwice(5))
    println(listOf("x", "y", "z").second)
    println(listOf(1, 2, 3).penultimate)
    println(listOf(1).penultimate)
    val missing: String? = null
    println(missing.orDash)
    println("here".orDash)
    println(missing.safeLength)
    println("four".safeLength)

    val b = Box(5, "b")
    println(b.doubled)
    b.doubled = 20
    println(b.value)
    b.doubled += 4
    println(b.value)
    b.doubled++
    println(b.value)
    println(b.describe())

    // The receiver is evaluated once
    makeBox().doubled += 2
    val made = makeBox()
    made.doubled *= 3
    println(made.value)

    // Safe calls
    val nb: Box? = null
    println(nb?.doubled)
    println(nb?.label)
    val sb: Box? = Box(1, "s")
    println(sb?.doubled)
    println(sb?.label?.length)

    println((-5).sign)
    println(0.sign)
    println(9.sign)

    println(1.tracked)
    5.tracked = 3
    println(counter)
    println(1.tracked)

    // Properties from another file
    println("kotlin".lastChar)
    val c = Counter(4)
    println(c.double)
    c.double = 30
    println(c.count)
    c.double += 2
    println(c.count)
    val numbers = mutableListOf(1, 2, 3)
    println(numbers.head)
    numbers.head = 10
    numbers.head += 5
    println(numbers)
}
