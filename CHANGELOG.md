# Changelog

All notable changes to k2l. The format follows [Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/). The version lives in `gradle.properties`.

## [Unreleased] (0.2.0)

### Added
- Release engineering: the version is defined once (`gradle.properties`) and `k2l --version` reports it; the CLI
  distribution (`./gradlew :compiler:distZip`) now includes the README (and a LICENSE once the repository has one);
  a tag-triggered GitHub Release workflow; Maven Central (Central Portal) and Gradle Plugin Portal publishing
  configuration for `dev.k2l:compiler`, `dev.k2l:lua-api` and the `dev.k2l` plugin; `RELEASING.md`.
- The compiler publishes `compiler-<version>-runtime-libs.zip`, a self-contained archive of its runtime classpath that
  the Gradle plugin resolves, so the plugin works from Maven Central without the JetBrains-only Analysis API
  repositories.

## Work before the first release

Merged pull requests, oldest first (there has been no tagged release yet).

### PR #7: Semantics, numbers and Unicode
- UTF-16 strings (`--strings utf16`) so `String` and `Char` behave like the JVM's.
- `Float32`, unsigned integer types and big numbers; checked casts.
- Lazy objects (`object` initialization on first use) and more language features.

### PR #6: Correctness, reflection and tooling
- `--int-overflow wrap` to make `Int` arithmetic wrap to 32 bits; array/list bounds checks.
- Reflection support, jumps out of `try` blocks.
- Source maps (`--source-map`) with Kotlin positions in Lua errors and tracebacks.
- Watch mode (`--watch`).
- The `dev.k2l` Gradle plugin with `compileKotlinToLua` and TestKit functional tests.
- Fixes for compiler hangs on CI (package clash with `lua-api`, exit on crashes, AWT work queued before disposing
  the Analysis API session).

### PR #5: Coroutines, stdlib and language gaps
- Coroutines, lazy sequences, wider standard library coverage and more language features.

### PR #4: Everyday Kotlin
- Inner classes, enum entry bodies, extension and delegated properties, open accessors.

### PR #3: Static analysis
- ktlint (via Spotless) and detekt, with all findings fixed.

### PR #2 and #1: Clean Code refactors
- The transformer was split by language area.

### Before the pull requests (milestones 1 to 8)
- Analysis API based frontend; core expressions, control flow and functions.
- Classes, interfaces, objects, enums and data classes; null safety, lambdas, extensions, default arguments,
  overloads and exceptions.
- Collections, ranges and strings with a shared `lualib_bundle.lua`; multi-file programs linked with `require`.
- Lua interop (`@LuaExternal` declarations, `LuaTable`, multiple returns).
- Lua 5.1, 5.2, 5.3, 5.4 and LuaJIT targets, with a CI matrix.
- CLI distribution, `k2l.json` projects and the README.
