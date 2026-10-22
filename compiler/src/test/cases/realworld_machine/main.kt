// A puzzle-style register machine: instructions parsed with Regex and destructuring,
// a sealed instruction hierarchy, bitmask "memory" writes and memoized wire evaluation.

sealed class Instr {
    data class Set(val reg: Char, val value: Operand) : Instr()
    data class Add(val reg: Char, val value: Operand) : Instr()
    data class Mul(val reg: Char, val value: Operand) : Instr()
    data class Mod(val reg: Char, val value: Operand) : Instr()
    data class Jnz(val test: Operand, val offset: Operand) : Instr()
    data class Out(val value: Operand) : Instr()
    object Halt : Instr() {
        override fun toString() = "Halt"
    }
}

sealed interface Operand {
    data class Lit(val v: Long) : Operand
    data class Reg(val r: Char) : Operand
}

fun parseOperand(s: String): Operand = s.toLongOrNull()?.let { Operand.Lit(it) } ?: Operand.Reg(s.single())

// an op of three word characters and up to two operands (Lua patterns have no optional groups: split on blanks)
private val OP = Regex("""\w{3}""")

fun parseProgram(text: String): List<Instr> = text.lines()
    .map { it.substringBefore('#').trim() }
    .filter { it.isNotEmpty() }
    .map { line ->
        val parts = line.split(Regex("\\s+"))
        if (parts.size > 3 || !parts[0].matches(OP)) throw IllegalArgumentException("bad line: '$line'")
        val (op, a, b) = List(3) { parts.getOrElse(it) { "" } }
        when (op) {
            "set" -> Instr.Set(a[0], parseOperand(b))
            "add" -> Instr.Add(a[0], parseOperand(b))
            "mul" -> Instr.Mul(a[0], parseOperand(b))
            "mod" -> Instr.Mod(a[0], parseOperand(b))
            "jnz" -> Instr.Jnz(parseOperand(a), parseOperand(b))
            "out" -> Instr.Out(parseOperand(a))
            "hlt" -> Instr.Halt
            else -> error("unknown op $op")
        }
    }

class Machine(private val program: List<Instr>) {
    val registers = mutableMapOf<Char, Long>().withDefault { 0L }
    val output = mutableListOf<Long>()
    var steps = 0
        private set

    private fun Operand.value(): Long = when (this) {
        is Operand.Lit -> v
        is Operand.Reg -> registers.getValue(r)
    }

    fun run(limit: Int = 10_000): Machine = apply {
        var pc = 0
        while (pc in program.indices && steps < limit) {
            steps++
            when (val ins = program[pc]) {
                is Instr.Set -> registers[ins.reg] = ins.value.value()
                is Instr.Add -> registers[ins.reg] = registers.getValue(ins.reg) + ins.value.value()
                is Instr.Mul -> registers[ins.reg] = registers.getValue(ins.reg) * ins.value.value()
                is Instr.Mod -> registers[ins.reg] = registers.getValue(ins.reg) % ins.value.value()
                is Instr.Jnz -> if (ins.test.value() != 0L) {
                    pc += ins.offset.value().toInt()
                    continue
                }
                is Instr.Out -> output += ins.value.value()
                Instr.Halt -> return@apply
            }
            pc++
        }
    }
}

val PROGRAM = """
    set a 10      # counter
    set b 1
    set f 0
    mul b 3       # loop start
    mod b 1000
    add f b
    out b
    add a -1
    jnz a -5
    out f
    hlt
    out 999       # never reached
"""

// Bitmask memory: mask=X1X0 style, writes forced through the mask.
fun applyMask(mask: String, value: Long): Long {
    var result = value
    mask.reversed().forEachIndexed { bit, c ->
        when (c) {
            '1' -> result = result or (1L shl bit)
            '0' -> result = result and (1L shl bit).inv()
        }
    }
    return result
}

fun floatingAddresses(mask: String, address: Long): List<Long> {
    val base = mask.reversed().foldIndexed(address) { bit, acc, c -> if (c == '1') acc or (1L shl bit) else acc }
    val floating = mask.reversed().withIndex().filter { it.value == 'X' }.map { it.index }
    return (0 until (1 shl floating.size)).map { combo ->
        floating.foldIndexed(base) { i, acc, bit ->
            if (combo and (1 shl i) != 0) acc or (1L shl bit) else acc and (1L shl bit).inv()
        }
    }.sorted()
}

