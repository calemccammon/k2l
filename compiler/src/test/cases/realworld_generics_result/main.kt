package generics.result

// Error-handling types of a small functional library: Either with map/flatMap/fold, Validated that accumulates errors,
// an Outcome over the standard Result, and a form parser built on them.

sealed interface Either<out E, out A> {
    data class Left<out E>(val error: E) : Either<E, Nothing>
    data class Right<out A>(val value: A) : Either<Nothing, A>

    companion object {
        fun <A> right(a: A): Either<Nothing, A> = Right(a)
        fun <E> left(e: E): Either<E, Nothing> = Left(e)

        inline fun <A> catching(block: () -> A): Either<Throwable, A> = try {
            Right(block())
        } catch (e: Exception) {
            Left(e)
        }
    }
}

inline fun <E, A, B> Either<E, A>.map(f: (A) -> B): Either<E, B> = when (this) {
    is Either.Left -> this
    is Either.Right -> Either.Right(f(value))
}

inline fun <E, A, B> Either<E, A>.flatMap(f: (A) -> Either<E, B>): Either<E, B> = when (this) {
    is Either.Left -> this
    is Either.Right -> f(value)
}

inline fun <E, F, A> Either<E, A>.mapLeft(f: (E) -> F): Either<F, A> = when (this) {
    is Either.Left -> Either.Left(f(error))
    is Either.Right -> this
}

inline fun <E, A, R> Either<E, A>.fold(ifLeft: (E) -> R, ifRight: (A) -> R): R = when (this) {
    is Either.Left -> ifLeft(error)
    is Either.Right -> ifRight(value)
}

fun <E, A> Either<E, A>.getOrElse(default: A): A = fold({ default }, { it })

fun <E, A> List<Either<E, A>>.sequence(): Either<E, List<A>> {
    val out = ArrayList<A>(size)
    for (e in this) {
        when (e) {
            is Either.Left -> return e
            is Either.Right -> out += e.value
        }
    }
    return Either.Right(out)
}

sealed class Validated<out E, out A> {
    data class Valid<out A>(val value: A) : Validated<Nothing, A>()
    data class Invalid<out E>(val errors: List<E>) : Validated<E, Nothing>()

    inline fun <B> map(f: (A) -> B): Validated<E, B> = when (this) {
        is Valid -> Valid(f(value))
        is Invalid -> this
    }

    fun toEither(): Either<List<E>, A> = when (this) {
        is Valid -> Either.Right(value)
        is Invalid -> Either.Left(errors)
    }
}

fun <E, A, B, C> zip(a: Validated<E, A>, b: Validated<E, B>, f: (A, B) -> C): Validated<E, C> = when {
    a is Validated.Valid && b is Validated.Valid -> Validated.Valid(f(a.value, b.value))
    else -> Validated.Invalid(listOf(a, b).filterIsInstance<Validated.Invalid<E>>().flatMap { it.errors })
}

fun <E, A, B, C, D> zip(a: Validated<E, A>, b: Validated<E, B>, c: Validated<E, C>, f: (A, B, C) -> D): Validated<E, D> =
    zip(zip(a, b) { x, y -> x to y }, c) { (x, y), z -> f(x, y, z) }

fun <A> A.valid(): Validated<Nothing, A> = Validated.Valid(this)
fun <E> E.invalid(): Validated<E, Nothing> = Validated.Invalid(listOf(this))

enum class Field { NAME, AGE, EMAIL }

data class FieldError(val field: Field, val message: String) {
    override fun toString() = "${field.name.lowercase()}: $message"
}

data class User(val name: String, val age: Int, val email: String)

fun validateName(raw: String?): Validated<FieldError, String> = when {
    raw.isNullOrBlank() -> FieldError(Field.NAME, "required").invalid()
    raw.length > 12 -> FieldError(Field.NAME, "too long (${raw.length})").invalid()
    else -> raw.trim().replaceFirstChar { it.uppercase() }.valid()
}

fun validateAge(raw: String?): Validated<FieldError, Int> {
    val n = raw?.toIntOrNull() ?: return FieldError(Field.AGE, "not a number: $raw").invalid()
    return if (n in 0..150) n.valid() else FieldError(Field.AGE, "out of range: $n").invalid()
}

