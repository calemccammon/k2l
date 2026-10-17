fun sign(n: Int): String = if (n > 0) "positive" else if (n < 0) "negative" else "zero"

fun describe(n: Int): String {
    val parity = if (n % 2 == 0) "even" else "odd"
    val size = when {
        n < 10 -> "small"
        n < 100 -> "medium"
        else -> "large"
    }
    return "$n is $parity and $size"
}

fun bucket(n: Int): Int = when (n) {
    0 -> 0
    1, 2, 3 -> 1
    in 4..9 -> 2
    !in 10..99 -> 4
    else -> 3
}

fun isPositive(n: Int): Boolean = if (n > 0) true else false

fun n0(): Int = 1

fun maybe(n: Int): String? = if (n > 0) null else "nonpositive"

fun main() {
    println(sign(5))
    println(sign(-5))
    println(sign(0))
    println(describe(7))
    println(describe(42))
    println(describe(1000))
    println(bucket(0))
    println(bucket(2))
    println(bucket(7))
    println(bucket(50))
    println(bucket(500))
    println(isPositive(3))
    println(isPositive(-3))
    println(maybe(1))
    println(maybe(-1))
    var label: String? = "stale"
    label = if (n0() > 0) null else "set"
    println(label)

    val n = 15
    val fizz = when {
        n % 15 == 0 -> {
            val word = "Fizz"
            word + "Buzz"
        }
        n % 3 == 0 -> "Fizz"
        else -> "$n"
    }
    println(fizz)

    var count = 0
    if (n > 10) {
        count += 1
    } else if (n > 5) {
        count += 2
    } else {
        count += 3
    }
    println(count)
}
