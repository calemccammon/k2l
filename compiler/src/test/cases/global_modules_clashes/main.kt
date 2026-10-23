package app

fun clamp(x: Int) = x

class Panel

fun render() = Unit

fun shrink() = 5

val ____lualib = 1

val ____internal = 2

private fun helper() = 2

// Both files use both Models: two fields of the module table with one name.
internal class Model

internal fun models() = listOf(Model(), other.Model())

// A local of this file, which hides the global of other.useHelper
internal fun useHelper() = 3

fun main() {
    println(clamp(helper()) + other.useHelper() + useHelper())
}
