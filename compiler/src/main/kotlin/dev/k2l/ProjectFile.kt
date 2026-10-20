package dev.k2l

import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonArray
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.JsonPrimitive
import kotlinx.serialization.json.booleanOrNull
import java.nio.file.Files
import java.nio.file.Path

private val PROJECT_KEYS =
    listOf("srcDirs", "outDir", "luaTarget", "luaLibImport", "classpath", "intOverflow", "strings", "long64", "sourceMap")

/** Comments and trailing commas are accepted: k2l.json is written by hand. */
@OptIn(ExperimentalSerializationApi::class)
private val LENIENT_JSON = Json {
    allowComments = true
    allowTrailingComma = true
}

/**
 * k2l.json, with paths relative to its directory:
 * `{"srcDirs": ["src"], "outDir": "out", "luaTarget": "5.4", "luaLibImport": "require", "classpath": [], "intOverflow": "unchecked",
 * "strings": "bytes", "long64": "double", "sourceMap": false}`
 */
internal fun readProject(file: Path): Settings {
    require(Files.isRegularFile(file)) { "project file $file not found" }
    val json = try {
        LENIENT_JSON.parseToJsonElement(Files.readString(file))
    } catch (e: SerializationException) {
        // The parser's message starts with the position; the rest is advice about its own builder options.
        throw IllegalArgumentException("$file is not valid JSON: ${e.message.orEmpty().lineSequence().first()}", e)
    }
    require(json is JsonObject) { "$file must contain a JSON object" }
    checkKeys(file, json.keys)
    val dir = file.toAbsolutePath().parent
    val project = ProjectJson(file, json)
    return Settings(
        sources = project.paths("srcDirs").map(dir::resolve),
        out = project.string("outDir")?.let(dir::resolve) ?: dir.resolve("out"),
        target = project.string("luaTarget")?.let(LuaTarget::parse) ?: LuaTarget.Lua54,
        lualib = project.string("luaLibImport")?.let(::parseLualib) ?: LuaLibImport.Require,
        classpath = project.paths("classpath").map(dir::resolve),
        intOverflow = project.string("intOverflow")?.let(IntOverflow::parse) ?: IntOverflow.Unchecked,
        strings = project.string("strings")?.let(StringSemantics::parse) ?: StringSemantics.Bytes,
        long64 = project.string("long64")?.let(Long64::parse) ?: Long64.AsDouble,
        sourceMap = project.boolean("sourceMap"),
    )
}

private fun checkKeys(file: Path, keys: Set<String>) {
    val unknown = keys - PROJECT_KEYS.toSet()
    if (unknown.isEmpty()) return
    val described = unknown.joinToString { key -> closestMatch(key, PROJECT_KEYS)?.let { "'$key' (did you mean '$it'?)" } ?: "'$key'" }
    throw IllegalArgumentException("unknown key(s) in $file: $described; the keys are ${PROJECT_KEYS.joinToString()}")
}

/** Typed reads of k2l.json values: a value of the wrong type is an error rather than silently ignored. */
private class ProjectJson(private val file: Path, private val json: JsonObject) {
    private fun wrongType(key: String, expected: String, value: JsonElement): Nothing =
        throw IllegalArgumentException("'$key' in $file must be $expected, not $value")

    fun string(key: String): String? = json[key]?.let { value ->
        (value as? JsonPrimitive)?.takeIf { it.isString }?.content ?: wrongType(key, "a string", value)
    }

    fun boolean(key: String): Boolean? = json[key]?.let { value ->
        (value as? JsonPrimitive)?.takeIf { !it.isString }?.booleanOrNull ?: wrongType(key, "true or false", value)
    }

    fun paths(key: String): List<String> = json[key]?.let { value ->
        val array = value as? JsonArray ?: wrongType(key, "an array of paths", value)
        array.map { (it as? JsonPrimitive)?.takeIf { p -> p.isString }?.content ?: wrongType(key, "an array of paths", value) }
    }.orEmpty()
}
