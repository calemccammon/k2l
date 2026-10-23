# Usage

- [Command line](#command-line)
- [`k2l.json`](#k2ljson)
- [Gradle plugin](#gradle-plugin)
- [Global modules](#global-modules)
- [Diagnostics and `--check`](#diagnostics-and---check)
- [Source maps](#source-maps)
- [Watch mode](#watch-mode)
- [Exit codes](#exit-codes)

## Command line

```
k2l [options] [SOURCE_DIR...]
```

| Option | Meaning |
|---|---|
| `-p`, `--project FILE` | read settings from a `k2l.json` file |
| `-o`, `--out DIR` | output directory (default `out`) |
| `-t`, `--target VERSION` | `5.1`, `5.2`, `5.3`, `5.4` (default) or `JIT` |
| `--lualib MODE` | `require` (default) or `inline`, see below |
| `--modules MODE` | `require` (default) or `global`, see [Global modules](#global-modules) |
| `--classpath PATHS` | extra jars or class directories, such as Lua bindings (`:`-separated) |
| `--source-map` | write source maps (on by default with `--watch`) |
| `--no-source-map` | no source maps, also with `--watch` |
| `--check` | report errors without writing any files |
| `--watch` | rebuild whenever a source file or `k2l.json` changes (Ctrl-C to stop) |
| `-h`, `--help` | show the help |
| `--version` | show the version |

With no `SOURCE_DIR` and no `-p`, k2l reads `./k2l.json`.

Output:

- Each `.kt` file becomes a `.lua` file at the same relative path.
- Its module name is that path: `util/strings.kt` is `require("util.strings")`.
- `--lualib require` writes the runtime once, to `lualib_bundle.lua`. It has only the functions and methods the files use.
- `--lualib inline` puts a copy of the runtime each file uses into that file instead.
- A build with errors writes nothing.

The files load each other with `require`, which searches from the current directory. Run Lua from the output
directory, or add `out/?.lua` to `package.path`. With `--modules global` they use no `require`.

## `k2l.json`

```json
{
  "srcDirs": ["src"],
  "outDir": "out",
  "luaTarget": "5.4",
  "luaLibImport": "require",
  "moduleMode": "require",
  "classpath": [],
  "sourceMap": false
}
```

| Key | Meaning | CLI option |
|---|---|---|
| `srcDirs` | Kotlin source directories | `SOURCE_DIR...` |
| `outDir` | output directory (default `out`) | `-o` |
| `luaTarget` | `5.1`, `5.2`, `5.3`, `5.4` or `JIT` | `-t` |
| `luaLibImport` | `require` or `inline` | `--lualib` |
| `moduleMode` | `require` or `global` | `--modules` |
| `classpath` | extra jars or class directories | `--classpath` |
| `sourceMap` | `true` or `false` (default: on with `--watch`) | `--source-map`, `--no-source-map` |

- Paths are relative to the `k2l.json` file.
- Command-line options override the file.
- Comments and trailing commas are allowed.
- An unknown key or a wrong type is an error. An unknown key suggests the nearest valid one.

## Gradle plugin

The plugin `dev.k2l` runs the compiler on your sources. Make it available in one of two ways.

**Included build.** Point at a checkout of this repository:

```kotlin
// settings.gradle.kts
pluginManagement {
    includeBuild("/path/to/k2l")   // the plugin
}
includeBuild("/path/to/k2l")       // the compiler it runs

// build.gradle.kts
plugins { id("dev.k2l") }
```

**Maven local.** Run `./gradlew publishToMavenLocal` in this repository. It installs the compiler, `lua-api` and the
plugin into `~/.m2`. Then:

```kotlin
// settings.gradle.kts
pluginManagement {
    repositories { mavenLocal(); gradlePluginPortal() }
}
dependencyResolutionManagement {
    repositories { mavenLocal(); mavenCentral() }
}

// build.gradle.kts
plugins { id("dev.k2l") version "0.2.0" }   // the version in this repository's gradle.properties
```

### Settings

All settings are optional. These are the defaults:

```kotlin
k2l {
    sourceDirs.setFrom("src/main/kotlin")
    outputDir.set(layout.buildDirectory.dir("lua"))
    luaTarget.set("5.4")               // 5.1, 5.2, 5.3, 5.4 or JIT
    luaLibImport.set("require")        // or "inline"
    moduleMode.set("require")          // or "global"
    sourceMap.set(false)
    classpath.from(files())            // extra jars or class directories, e.g. Lua bindings
}
```

### Tasks

| Task | What it does |
|---|---|
| `compileKotlinToLua` | writes the Lua files to `outputDir`. `assemble` runs it. |
| `k2lCheck` | runs `k2l --check` and writes its report to `build/k2l/check.txt`. It fails on errors. It is not part of `check`; add `tasks.check { dependsOn("k2lCheck") }` if you want it there. |

Both tasks are up to date while the sources, settings and compiler are unchanged, and they support the configuration
cache.

### Other details

- The compiler runs in a separate JVM. It comes from the `k2lCompiler` configuration, which defaults to
  `dev.k2l:compiler:<plugin version>`.
- The compiler needs JDK 21. The plugin uses Gradle's own JVM when it is 21 or newer, and a JDK 21 toolchain otherwise.
- With the Kotlin JVM plugin applied too, `dev.k2l:lua-api` is added to `compileOnly`, so the
  [interop annotations](lua-interop.md) resolve in the IDE. `lua-api` is built with Kotlin 2.4, so that needs the Kotlin
  plugin 2.4 or newer.

## Global modules

Some Lua hosts have no `require`. They load each file themselves, in an order they set, for example from a manifest.
For them, use `--modules global` (`"moduleMode": "global"`).

- A file's public and internal top-level functions, properties, classes, objects and interfaces are Lua globals.
  Private ones stay `local`.
- A global has the declaration's Lua name, without the package. `@LuaName` changes it.
- Files use each other's declarations as globals. They do not `require` each other and do not return a table.
- External declarations with `@LuaRequire` still use `require`.
- `main` runs at the end of its file.

The runtime:

- With `--lualib require`, `lualib_bundle.lua` sets one global, `____lualib`, and each file reads the runtime functions
  it uses from it. Load the bundle first.
- With `--lualib inline`, each file has its own copy of the runtime functions it uses.

Load order:

- k2l does not know the order the host loads the files in.
- A file's top-level code runs when it loads: property initializers, objects that are created where they are declared,
  and `main`. Load the files this code uses before it.
- Functions and methods use other files' globals only when they are called.
- Top-level properties are initialized when their file loads. Where k2l would initialize them on first use (see
  [Language](language.md#supported)), it initializes them at the end of the file, after its functions and classes.

Names:

- All files share one set of globals. Two declarations with the same global name are an error, also in different
  packages. Rename one, or give a function or property another name with `@LuaName`.
- A declaration named `____lualib` is an error.
- A global replaces a global of the same name that the host defines.

## Diagnostics and `--check`

Kotlin compile errors stop the build, and so does every construct k2l cannot translate. Each diagnostic shows the
position, the source line, the problem underlined, and sometimes a `hint:` line with a workaround:

```
/path/to/src/main.kt:6:19: error: Unsigned type 'UInt' is not supported
    val n: UInt = 3u
                  ^^
  hint: use Int or Long: numbers are Lua numbers, and Lua has no unsigned ones
/path/to/src/main.kt:8:13: error: Constructing library class 'java.util.TreeMap' is not supported
    val t = TreeMap<String, Int>()
            ^^^^^^^^^^^^^^^^^^^^^^
k2l: checked 1 file(s): 2 errors, 0 warnings
```

An unsupported library API or construct is reported as `X is not supported`. A few errors name a Lua limit instead,
such as a jump that needs `goto` on Lua 5.1, or a name clash in the generated Lua.

`k2l --check` takes the same options as a build. It reports every problem and writes no files. Use it before porting
existing code, or in CI.

## Source maps

With `--source-map` (or `"sourceMap": true`):

- k2l writes a [Source Map v3](https://sourcemaps.info/spec.html) file next to each Lua file (`main.lua.map`).
- Lua error messages and tracebacks show Kotlin positions, also the ones `debug.traceback` returns:

```
java.lang.IllegalStateException: boom
stack traceback:
	main.kt:42: in function <main.kt:5>
	...
```

Source maps are off by default, except in watch mode.

## Watch mode

`k2l --watch` builds once, then rebuilds whenever a `.kt` file under the source directories or the `k2l.json` changes.
It re-reads `k2l.json` on every rebuild. Stop it with Ctrl-C.

## Exit codes

| Code | Meaning |
|---|---|
| `0` | success |
| `1` | errors in the Kotlin sources |
| `2` | bad command line or `k2l.json` |
| `70` | internal compiler error (k2l crashed; the stack trace is printed) |
