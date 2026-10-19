import sys, os
out = sys.argv[1]; n = int(sys.argv[2])
os.makedirs(out + "/src/pkg", exist_ok=True)
for i in range(n):
    body = f"""package pkg

interface Shape{i} {{ fun area(): Double; val label: String }}
open class Base{i}(val id: Int, open val tag: String) {{
    var counter: Int = 0
    open fun describe(): String = "Base{i}#$id:$tag"
}}
class Impl{i}(id: Int, val items: List<Int>) : Base{i}(id, "impl"), Shape{i} {{
    override val label: String get() = "impl-$id"
    override fun area(): Double = items.sumOf {{ it * 2.5 }}
    override fun describe(): String = super.describe() + "/" + label
}}
data class Rec{i}(val name: String, val value: Int, val extra: List<String> = emptyList())
enum class Color{i} {{ RED, GREEN, BLUE }}
object Util{i} {{
    val cache = mutableMapOf<String, Int>()
    fun fib(n: Int): Int = if (n < 2) n else fib(n - 1) + fib(n - 2)
}}
class Lazy{i} {{
    val computed: Int by lazy {{ Util{i}.fib(10) }}
    var observed: String = "a"
}}
"""
    for f in range(12):
        body += f"""
fun work{i}_{f}(xs: List<Int>, k: Int): Map<String, Int> {{
    val sb = StringBuilder()
    val evens = xs.filter {{ it % 2 == 0 }}.map {{ it * k + {f} }}
    for ((idx, v) in evens.withIndex()) {{
        if (idx > 3) break
        sb.append("v").append(v).append(',')
    }}
    val recs = evens.map {{ Rec{i}("n$it", it, listOf("a", "b")) }}
    val grouped = recs.groupBy {{ it.value % 3 }}.mapValues {{ (_, l) -> l.size }}
    val result = mutableMapOf<String, Int>()
    for ((g, c) in grouped) result["g$g"] = c + sb.length
    when (Color{i}.values()[k % 3]) {{
        Color{i}.RED -> result["red"] = 1
        Color{i}.GREEN -> result["green"] = 2
        else -> result["blue"] = 3
    }}
    var total = 0
    var j = 0
    while (j < xs.size) {{ total += xs[j] * (j + 1); j++ }}
    result["total"] = total
    val s = "total=${{total}} size=${{result.size}}".uppercase().substring(2)
    result[s] = s.length
    val i2 = Impl{i}({f}, xs)
    result[i2.describe()] = i2.area().toInt()
    return result.filter {{ (key, v) -> key.isNotEmpty() && v >= 0 }}.toSortedMap()
}}
"""
    if i == 0:
        body += "\nfun main() {\n    println(work0_0(listOf(1,2,3,4,5,6), 3))\n    println(Lazy0().computed)\n}\n"
    else:
        body += f"\nfun call{i}(): Int = work{i}_0(listOf(1,2,3,4), {i}).size + (Lazy{i}().computed)\n"
    open(f"{out}/src/pkg/F{i}.kt", "w").write(body)
open(out + "/k2l.json", "w").write('{"srcDirs":["src"],"outDir":"out","luaTarget":"5.4"}\n')
