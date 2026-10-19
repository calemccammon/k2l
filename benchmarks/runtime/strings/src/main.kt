fun main() {
    val sb = StringBuilder()
    for (i in 0 until 200000) {
        sb.append("item").append(i).append(',')
    }
    println(sb.length)
    var s = ""
    for (i in 0 until 20000) s += i.toString()
    println(s.length)
    var count = 0
    for (c in sb.toString()) if (c == ',') count++
    println(count)
    val parts = sb.toString().split(",")
    println(parts.size)
    var total = 0
    for (p in parts) if (p.startsWith("item1")) total += p.length
    println(total)
    val joined = parts.take(50000).joinToString("-") { it.uppercase() }
    println(joined.length)
    var h = 0
    for (i in 0 until joined.length) h = h * 31 + joined[i].code
    println(h)
    val tmpl = (0 until 100000).map { "k$it=${it * 2}" }
    println(tmpl.last())
}
