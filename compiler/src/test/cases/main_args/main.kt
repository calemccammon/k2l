// `main(args)` receives the command-line arguments as an Array<String> (none in the tests).
fun main(args: Array<String>) {
    println(args.isEmpty())
    println(args.size)
    println(args.joinToString(prefix = "[", postfix = "]"))
    println(args.toList())
    println(args.firstOrNull() ?: "no arguments")
    for (a in args) println(a)
    val verbose = "-v" in args
    println(verbose)
}
