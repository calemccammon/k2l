# Development

You need JDK 21 or newer. The tests also need Lua interpreters: `lua5.1`, `lua5.2`, `lua5.3`, `lua5.4` and `luajit`.
A missing interpreter skips that target's tests.

## Commands

| Command | What it does |
|---|---|
| `./gradlew test` | transpile and run every test case on every Lua interpreter found |
| `./gradlew check` | the tests, the Gradle plugin's functional tests, ktlint (`spotlessCheck`) and detekt |
| `./gradlew :gradle-plugin:functionalTest` | only the plugin's TestKit tests |
| `./gradlew spotlessApply` | reformat the Kotlin sources with ktlint |
| `./gradlew :compiler:installDist` | build the `k2l` launcher in `compiler/build/install/k2l/bin` |
| `./gradlew :compiler:distZip` | the same as a zip, in `compiler/build/distributions` |
| `./gradlew :compiler:run --args="..."` | run k2l from the repository root |
| `./gradlew publishToMavenLocal` | install the compiler, `lua-api` and the plugin into `~/.m2` |

- The version of everything, including `k2l --version`, is the `version` in `gradle.properties`.
- Compiler warnings are errors. detekt's settings are in `config/detekt.yml`.

## Golden tests

Each directory in `compiler/src/test/cases` is one program.

| File | Meaning |
|---|---|
| `main.kt` | the program; other `.kt` files and subdirectories are part of it too |
| `expected.lua` | the exact Lua output for Lua 5.4 |
| `stdout.txt` | what the program prints on Lua 5.4 |
| `stdout.<target>.txt` | what it prints on another target where that differs (`stdout.5.1.txt`, `stdout.JIT.txt`) |
| `errors.txt` | expected diagnostics instead of output: `line:column: message`, then an optional `  hint: ...` line |
| `targets-skip.txt` | targets the case cannot run on, one `target: reason` per line |
| `options.txt` | compiler options, one `name=value` per line: `luaLibImport=inline`, `moduleMode=global`, `noImplicitSelf=true` |
| `load-order.txt` | with `moduleMode=global`: the Lua files to load, one per line. The test sets `require` and `package` to nil, then runs `lualib_bundle.lua` and these files with `dofile`. |
| `lib/` | hand-written Lua the program calls into, copied next to the output (`lib/greeter.lua` is `require("lib.greeter")`) |

The test runs each case on every installed target and compares its output with `stdout.txt` or `stdout.<target>.txt`.

Never write expected output by hand:

```sh
./gradlew test -PupdateGolden        # rewrite expected.lua, stdout.txt, stdout.<target>.txt and errors.txt
```

`-PupdateGolden` writes `stdout.<target>.txt` only where that target's output differs, and deletes it when it no
longer does. Review the diff before you commit.

Other options:

```sh
./gradlew test -Ponly=casts,lazy_objects     # only these cases
./gradlew test -Plua51=/path/to/lua5.1       # the interpreter for a target; also -Plua52, -Plua53, -Plua54, -Pluajit
```

## Code layout

| Path | Contents |
|---|---|
| `compiler/src/main/kotlin/dev/k2l` | the CLI (`Main.kt`), options, `k2l.json`, diagnostics, source maps, watch mode |
| `.../frontend` | the Kotlin Analysis API session that parses and type-checks the sources |
| `.../transform` | Kotlin to a Lua syntax tree, one file per language or library area |
| `.../codegen` | the Lua syntax tree and its printer |
| `compiler/src/main/resources/dev/k2l/lualib` | the runtime, in plain Lua; `Name.51.lua`, `Name.jit.lua`, `Name.float.lua` and the like are target-specific variants |
| `compiler/src/test` | the golden test cases and the unit tests |
| `lua-api` | the interop declarations (`dev.k2l.lua`) |
| `gradle-plugin` | the Gradle plugin and its TestKit tests |
| `examples/hello` | a small project with a `k2l.json` |

The compiler copies only the statements of the runtime that a program uses (`codegen/LualibPruning.kt`). A statement
at the top level of a runtime file that is not a definition, such as a loop filling a table, is always copied. Build such
a table in a function instead: `local T = (function() ... end)()`.

The Analysis API artifacts come from JetBrains' `intellij-dependencies` repository and must match the Kotlin version
exactly. See the comments in `gradle/libs.versions.toml` before upgrading Kotlin.

## CI

`.github/workflows/ci.yml` has one job, `test`. It installs JDK 21 and the five Lua interpreters on Ubuntu, then runs
`./gradlew check`. It runs on every push to `main` and on every pull request.
