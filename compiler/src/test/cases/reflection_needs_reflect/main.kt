import kotlin.reflect.KFunction1
import kotlin.reflect.KProperty

// The members of references that need kotlin-reflect, which the JVM program does not have (-no-reflect): they throw
// KotlinReflectionNotSupportedError, and `name` works.

class Person(val name: String, var age: Int) {
    fun greet(other: String) = "hi $other"
}

fun twice(x: Int) = x * 2

suspend fun later() = 1

var counter = 1

lateinit var late: String

const val LIMIT = 3

fun probe(what: String, f: () -> Any?) {
    try {
        println("$what = ${f()}")
    } catch (e: Throwable) {
        println("$what threw ${e::class.simpleName}: ${e.message}")
    }
}

var evaluated = 0

fun person(): Person {
    evaluated++
    return Person("ann", 30)
}

class Logged {
    operator fun getValue(thisRef: Any?, property: KProperty<*>): Int {
        println("get ${property.name}: $property")
        probe("delegate returnType") { property.returnType }
        probe("delegate getter") { property.getter }
        probe("delegate isConst") { property.isConst }
        probe("delegate annotations") { property.annotations }
        return 1
    }

    operator fun setValue(thisRef: Any?, property: KProperty<*>, value: Int) {
        println("set ${property.name} = $value: $property")
    }
}

class Holder {
    val x by Logged()
    var y by Logged()
}

val top by Logged()

fun main() {
    probe("parameters") { ::twice.parameters }
    probe("returnType") { ::twice.returnType }
    probe("isSuspend") { ::twice.isSuspend }
    probe("suspend isSuspend") { ::later.isSuspend }
    probe("call") { ::twice.call(2) }
    probe("callBy") { ::twice.callBy(emptyMap()) }
    probe("visibility") { ::twice.visibility }
    probe("isOpen") { ::twice.isOpen }
    probe("isFinal") { ::twice.isFinal }
    probe("isAbstract") { ::twice.isAbstract }
    probe("isInline") { ::twice.isInline }
    probe("isExternal") { ::twice.isExternal }
    probe("isOperator") { ::twice.isOperator }
    probe("isInfix") { ::twice.isInfix }
    probe("typeParameters") { ::twice.typeParameters }
    probe("annotations") { ::twice.annotations }
    probe("method parameters") { Person::greet.parameters }
    probe("constructor parameters") { ::Person.parameters }
    probe("constructor name") { ::Person.name }
    probe("name") { ::twice.name }
    probe("bound method returnType") { person()::greet.returnType }
    println("receiver evaluated $evaluated time(s)")

    probe("property returnType") { Person::name.returnType }
    probe("property getter") { Person::name.getter }
    probe("property setter") { Person::age.setter }
    probe("property call") { Person::name.call(Person("bob", 1)) }
    probe("property parameters") { Person::name.parameters }
    probe("property visibility") { Person::name.visibility }
    probe("property isSuspend") { Person::name.isSuspend }
    probe("property getDelegate") { Person::name.getDelegate(Person("bob", 1)) }
    probe("isConst") { ::LIMIT.isConst }
    probe("isLateinit") { ::late.isLateinit }
    probe("top-level getter") { ::counter.getter }
    probe("top-level setter") { ::counter.setter }
    probe("property name") { Person::age.name }

    val f: KFunction1<String, String> = String::uppercase
    probe("library function name") { f.name }
    probe("library function parameters") { f.parameters }
    probe("library function returnType") { f.returnType }
    probe("library property returnType") { String::length.returnType }
    probe("library property getter") { String::length.getter }
    probe("library property name") { String::length.name }

    val holder = Holder()
    println(holder.x)
    holder.y = 5
    println(holder.y)
    println(top)
}
