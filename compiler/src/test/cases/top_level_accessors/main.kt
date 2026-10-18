package app

import app.config.Settings
import app.config.level
import app.config.name
import app.config.volume
import app.config.history
import app.config.describe
import app.config.hits

var counter = 3
val now: Int get() = counter * 2

val log = mutableListOf<String>()

var total = 0
    set(value) {
        log.add("total $field -> $value")
        field = value
    }

var clamped: Int = 5
    get() = if (field < 0) 0 else field
    set(v) {
        field = if (v > 10) 10 else v
    }

val doubled: Int = 21
    get() = field * 2

var fake: String
    get() = "fake$counter"
    set(v) {
        counter = v.length
    }

private val hidden: Int get() = 99

private var secret = 1
    get() = field + 100
    set(v) {
        field = v * 2
    }

var nullable: String? = null
    get() = field ?: "none"

var flag: Boolean = false
    set(v) {
        field = !v
    }

val computed: List<Int>
    get() = listOf(counter, counter + 1)

// a function and a property that would both be called getNow
fun getNow() = "fun getNow"

// used before its declaration
fun early() = later + 1
val later: Int get() = 41

// the initializer runs where the property is declared, and may branch
val branching: String = if (counter > 100) "big" else "small"
    get() = field.uppercase()

var lazyish = 0
    get() {
        field += 1
        return field
    }

fun main() {
    println(now)
    counter++
    println(now)

    total = 5
    total += 3
    total++
    ++total
    val old = total--
    println("$old $total")
    println(log)

    clamped = 50
    println(clamped)
    clamped -= 100
    println(clamped)
    clamped = 7
    clamped *= 2
    println(clamped)

    println(doubled)
    fake = "abcd"
    println("$fake $counter")
    println(hidden)
    secret = 4
    secret += 1
    println(secret)
    println(nullable)
    nullable = "set"
    println(nullable)
    flag = true
    println(flag)
    flag = true
    println(flag)
    println(computed)
    println(getNow())
    println(early())
    println(branching)
    println(lazyish + lazyish)

    // cross-file access
    println(name)
    name = "renamed"
    println(name)
    volume = 150
    volume += 10
    println(volume)
    println(level)
    println(hits)
    println(describe())
    Settings.touch()
    println(hits)
    println(level)
    println(history)
    val sum = now + volume + counter
    println(sum)
    val local = if (now > 5) total else clamped
    println(local)
}
