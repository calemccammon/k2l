package app.parity

fun isEven(n: Int): Boolean = if (n == 0) true else isOdd(n - 1)
