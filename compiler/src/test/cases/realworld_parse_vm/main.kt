// A two-pass assembler for a small stack VM: sealed instruction types, labels resolved to addresses, calls with a
// return stack, a disassembler written as a sequence, and a run loop that reports faults with the program counter.

sealed class Insn {
    data class Push(val v: Int) : Insn()
    data class Load(val slot: Int) : Insn()
    data class Store(val slot: Int) : Insn()
    data class Jump(val target: Int) : Insn()
    data class JumpIfZero(val target: Int) : Insn()
    data class Call(val target: Int) : Insn()
    data class Arith(val op: Char) : Insn()
    data class Cmp(val op: String) : Insn()
    data object Ret : Insn()
    data object Dup : Insn()
    data object Swap : Insn()
    data object Pop : Insn()
    data object Print : Insn()
    data object Emit : Insn()
    data object Halt : Insn()
}

class AsmError(val lineNo: Int, msg: String) : Exception("asm line $lineNo: $msg")
class VmFault(val pc: Int, msg: String) : Exception("fault at pc=$pc: $msg")

object Assembler {
    private val labelDef = Regex("""^([A-Za-z_][\w.]*):$""")
    private val arithOps = mapOf("add" to '+', "sub" to '-', "mul" to '*', "div" to '/', "mod" to '%', "and" to '&', "or" to '|', "xor" to '^', "shl" to '<')
    private val cmpOps = mapOf("eq" to "==", "ne" to "!=", "lt" to "<", "le" to "<=", "gt" to ">", "ge" to ">=")

    private fun cleaned(src: String) = src.lines().mapIndexed { n, l -> n + 1 to l.substringBefore(';').trim() }.filter { it.second.isNotEmpty() }

    fun assemble(src: String): List<Insn> {
        val labels = HashMap<String, Int>()
        var addr = 0
        for ((n, l) in cleaned(src)) {
            val m = labelDef.matchEntire(l)
            if (m != null) {
                val name = m.groupValues[1]
                if (labels.put(name, addr) != null) throw AsmError(n, "duplicate label '$name'")
            } else {
                addr++
            }
        }
        val out = ArrayList<Insn>(addr)
        for ((n, l) in cleaned(src)) {
            if (labelDef.matches(l)) continue
            val parts = l.split(Regex("\\s+"), limit = 2)
            val op = parts[0].lowercase()
            val arg = parts.getOrNull(1)
            fun need(): String = arg ?: throw AsmError(n, "'$op' needs an operand")
            fun num(): Int = need().let { a ->
                when {
                    a.startsWith("'") && a.endsWith("'") && a.length == 3 -> a[1].code
                    a.startsWith("0x") -> a.substring(2).toIntOrNull(16)
                    else -> a.toIntOrNull()
                } ?: throw AsmError(n, "bad number '$a'")
            }
            fun label(): Int = labels[need()] ?: throw AsmError(n, "unknown label '${need()}'")
            out += when (op) {
                "push" -> Insn.Push(num())
                "load" -> Insn.Load(num())
                "store" -> Insn.Store(num())
                "jmp" -> Insn.Jump(label())
                "jz" -> Insn.JumpIfZero(label())
                "call" -> Insn.Call(label())
                in arithOps -> Insn.Arith(arithOps.getValue(op))
                in cmpOps -> Insn.Cmp(cmpOps.getValue(op))
                "ret" -> Insn.Ret
                "dup" -> Insn.Dup
                "swap" -> Insn.Swap
                "pop" -> Insn.Pop
                "print" -> Insn.Print
                "emit" -> Insn.Emit
                "halt" -> Insn.Halt
                else -> throw AsmError(n, "unknown mnemonic '${parts[0]}'")
            }
        }
        return out
    }
}

fun disassemble(code: List<Insn>): Sequence<String> = sequence {
    val targets = code.mapNotNull {
        when (it) {
            is Insn.Jump -> it.target
            is Insn.JumpIfZero -> it.target
            is Insn.Call -> it.target
            else -> null
        }
    }.toSortedSet()
    for ((pc, insn) in code.withIndex()) {
        if (pc in targets) yield("L$pc:")
        val text = when (insn) {
            is Insn.Push -> "push ${insn.v}"
            is Insn.Load -> "load r${insn.slot}"
            is Insn.Store -> "store r${insn.slot}"
            is Insn.Jump -> "jmp L${insn.target}"
            is Insn.JumpIfZero -> "jz L${insn.target}"
            is Insn.Call -> "call L${insn.target}"
            is Insn.Arith -> "arith '${insn.op}'"
            is Insn.Cmp -> "cmp ${insn.op}"
            else -> insn.toString().lowercase()
        }
        yield("  %03d  %s".format(pc, text))
    }
}

class Vm(private val code: List<Insn>, private val maxSteps: Int = 100_000) {
    private val stack = IntArray(64)
    private var sp = 0
    private val regs = IntArray(8)
    private val calls = ArrayDeque<Int>()
    val output = StringBuilder()
    var steps = 0
        private set

    private fun push(pc: Int, v: Int) {
        if (sp == stack.size) throw VmFault(pc, "stack overflow")
        stack[sp++] = v
    }

