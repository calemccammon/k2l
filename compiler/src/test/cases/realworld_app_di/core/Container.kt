package app.di.core

import kotlin.reflect.KClass

/** Something that can produce instances of [T]; the container decides how often it is asked. */
fun interface Provider<out T : Any> {
    fun get(): T
}

enum class Scope { SINGLETON, PROTOTYPE, SCOPED }

class ResolutionException(message: String, val chain: List<String>) : RuntimeException(message)

internal class Binding<T : Any>(
    val type: KClass<T>,
    val scope: Scope,
    val qualifier: String?,
    val factory: Container.() -> T,
) {
    var cached: T? = null
    var created = 0
        private set

    fun create(container: Container): T {
        created++
        return container.factory()
    }

    override fun toString(): String = "Binding(${type.simpleName}${qualifier?.let { "@$it" } ?: ""}, $scope)"
}

internal data class Key(val type: KClass<*>, val qualifier: String?) {
    override fun toString() = (type.simpleName ?: "?") + (qualifier?.let { "#$it" } ?: "")
}

/**
 * A small dependency-injection container. Bindings are looked up by class and optional qualifier;
 * a child container (a scope) sees its parent's bindings, but SCOPED bindings are cached per child.
 */
open class Container internal constructor(private val parent: Container?, val name: String) {
    private val bindings = linkedMapOf<Key, Binding<*>>()
    private val scopedCache = mutableMapOf<Key, Any>()
    private val resolving = ArrayDeque<Key>()
    protected val log = mutableListOf<String>()

    constructor(name: String = "root") : this(null, name)

    fun <T : Any> register(type: KClass<T>, scope: Scope, qualifier: String? = null, factory: Container.() -> T) {
        val key = Key(type, qualifier)
        require(key !in bindings) { "duplicate binding for $key in $name" }
        bindings[key] = Binding(type, scope, qualifier, factory)
        onRegister(key)
    }

    protected open fun onRegister(key: Any) {
        log += "register $key"
    }

    inline fun <reified T : Any> single(qualifier: String? = null, noinline factory: Container.() -> T) =
        register(T::class, Scope.SINGLETON, qualifier, factory)

    inline fun <reified T : Any> factory(qualifier: String? = null, noinline factory: Container.() -> T) =
        register(T::class, Scope.PROTOTYPE, qualifier, factory)

    inline fun <reified T : Any> scoped(noinline factory: Container.() -> T) = register(T::class, Scope.SCOPED, null, factory)

    inline fun <reified T : Any> get(qualifier: String? = null): T = resolve(T::class, qualifier)

    inline fun <reified T : Any> provider(qualifier: String? = null): Provider<T> = Provider { get<T>(qualifier) }

    inline fun <reified T : Any> lazyGet(): Lazy<T> = lazy { get<T>() }

    fun <T : Any> resolve(type: KClass<T>, qualifier: String? = null): T {
        val key = Key(type, qualifier)
        if (key in resolving) {
            val chain = (resolving.map { it.toString() } + key.toString())
            throw ResolutionException("cycle: ${chain.joinToString(" -> ")}", chain)
        }
        resolving.addLast(key)
        try {
            return lookup(key, this) ?: throw ResolutionException("no binding for $key in $name", resolving.map { it.toString() })
        } finally {
            resolving.removeLast()
        }
    }

    private fun <T : Any> lookup(key: Key, requester: Container): T? {
        @Suppress("UNCHECKED_CAST")
        val binding = bindings[key] as Binding<T>?
        if (binding == null) return parent?.lookup(key, requester)
        val value: T = when (binding.scope) {
            Scope.SINGLETON -> binding.cached ?: binding.create(this).also { binding.cached = it }
            Scope.PROTOTYPE -> binding.create(requester)
            Scope.SCOPED -> {
                @Suppress("UNCHECKED_CAST")
                requester.scopedCache.getOrPut(key) { binding.create(requester) } as T
            }
        }
        return value
    }

    fun child(name: String): Container = ChildContainer(this, name)

    fun describe(): List<String> = bindings.values.map { it.toString() } + (parent?.describe()?.map { "  ^ $it" } ?: emptyList())

    fun creations(): Map<String, Int> = bindings.entries.associate { (k, v) -> k.toString() to v.created }

    fun history(): List<String> = log.toList()
}

private class ChildContainer(parent: Container, name: String) : Container(parent, name) {
    override fun onRegister(key: Any) {
        log += "[$name] register $key"
    }
}