fun validateEmail(raw: String?): Validated<FieldError, String> =
    raw?.takeIf { '@' in it && !it.startsWith("@") }?.lowercase()?.valid() ?: FieldError(Field.EMAIL, "invalid: $raw").invalid()

fun parseUser(form: Map<String, String>): Validated<FieldError, User> =
    zip(validateName(form["name"]), validateAge(form["age"]), validateEmail(form["email"]), ::User)

/** A Result-based pipeline: the standard library's Result with runCatching, mapCatching and recover. */
fun parsePercent(s: String): Result<Double> = runCatching {
    val n = s.removeSuffix("%").trim().toDouble()
    require(n in 0.0..100.0) { "percent out of range: $n" }
    n / 100
}

fun <T, R> Result<T>.describe(f: (T) -> R): String = fold({ "ok(${f(it)})" }, { "err(${it::class.simpleName}: ${it.message})" })

fun divide(a: Int, b: Int): Either<String, Int> = if (b == 0) Either.left("division by zero") else Either.right(a / b)

fun main() {
    println("== either")
    val chain = divide(100, 5).flatMap { divide(it, 2) }.map { it * 3 }
    println("chain=$chain fold=${chain.fold({ "error $it" }, { "value $it" })}")
    val broken = divide(1, 0).flatMap { divide(it, 2) }.map { it + 1 }.mapLeft { it.uppercase() }
    println("broken=$broken orElse=${broken.getOrElse(-1)}")
    val all = listOf(divide(10, 2), divide(9, 3), divide(8, 4)).sequence()
    val some = listOf(divide(10, 2), divide(9, 0), divide(8, 0)).sequence()
    println("all=$all some=$some")
    val caught = Either.catching { "12x".toInt() }.mapLeft { it::class.simpleName }
    val fine = Either.catching { "12".toInt() }.map { it * 2 }
    println("caught=$caught fine=$fine")
    val values: List<Either<String, Any>> = listOf(Either.right(1), Either.left("x"), Either.right("two"), Either.right(3.5))
    println("rights=${values.filterIsInstance<Either.Right<Any>>().map { it.value }}")
    println("lefts=${values.filterIsInstance<Either.Left<String>>().joinToString { it.error }}")

    println("== validated")
    val forms = listOf(
        mapOf("name" to "ada", "age" to "36", "email" to "Ada@Example.org"),
        mapOf("name" to "", "age" to "abc", "email" to "nope"),
        mapOf("name" to "bartholomew-the-great", "age" to "200", "email" to "b@x.io"),
        mapOf("age" to "41", "email" to "@x"),
    )
    for (form in forms) {
        when (val result = parseUser(form)) {
            is Validated.Valid -> println("valid ${result.value}")
            is Validated.Invalid -> println("invalid ${result.errors}")
        }
    }
    val emails = forms.map(::parseUser).map { v -> v.map { it.email } }.mapNotNull { (it as? Validated.Valid)?.value }
    println("emails=$emails")
    val asEither = parseUser(forms[1]).toEither().mapLeft { errs -> errs.groupBy({ it.field }, { it.message }) }
    println("either=$asEither")

    println("== result")
    for (s in listOf("50%", " 12.5 ", "150", "abc")) println("$s -> ${parsePercent(s).describe { "%.3f".format(it) }}")
    val total = listOf("10%", "20%", "x", "30%").map(::parsePercent).mapNotNull { it.getOrNull() }.sum()
    println("total=$total")
    val recovered = parsePercent("oops").recover { 0.0 }.map { it + 1 }
    val mapped = parsePercent("40").mapCatching { check(it < 0.3) { "too high: $it" }; it }
    println("recovered=${recovered.getOrThrow()} mapped=${mapped.exceptionOrNull()?.message} isFailure=${mapped.isFailure}")
    val firstFailure = listOf("1", "2", "z", "w").map(::parsePercent).firstOrNull { it.isFailure }
    println("first failure: ${firstFailure?.exceptionOrNull()?.let { it::class.simpleName }}")
}
