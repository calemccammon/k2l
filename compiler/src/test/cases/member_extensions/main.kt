class Builder {
    val parts = mutableListOf<String>()
    private var prefix = ">"

    operator fun String.unaryPlus() {
        parts += prefix + this
    }

    operator fun Int.times(s: String): String {
        var r = ""
        for (i in 0 until this) r += s
        return r + this@Builder.prefix
    }

    infix fun String.joinWith(other: String) = this + "," + other + prefix

    fun String.shout() = uppercase() + "!" + parts.size

    // overloads of an operator by receiver type
    operator fun String.plus(n: Int) = this + "#" + n
    operator fun Int.plus(s: String) = "$this#$s"

    var String.tag: String
        get() = "<" + this + prefix + ">"
        set(v) {
            prefix = v + length
        }

    val Int.doubled: Int get() = this * 2 + parts.size

    fun run(): String {
        +"a"
        +"b"
        val x = 3 * "z"
        "q".tag = "!"
        return x + " " + ("l" joinWith "r") + " " + "hey".shout() + " " + "t".tag + " " + 4.doubled
    }

    fun String.twice(): String = this + this.shout()

    fun go() = "ab".twice()

    fun both(): String = "s" + 1 + "|" + (2 + "t")
}

class Counter {
    var count = 0

    fun Int.bump(): Int {
        count += this
        return count
    }

    operator fun Int.invoke(): String = "invoked $this with $count"

    var Int.scaled: Int
        get() = this * count
        set(v) {
            count = v / (if (this == 0) 1 else this)
        }

    fun demo(): String {
        val a = 3.bump()
        val b = 4.bump()
        2.scaled = 20
        val c = 5.scaled
        val d = 7()
        return "$a $b $c $d"
    }
}

interface Formatter {
    fun String.format(): String = "[" + this + "]"

    fun render(s: String): String = s.format()
}

class Loud : Formatter {
    override fun String.format(): String = uppercase() + "!"
}

class Plainer : Formatter

object Registry {
    val names = mutableListOf<String>()

    operator fun String.unaryPlus() {
        names.add(this)
    }

    fun String.register(times: Int) {
        for (i in 0 until times) names.add(this + i)
    }

    fun fill() {
        +"first"
        "gen".register(2)
    }
}

class Outer(val tag: String) {
    inner class Inner(val id: Int) {
        fun String.label(): String = this + "@" + id + "/" + tag + "/" + this@Outer.tag

        fun show(): String = "x".label()
    }

    fun String.mark() = this + tag

    fun nested(): String = Inner(5).show() + " " + "m".mark()
}

class Html {
    private val sb = StringBuilder()
    private var depth = 0

    fun tag(name: String, body: Html.() -> Unit) {
        sb.append("  ".repeat(depth)).append("<").append(name).append(">\n")
        depth++
        body()
        depth--
    }

    operator fun String.unaryPlus() {
        sb.append("  ".repeat(depth)).append(this).append("\n")
    }

    fun String.bold() = "*" + this + "*"

    override fun toString() = sb.toString()
}

fun html(body: Html.() -> Unit): Html {
    val h = Html()
    h.body()
    return h
}

class Maybe(val value: String?) {
    fun String?.orDash(): String = this ?: "-"
    fun show() = value.orDash() + (value?.let { it.orDash() } ?: "?")
}

// prefix operators on your own types
class Vec(val x: Int) {
    operator fun unaryMinus() = Vec(-x)

    operator fun unaryPlus() = Vec(x + 100)

    operator fun not() = x == 0

    override fun toString() = "Vec($x)"
}

fun main() {
    println(-Vec(3))
    println(+Vec(3))
    println(!Vec(0))
    println(!Vec(1))

    val b = Builder()
    println(b.run())
    println(b.parts)
    with(b) {
        +"c"
        println(2 * "k")
        println("w".shout())
        println(5.doubled)
        println("zz".tag)
        println("x" joinWith "y")
        println(b.parts.size)
        println("p" + 3)
        println(4 + "q")
    }
    b.apply { +"d" }
    println(b.parts)
    println(b.go())
    println(b.both())

    println(Counter().demo())

    println(Loud().render("hi"))
    println(Plainer().render("hi"))

    Registry.fill()
    with(Registry) {
        +"last"
        "more".register(1)
    }
    println(Registry.names)

    println(Outer("T").nested())

    val page = html {
        tag("body") {
            +"hello"
            tag("p") {
                +"world".bold()
            }
        }
    }
    print(page)

    println(Maybe("v").show())
    println(Maybe(null).show())
}
