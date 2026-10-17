class Counter(val name: String) {
    var total = 0
    private val log = mutableListOf<String>()

    fun record(msg: String) {
        log.add("$name: $msg")
    }

    fun history(): List<String> = log

    inner class Handle(val step: Int) {
        var uses = 0

        fun bump(): Int {
            total += step
            uses++
            record("bump by $step")
            return total
        }

        fun owner(): Counter = this@Counter

        fun ownerName(): String = name

        override fun toString() = "Handle($step) of $name uses=$uses total=$total"
    }

    inner class Named(val label: String) {
        constructor() : this("unnamed")

        constructor(a: Int, b: Int) : this("sum${a + b}")

        fun show() = "$label@$name"
    }

    fun newHandle(step: Int): Handle = Handle(step)

    fun makeNamed(): Named = Named("made")
}

class Outer(val tag: String) {
    var depth = 0

    fun tagged(s: String) = "$tag/$s"

    inner class Middle(val m: Int) {
        fun middleValue() = m * 2

        inner class Leaf(val leaf: Int) {
            fun describe(): String {
                depth++
                return tagged("leaf $leaf in middle $m") + " depth=$depth"
            }

            fun outers(): String = "${this@Middle.m} ${this@Outer.tag} ${middleValue()}"

            fun viaThis(): Int = this@Leaf.leaf + this.leaf
        }

        fun makeLeaf(n: Int) = Leaf(n + m)
    }

    fun middle(m: Int) = Middle(m)
}

open class Shape(val name: String) {
    open fun sides() = 0

    open inner class Part(val index: Int) {
        open fun label() = "$name part $index"
    }

    inner class SpecialPart(index: Int, val extra: String) : Part(index) {
        override fun label() = super.label() + " (" + extra + ")"
    }

    inner class Marked : Part(99) {
        override fun label(): String = "marked " + super.label()
    }

    inner class Late : Part {
        constructor(i: Int) : super(i + 100)

        constructor() : super(-1)
    }

    fun parts(): List<Part> = listOf(Part(1), SpecialPart(2, "x"), Marked(), Late(3), Late())
}

class Square : Shape("square") {
    override fun sides() = 4

    fun squarePart(): Part = Part(7)

    inner class Corner(val which: Int) {
        fun report() = "$name corner $which of ${sides()}"
    }
}

class Wrapper {
    var items = 0

    inner class Counted {
        init {
            items++
        }

        val id = items
    }

    inner class Lazy(val factor: Int = 3, val tag: String = "t") {
        fun scaled() = items * factor
    }
}

fun main() {
    val counter = Counter("main")
    val h1 = counter.Handle(2)
    val h2 = counter.Handle(5)
    println(h1.bump())
    println(h2.bump())
    println(h1.bump())
    println(counter.total)
    println(h1)
    println(h2)
    println(h1.owner() === counter)
    println(h2.ownerName())
    val h3 = counter.newHandle(10)
    println(h3.bump())
    println(counter.history())

    val other = Counter("other")
    val oh = other.Handle(1)
    oh.bump()
    println(other.total)
    println(counter.total)

    println(counter.Named().show())
    println(counter.Named("x").show())
    println(counter.Named(2, 3).show())
    println(counter.makeNamed().show())

    val outer = Outer("T")
    val mid = outer.middle(4)
    val leaf = mid.makeLeaf(1)
    println(leaf.describe())
    println(leaf.describe())
    println(leaf.outers())
    println(leaf.viaThis())
    val leaf2 = outer.Middle(10).Leaf(3)
    println(leaf2.describe())
    println(outer.depth)
    println(leaf2.outers())

    val sq = Square()
    for (p in sq.parts()) {
        println(p.label())
    }
    println(sq.squarePart().label())
    println(sq.Corner(2).report())
    val part: Shape.Part = sq.SpecialPart(5, "y")
    println(part.label())
    println(part is Shape.Part)
    println(part is Shape.SpecialPart)

    val w = Wrapper()
    val a = w.Counted()
    val b = w.Counted()
    val c = Wrapper().Counted()
    println("${a.id} ${b.id} ${c.id} ${w.items}")
    println(w.Lazy().scaled())
    println(w.Lazy(10).scaled())
    println(w.Lazy(tag = "z", factor = 2).scaled())

    val handles = listOf(1, 2, 3).map { counter.Handle(it) }
    println(handles.map { it.bump() })
    val total = handles.sumOf { it.step }
    println(total)
}
