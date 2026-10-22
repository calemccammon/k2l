# k2l: Kotlin to Lua

k2l compiles Kotlin to plain, readable Lua. It is the Kotlin counterpart of
[TypeScriptToLua](https://typescripttolua.github.io/).

- At compile time you get Kotlin's checks and features: types, null safety, sealed classes, data classes, generics.
- At run time you get plain Lua for Lua 5.1, 5.2, 5.3, 5.4 and LuaJIT. It needs no third-party code.
- k2l does not emulate the JVM. The differences are listed in [Caveats](docs/caveats.md), and anything k2l cannot
  translate is a compile error.

## Example

```kotlin
sealed interface Shape
class Circle(val r: Double) : Shape
class Rect(val w: Double, val h: Double) : Shape

fun Shape.area(): Double = when (this) {
    is Circle -> 3.14159 * r * r
    is Rect -> w * h
}

fun main() {
    for (s in listOf(Circle(1.0), Rect(2.0, 3.0))) println(s.area())
}
```

```lua
-- excerpt
local function area(self)
    local ____mt = getmetatable(self)
    if ____mt == Circle then
        return 3.14159 * self.r * self.r
    elseif ____mt == Rect then
        return self.w * self.h
    end
end

local function main()
    local ____list = __K2L_ListOf(Circle.new(1.0), Rect.new(2.0, 3.0))
    for ____i = 1, ____list.size do
        local s = ____list[____i]
        print(area(s))
    end
end
```

## Build

You need JDK 21 or newer to run k2l, and a Lua interpreter to run its output.

```sh
./gradlew :compiler:installDist
export PATH="$PWD/compiler/build/install/k2l/bin:$PATH"   # the k2l launcher
```

## Use

### Command line

```sh
k2l                          # build the project in ./k2l.json
k2l -o out src               # compile src/ to out/
k2l -t JIT -o build src      # compile for LuaJIT
k2l --check                  # report errors without writing any Lua
k2l --watch                  # rebuild on every change
```

Run the output from its directory, because the files load each other with `require`:

```sh
cd out && lua5.4 main.lua
```

### `k2l.json`

```json
{
  "srcDirs": ["src"],
  "outDir": "out",
  "luaTarget": "5.4"
}
```

[`examples/hello`](examples/hello) is a complete project: run `k2l` in it, then `cd out && lua5.4 main.lua`.

### Gradle plugin

Use the plugin `dev.k2l` from a checkout of this repository as an included build:

```kotlin
// settings.gradle.kts
pluginManagement {
    includeBuild("/path/to/k2l")
}
includeBuild("/path/to/k2l")

// build.gradle.kts
plugins { id("dev.k2l") }
```

Or install it with `./gradlew publishToMavenLocal` in this repository, and add `mavenLocal()` to the repositories:

```kotlin
// settings.gradle.kts
pluginManagement {
    repositories { mavenLocal(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositories { mavenLocal() }
}
```

Then `./gradlew compileKotlinToLua` writes the Lua files to `build/lua`, and `./gradlew k2lCheck` checks the sources.

## Documentation

| Page | Contents |
|---|---|
| [Usage](docs/usage.md) | CLI options, `k2l.json`, the Gradle plugin, diagnostics, source maps, exit codes |
| [Language](docs/language.md) | Kotlin language features and the Lua they become |
| [Standard library](docs/library.md) | what of the standard library works, and what is a compile error |
| [Lua interop](docs/lua-interop.md) | calling Lua from Kotlin, and Kotlin from Lua |
| [Caveats](docs/caveats.md) | where the program behaves differently from Kotlin/JVM |
| [Development](docs/development.md) | building k2l, the tests, the code layout, CI |
