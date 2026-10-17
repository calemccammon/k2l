package app.parity

fun isOdd(n: Int): Boolean = if (n == 0) false else isEven(n - 1)
