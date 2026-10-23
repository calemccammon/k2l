package ui

// Objects whose functions a host calls by name with `.`: XML handlers and entry points.
object Dispatch {
    var wheel = 0

    fun OnMouseWheel(x: Int, y: Int, delta: Int) {
        wheel += delta
        println("wheel $x $y $wheel")
    }
}

object Interface {
    var elapsed = 0.0

    fun CreatePlayWindowSet() {
        println("windows created")
    }

    fun Update(timePassed: Double) {
        elapsed += timePassed
        println("elapsed $elapsed")
    }
}

object Book {
    var title = "none"
    val pages: Int get() = title.length

    fun Initialize(name: String, page: Int) {
        title = name
        println("book $title at $page of $pages")
    }
}
