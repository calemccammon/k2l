fun id(x: Int): Int = x

fun t(label: String, f: () -> Any?) {
    try {
        println("$label = ${f()}")
    } catch (e: IndexOutOfBoundsException) {
        println("$label IOOBE: ${e.message}")
    } catch (e: NoSuchElementException) {
        println("$label NSEE: ${e.message}")
    } catch (e: ArithmeticException) {
        println("$label AE: ${e.message}")
    } catch (e: IllegalArgumentException) {
        println("$label IAE: ${e.message}")
    } catch (e: Exception) {
        println("$label OTHER: ${e.message}")
    }
}

fun main() {
    val s = "hello"
    val e = ""
    t("s[1]") { s[id(1)] }
    t("s[5]") { s[id(5)] }
    t("s[-1]") { s[id(-1)] }
    t("e[0]") { e[id(0)] }
    t("sub(2)") { s.substring(id(2)) }
    t("sub(5)") { s.substring(id(5)) }
    t("sub(6)") { s.substring(id(6)) }
    t("sub(-1)") { s.substring(id(-1)) }
    t("sub(1,3)") { s.substring(id(1), id(3)) }
    t("sub(3,1)") { s.substring(id(3), id(1)) }
    t("sub(0,9)") { s.substring(id(0), id(9)) }
    t("sub(-1,2)") { s.substring(id(-1), id(2)) }
    t("sub(5,5)") { s.substring(id(5), id(5)) }
    t("sub(0..2)") { s.substring(0..id(2)) }
    t("sub(0..9)") { s.substring(0..id(9)) }
    t("subSeq(1,3)") { s.subSequence(id(1), id(3)) }
    t("subSeq(1,9)") { s.subSequence(id(1), id(9)) }
    t("subSeq(3,1)") { s.subSequence(id(3), id(1)) }
    t("first") { s.first() }
    t("e.first") { e.first() }
    t("last") { s.last() }
    t("e.last") { e.last() }
    t("e.single") { e.single() }
    t("take(-1)") { s.take(id(-1)) }
    t("drop(-1)") { s.drop(id(-1)) }
    t("takeLast(-1)") { s.takeLast(id(-1)) }
    t("dropLast(-1)") { s.dropLast(id(-1)) }
    t("take(9)") { s.take(id(9)) }
    t("drop(9)") { s.drop(id(9)) }
    t("substringBefore") { s.substringBefore("z") }
    t("repeat(-1)") { s.repeat(id(-1)) }
    t("padStart(-1)") { s.padStart(id(-1)) }
    t("removeRange(3,1)") { s.removeRange(id(3), id(1)) }
    t("elementAt(9)") { s.elementAt(id(9)) }
    t("chunked(0)") { s.chunked(id(0)) }
    t("windowed(0)") { s.windowed(id(0)) }
    t("toInt") { "x".toInt() }
    t("digitToInt") { 'x'.digitToInt() }

    val list = listOf(1, 2, 3)
    val mlist = mutableListOf(1, 2, 3)
    val arr = arrayOf(1, 2, 3)
    val ia = intArrayOf(1, 2, 3)
    t("list[3]") { list[id(3)] }
    t("list[-1]") { list[id(-1)] }
    t("list.get(3)") { list.get(id(3)) }
    t("mlist[3]") { mlist[id(3)] }
    t("arr[3]") { arr[id(3)] }
    t("arr[-1]") { arr[id(-1)] }
    t("ia[3]") { ia[id(3)] }
    t("mlist[3]=") { mlist[id(3)] = 1 }
    t("mlist[-1]=") { mlist[id(-1)] = 1 }
    t("arr[3]=") { arr[id(3)] = 1 }
    t("ia[5]=") { ia[id(5)] = 1 }
    t("ia[3]+=") { ia[id(3)] += 1 }
    t("list.first") { emptyList<Int>().first() }
    t("list.last") { emptyList<Int>().last() }
    t("list.take(-1)") { list.take(id(-1)) }
    t("list.drop(-1)") { list.drop(id(-1)) }
    t("list.elementAt") { list.elementAt(id(7)) }
    t("list.subList") { list.subList(id(2), id(9)) }
    t("list.subList2") { list.subList(id(2), id(1)) }
    t("mlist.removeAt") { mlist.removeAt(id(9)) }
    t("mlist.add") { mlist.add(id(9), 1) }
    t("list.single") { list.single() }
    t("list.chunked") { list.chunked(id(0)) }
    t("list.windowed") { list.windowed(id(0)) }
    t("list.max") { emptyList<Int>().max() }
    t("list.reduce") { emptyList<Int>().reduce { a, b -> a + b } }
    t("list.random") { emptyList<Int>().random() }
    t("ints.avg") { emptyList<Int>().average() }
    t("div") { 1 / id(0) }
    t("rem") { 1 % id(0) }
    t("rem fn") { 1.rem(id(0)) }
    t("mod") { 1.mod(id(0)) }
    t("floorDiv") { 1.floorDiv(id(0)) }
    t("ldiv") { 1L / id(0).toLong() }
    t("lrem") { 1L % id(0).toLong() }
    t("lmod") { 1L.mod(id(0).toLong()) }
    t("fdiv") { 1.0 / id(0) }
    t("frem") { 1.5 % id(0).toDouble() }
    t("frem2") { -1.5 % 0.0 }
    t("frem3") { 5.5 % -2.0 }
    t("frem4") { -5.5 % 2.0 }
    t("fmod") { (-5.5).mod(2.0) }
    t("fmod0") { (5.5).mod(0.0) }
    t("zero div") { 0.0 / 0.0 }
    t("imod") { (-7).mod(id(3)) }
    t("imod2") { 7.mod(id(-3)) }
    t("ifloor") { (-7).floorDiv(id(2)) }
    t("irem") { (-7) % id(3) }
    t("irem2") { 7 % id(-3) }

    // indices of a loop over the collection itself need no check
    val data = intArrayOf(5, 6, 7)
    val text = "abc"
    val numbers = listOf(1, 2, 3)
    var total = 0
    for (i in data.indices) total += data[i]
    for (i in 0 until numbers.size) total += numbers[i]
    for (i in text.indices) total += text[i].code
    for (i in numbers.size - 1 downTo 0) total += numbers[i]
    for (i in 0..text.length - 1) total += text[i].code
    for (i in data.indices) data[i] = data[i] * 2
    println(total)
    println(data.toList())
    t("loop+1") { var x = 0; for (i in data.indices) x += data[i + 1]; x }
}
