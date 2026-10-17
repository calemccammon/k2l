fun main() {
    val name = "Kotlin"
    val version = 2
    val ratio = 0.5
    val ok = true
    val missing: String? = null
    println("Hello, $name $version!")
    println("ratio=$ratio ok=$ok missing=$missing")
    println("expr: ${version * 10 + 1} ${name.length}")
    println("$version")
    println(name.uppercase() + " " + name.lowercase())
    println("ab".repeat(3))
    println("quotes \"inside\" and \\backslash\\ and tab\tend")
    println("dollar \$name")
    println("unicode: héllo ✓")
    println("".isEmpty())
    println(name + version)
    println(name + ratio)
    val c = 'x'
    println("char $c")
    var s = "a"
    s += "b"
    s += 1
    println(s)
    println(version.toString() + ratio.toString())
}