val MEMORY = """
    mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0
    mask = 000000000000000000000000000000X1001X
    mem[42] = 100
""".trimIndent()

fun runMemory(text: String): Pair<Long, Map<Long, Long>> {
    val mem = sortedMapOf<Long, Long>()
    var mask = ""
    val memLine = Regex("""mem\[(\d+)] = (\d+)""")
    for (line in text.lineSequence()) {
        if (line.startsWith("mask")) {
            mask = line.substringAfter("= ")
            continue
        }
        val (addr, value) = memLine.find(line)!!.groupValues.drop(1).map(String::toLong)
        mem[addr] = applyMask(mask, value)
    }
    return mem.values.sum() to mem
}

// Wires: "x AND y -> z", evaluated lazily with memoization.
val CIRCUIT = """
    123 -> x
    456 -> y
    x AND y -> d
    x OR y -> e
    x LSHIFT 2 -> f
    y RSHIFT 2 -> g
    NOT x -> h
    NOT y -> i
    d OR f -> j
    j AND e -> a
""".trimIndent()

class Circuit(text: String) {
    private val rules: Map<String, List<String>> = text.lines().associate { line ->
        val (expr, target) = line.split(" -> ")
        target to expr.split(" ")
    }
    private val cache = HashMap<String, Int>()
    var evaluations = 0
        private set

    fun signal(wire: String): Int {
        wire.toIntOrNull()?.let { return it }
        return cache.getOrPut(wire) {
            evaluations++
            val parts = rules[wire] ?: throw NoSuchElementException("no wire $wire")
            val value = when (parts.size) {
                1 -> signal(parts[0])
                2 -> signal(parts[1]).inv()
                else -> {
                    val (l, op, r) = parts
                    when (op) {
                        "AND" -> signal(l) and signal(r)
                        "OR" -> signal(l) or signal(r)
                        "LSHIFT" -> signal(l) shl signal(r)
                        "RSHIFT" -> signal(l) ushr signal(r)
                        else -> error("bad op $op")
                    }
                }
            }
            value and 0xFFFF
        }
    }
}

fun main() {
    val program = parseProgram(PROGRAM)
    println("${program.size} instructions; first: ${program.first()}, last: ${program.last()}")
    println(program.groupingBy { it::class.simpleName }.eachCount())
    val m = Machine(program).run()
    println("output=${m.output}")
    println("registers=${m.registers.toSortedMap()} steps=${m.steps}")
    println("a=${m.registers.getValue('a')} z=${m.registers.getValue('z')}")
    val looping = parseProgram("set a 1\njnz a 0")
    println("looping steps: ${Machine(looping).run(limit = 50).steps}")
    try {
        parseProgram("set a\nfoo")
    } catch (e: RuntimeException) {
        println("error: $e")
    }
    try {
        parseProgram("set a 1\nfoo bar baz qux")
    } catch (e: IllegalArgumentException) {
        println("error: ${e.message}")
    }
    try {
        parseProgram("xyz a 1")
    } catch (e: IllegalStateException) {
        println("error: ${e.message}")
    }

    val (sum, mem) = runMemory(MEMORY)
    println("memory sum=$sum mem=$mem")
    println("floating: ${floatingAddresses("000000000000000000000000000000X1001X", 42)}")
    println("mask bits: ${applyMask("1".repeat(36), 0).toString(2).length} ${applyMask("X1X0", 9).toString(2)}")
    val bits = (0..16).map { it.countOneBits() }
    println("bit counts: $bits highest=${100.takeHighestOneBit()} trailing=${96.countTrailingZeroBits()}")

    val circuit = Circuit(CIRCUIT)
    for (w in listOf("d", "e", "f", "g", "h", "i", "x", "y", "a")) print("$w=${circuit.signal(w)} ")
    println()
    println("evaluations=${circuit.evaluations}")
    println(runCatching { circuit.signal("zz") }.exceptionOrNull())
}
