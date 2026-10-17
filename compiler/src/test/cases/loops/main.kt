fun main() {
    for (i in 1..3) print("$i ")
    println()
    for (i in 0 until 3) print("$i ")
    println()
    for (i in 0..<3) print("$i ")
    println()
    for (i in 5 downTo 1) print("$i ")
    println()
    for (i in 0..10 step 4) print("$i ")
    println()
    for (i in 10 downTo 0 step 5) print("$i ")
    println()
    val n = 4
    for (i in 1..n * 2) print("$i ")
    println()

    var i = 0
    while (i < 5) {
        i++
        if (i == 2) continue
        if (i == 4) break
        print("w$i ")
    }
    println()

    var j = 10
    do {
        j -= 3
        print("d$j ")
    } while (j > 0)
    println()

    outer@ for (a in 1..3) {
        for (b in 1..3) {
            if (b == 2) continue@outer
            if (a == 3) break@outer
            print("($a,$b) ")
        }
    }
    println()

    var sum = 0
    for (k in 1..100) {
        if (k % 2 == 0) continue
        sum += k
    }
    println(sum)
}
