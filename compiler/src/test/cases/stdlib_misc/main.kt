fun pairs() {
    val p = Pair(1, "a")
    println(p)
    println(p.copy(first = 2))
    println(p.toList())
    val (n, s) = p
    println("$n$s")
    println(1 to 2 == Pair(1, 2))
    val t = Triple(1, "b", 2.5)
    println(t)
    println(t.third)
    println(t.copy(second = "z"))
    println(t.toList())
    println(listOf(1 to "x", 2 to "y").toMap())
    println(listOf(1 to "x", 2 to "y").map { it.second })
    println(Pair(Pair(1, 2), 3).first.second)
    println(Pair(1, 2).hashCode() == Pair(1, 2).hashCode())
    println(mapOf(Pair(1, 2) to "v")[Pair(1, 2)])
}

fun checks() {
    try {
        require(false) { "bad arg" }
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        require(1 > 2)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        check(false) { "bad state" }
    } catch (e: IllegalStateException) {
        println(e.message)
    }
    try {
        check(1 > 2)
    } catch (e: IllegalStateException) {
        println(e.message)
    }
    try {
        requireNotNull(null as String?) { "was null" }
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        checkNotNull(null as Int?)
    } catch (e: IllegalStateException) {
        println(e.message)
    }
    try {
        error("boom")
    } catch (e: IllegalStateException) {
        println(e.message)
    }
    try {
        TODO()
    } catch (e: NotImplementedError) {
        println(e.message)
    }
    println(requireNotNull("ok"))
    println(checkNotNull(5))
}

fun errors() {
    try {
        listOf(1).first { it > 5 }
    } catch (e: NoSuchElementException) {
        println(e.message)
    }
    try {
        emptyList<Int>().first()
    } catch (e: NoSuchElementException) {
        println(e)
    }
    try {
        emptyList<Int>().max()
    } catch (e: NoSuchElementException) {
        println(e)
    }
    try {
        listOf(1, 2).single()
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        mapOf("a" to 1).getValue("b")
    } catch (e: NoSuchElementException) {
        println(e.message)
    }
    try {
        listOf(1).get(5)
    } catch (e: IndexOutOfBoundsException) {
        println("ioobe")
    }
    try {
        "abc".toInt()
    } catch (e: NumberFormatException) {
        println(e)
    }
    try {
        listOf(1, 2, 3).chunked(0)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
    try {
        listOf(1).take(-1)
    } catch (e: IllegalArgumentException) {
        println(e.message)
    }
}

fun results() {
    println(runCatching { 1 }.getOrNull())
    println(runCatching { error("x") }.exceptionOrNull()?.message)
    println(runCatching { "12".toInt() }.map { it * 2 }.getOrDefault(0))
    println(runCatching { "zz".toInt() }.getOrDefault(-1))
    println(runCatching { "zz".toInt() }.recover { 0 }.getOrThrow())
    println(runCatching { 5 }.fold({ "ok $it" }, { "err" }))
    println(Result.success(3).isSuccess)
    println(Result.failure<Int>(RuntimeException("f")).isFailure)
}

fun scope() {
    val s = "abc"
    println(s.let { it.length })
    println(s.also { println("also $it") })
    println(s.run { length })
    println(with(s) { uppercase() })
    println(s.takeIf { it.length > 5 })
    println(s.takeUnless { it.length > 5 })
    println(buildList { add(1); add(2) })
    println(buildMap { put("a", 1) })
    println(buildSet { add(1); add(1) })
    println(List(3) { it * it })
    println(MutableList(2) { "x$it" })
    println(IntArray(3) { it + 1 }.toList())
    println(listOfNotNull(1, null, 2))
    println(emptyMap<String, Int>())
    println(setOf(3, 1, 2).sorted())
    println(arrayListOf(1, 2).apply { add(3) })
    println(mutableSetOf(1).apply { addAll(listOf(2, 3)) })
    println(lazy { 5 }.value)
}

fun main() {
    pairs()
    checks()
    errors()
    results()
    scope()
}