    private fun pop(pc: Int): Int = if (sp == 0) throw VmFault(pc, "stack underflow") else stack[--sp]

    private fun slot(pc: Int, s: Int): Int = if (s in regs.indices) s else throw VmFault(pc, "bad register r$s")

    fun run(): Int {
        var pc = 0
        while (true) {
            if (pc !in code.indices) throw VmFault(pc, "pc out of range")
            if (++steps > maxSteps) throw VmFault(pc, "step budget of $maxSteps exhausted")
            val insn = code[pc]
            var next = pc + 1
            when (insn) {
                is Insn.Push -> push(pc, insn.v)
                is Insn.Load -> push(pc, regs[slot(pc, insn.slot)])
                is Insn.Store -> regs[slot(pc, insn.slot)] = pop(pc)
                is Insn.Jump -> next = insn.target
                is Insn.JumpIfZero -> if (pop(pc) == 0) next = insn.target
                is Insn.Call -> {
                    if (calls.size >= 32) throw VmFault(pc, "call depth exceeded")
                    calls.addLast(next)
                    next = insn.target
                }
                Insn.Ret -> next = calls.removeLastOrNull() ?: throw VmFault(pc, "return with empty call stack")
                is Insn.Arith -> {
                    val b = pop(pc)
                    val a = pop(pc)
                    push(pc, arith(pc, insn.op, a, b))
                }
                is Insn.Cmp -> {
                    val b = pop(pc)
                    val a = pop(pc)
                    val r = when (insn.op) {
                        "==" -> a == b
                        "!=" -> a != b
                        "<" -> a < b
                        "<=" -> a <= b
                        ">" -> a > b
                        else -> a >= b
                    }
                    push(pc, if (r) 1 else 0)
                }
                Insn.Dup -> pop(pc).let { push(pc, it); push(pc, it) }
                Insn.Swap -> {
                    val b = pop(pc)
                    val a = pop(pc)
                    push(pc, b)
                    push(pc, a)
                }
                Insn.Pop -> pop(pc)
                Insn.Print -> output.append(pop(pc)).append(' ')
                Insn.Emit -> output.append(pop(pc).toChar())
                Insn.Halt -> return if (sp > 0) stack[sp - 1] else 0
            }
            pc = next
        }
    }

    private fun arith(pc: Int, op: Char, a: Int, b: Int): Int = when (op) {
        '+' -> a + b
        '-' -> a - b
        '*' -> a * b
        '/', '%' -> if (b == 0) throw VmFault(pc, "division by zero") else if (op == '/') a / b else a % b
        '&' -> a and b
        '|' -> a or b
        '^' -> a xor b
        else -> a shl b
    }
}

val programs = linkedMapOf(
    "factorial" to """
        push 10
        store 0        ; n
        push 1
        store 1        ; acc
    loop:
        load 0
        jz done
        load 1
        load 0
        mul
        store 1
        load 0
        push 1
        sub
        store 0
        jmp loop
    done:
        load 1
        print
        load 1
        halt
    """,
    "gcd_calls" to """
        push 1071
        push 462
        call gcd
        print
        push 'O'
        emit
        push 'K'
        emit
        halt
    gcd:                 ; (a b -- gcd)
        dup
        jz gcd.end
        swap
        store 7
        dup
        load 7
        swap
        mod
        jmp gcd
    gcd.end:
        pop
        ret
    """,
    "bits" to """
        push 1
        push 31
        shl
        dup
        print
        push 0x7fffffff
        add
        print
        push -7
        push 2
        div
        print
        push -7
        push 2
        mod
        print
        push 12
        push 10
        xor
        push 3
        lt
        print
        halt
    """,
    "underflow" to "push 1\nadd\nhalt",
    "divzero" to "push 4\npush 0\ndiv\nhalt",
    "spin" to "top:\njmp top",
    "recurse" to "f:\ncall f",
    "badret" to "ret",
    "badreg" to "push 1\nstore 9",
    "falloff" to "push 1",
)

fun main() {
    for ((name, src) in programs) {
        val code = Assembler.assemble(src.trimIndent())
        if (name == "gcd_calls") disassemble(code).forEach(::println)
        val vm = Vm(code, maxSteps = 500)
        try {
            val top = vm.run()
            println("$name: out=[${vm.output.toString().trim()}] top=$top steps=${vm.steps}")
        } catch (f: VmFault) {
            println("$name: ${f.message} (out=[${vm.output}], steps=${vm.steps})")
        }
    }
    val bad = listOf("push", "jmp nowhere", "a:\na:\nhalt", "frob 3", "push 12z", "push 'ab'")
    for (src in bad) {
        val r = runCatching { Assembler.assemble(src) }
        println(r.exceptionOrNull()?.message ?: "assembled ${r.getOrNull()}")
    }
    val counts = programs.values.flatMap { Assembler.assemble(it.trimIndent()) }.groupingBy { it::class.simpleName }.eachCount()
    println(counts.entries.sortedWith(compareByDescending<Map.Entry<String?, Int>> { it.value }.thenBy { it.key }).take(5))
    println(Insn.Halt == Assembler.assemble("halt").single() && Insn.Push(3) == Insn.Push(3))
}
