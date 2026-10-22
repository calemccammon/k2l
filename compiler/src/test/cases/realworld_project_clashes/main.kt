package draw

import draw.geometry.Registry as GeoRegistry
import draw.geometry.count as geoCount
import draw.geometry.describe
import draw.geometry.format as formatGeo
import draw.geometry.origin
import draw.text.Registry
import draw.text.Style
import draw.text.defaultStyle
import draw.text.styled
import draw.text.count
import draw.text.describe
import draw.text.format
import draw.text.print
import draw.text.select
import draw.text.type
import draw.geometry.Point as GPoint
import draw.text.Point as TPoint

// A drawing tool whose geometry and text packages both have a Point, a Registry, a `count` and `format`; main.kt
// imports them all, some under aliases, and names a local like the alias of another declaration.

class Point(val label: String) {
    override fun toString() = "main.Point($label)"
}

fun format(p: Point) = "main:$p"

fun main() {
    val g = GPoint(1.5, 2.0) + origin()
    val t = TPoint(3, 7)
    val parsed = TPoint("4:2")
    val own = Point("here")
    println(formatGeo(g))
    println(format(t))
    println(format(own))
    println(format("title", 8))
    println(g.describe())
    println(t.describe())
    println(listOf(parsed, t, TPoint(3, 1)).sorted())
    println(select(listOf(parsed, t, TPoint(3, 1)), 3))

    println("counts geo=$geoCount text=$count")
    GeoRegistry.register("circle")
    Registry.register("label")
    Registry.register("caption")
    geoCount += 5
    count -= 1
    println("counts geo=$geoCount text=$count")
    println(GeoRegistry.names + Registry.names)

    print("hello")
    println("type=$type")
    println(styled("plain") + " " + styled("loud", Style.BOLD))
    defaultStyle = Style.BOLD
    println(styled("now bold"))
    val geoCount = "shadowed"
    println(geoCount)
    println(draw.geometry.count)

    println(GPoint::class.simpleName + " " + TPoint::class.simpleName + " " + Point::class.simpleName)
    println(listOf<Any>(g, t, own).map { it::class.simpleName })
    println(own is Point)
    val any: Any = t
    println("${any is TPoint} ${any is GPoint}")
}
