// Library collections without a lualib base to extend are reported.
import java.util.Vector
import java.util.WeakHashMap

class Numbers : Vector<Int>()

class Cache : WeakHashMap<String, Int>()

fun main() {
    println(Numbers().size + Cache().size)
}
