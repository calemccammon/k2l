# Releasing k2l

Nothing is published automatically except the GitHub Release. Maven Central and the Gradle Plugin Portal are published
by a maintainer running Gradle with their own credentials.

## One-time setup

### Blocker: a license

The repository has no `LICENSE` file, and Maven Central rejects artifacts without license information. Decide on a
license, add `LICENSE` at the repository root (the CLI zip picks it up automatically) and replace the `TODO` license
name and url in the `pom { licenses { ... } }` block of the root `build.gradle.kts`.

### Maven Central (Central Portal)

1. Create an account at <https://central.sonatype.com> and verify the namespace `dev.k2l` (needs control of the
   `k2l.dev` domain, or choose another group id such as `io.github.calemccammon` and change `group` in the root
   `build.gradle.kts` and the `dev.k2l:...` coordinates in `K2lPlugin.kt`).
2. Generate a user token (Account, "Generate User Token"). This gives a username and a password.
3. Create a GPG key and publish its public part to a keyserver (for example keys.openpgp.org):
   ```sh
   gpg --full-generate-key
   gpg --keyserver keyserver.ubuntu.com --send-keys <KEYID>
   gpg --armor --export-secret-keys <KEYID>   # the value of signingInMemoryKey
   ```

### Gradle Plugin Portal

Create an account at <https://plugins.gradle.org>, then "API Keys" gives a key and a secret. The first publication of
the plugin id `dev.k2l` is reviewed by Gradle; the id must not already be taken.

### Credentials

They are only ever read from Gradle properties, normally set as environment variables, never stored in the repository:

| Environment variable | Used for |
|---|---|
| `ORG_GRADLE_PROJECT_mavenCentralUsername` | Central Portal token username |
| `ORG_GRADLE_PROJECT_mavenCentralPassword` | Central Portal token password |
| `ORG_GRADLE_PROJECT_signingInMemoryKey` | ASCII-armored secret key (also enables signing) |
| `ORG_GRADLE_PROJECT_signingInMemoryKeyId` | last 8 characters of the key id (optional) |
| `ORG_GRADLE_PROJECT_signingInMemoryKeyPassword` | key passphrase |
| `GRADLE_PUBLISH_KEY` and `GRADLE_PUBLISH_SECRET` (or `-Pgradle.publish.key` / `-Pgradle.publish.secret`) | Plugin Portal |

The GitHub Release workflow needs no secrets: it uses the built-in `GITHUB_TOKEN`. If publishing is later moved into
GitHub Actions, store the values above as repository secrets named `MAVEN_CENTRAL_USERNAME`,
`MAVEN_CENTRAL_PASSWORD`, `SIGNING_KEY`, `SIGNING_KEY_ID`, `SIGNING_KEY_PASSWORD`, `GRADLE_PUBLISH_KEY` and
`GRADLE_PUBLISH_SECRET`, and map them to the variables above in the job's `env`.

## Cutting a release (0.2.0)

For 0.2.0, `gradle.properties` already says `version=0.2.0`, and `CHANGELOG.md` already has a `## [0.2.0] - YYYY-MM-DD`
section, so the checklist starts at the date. For a later release, first set `version=X.Y.Z` in `gradle.properties`.
Then move the entries under `## [Unreleased]` into a new `## [X.Y.Z] - YYYY-MM-DD` section, and add its link at the
bottom of the file.

Careful: `./gradlew publish` (without a suffix) also uploads to Maven Central. For local checks, use only
`publishToMavenLocal`.

1. **Set the date.** Replace `YYYY-MM-DD` in the `## [0.2.0]` heading of `CHANGELOG.md` with the release date. Commit
   this ("Release 0.2.0") on `main`, and wait for CI to be green on that commit.
2. **Check locally**, with no credentials in the environment, so nothing is signed or uploaded.
   `-Dmaven.repo.local` keeps the artifacts out of `~/.m2`:
   ```sh
   export JAVA_HOME=...   # JDK 21
   ./gradlew check :compiler:distZip :gradle-plugin:validatePlugins publishToMavenLocal -Dmaven.repo.local=$PWD/build/m2
   unzip -l compiler/build/distributions/k2l-0.2.0.zip   # README.md, bin/k2l, bin/k2l.bat, lib/*.jar (compiler-0.2.0.jar)
   find build/m2 -name '*.pom'                          # compiler, lua-api, gradle-plugin, dev.k2l.gradle.plugin, all 0.2.0
   ```
   Unpack the zip and run `bin/k2l --version`, which must print `k2l 0.2.0`. Read through one POM: check the name,
   description, url, scm, developers and licenses.
3. **Tag and push the tag.** This starts the "Release" workflow (`.github/workflows/release.yml`), which:
   - runs `./gradlew check` with all five Lua interpreters;
   - builds `k2l-0.2.0.zip` and `.tar`;
   - smoke-tests the zip: `k2l --version` must print `k2l 0.2.0`, then `examples/hello` is compiled and run;
   - writes `SHA256SUMS` and creates the GitHub Release with generated notes.

   A tag with a suffix such as `v0.2.0-rc1` is marked as a pre-release. The workflow takes the version from the tag
   (`-Pversion=...`), so the tag must match `gradle.properties`.
   ```sh
   git tag -a v0.2.0 -m "k2l 0.2.0" && git push origin v0.2.0
   ```
   Then check the release page:
   - the zip, the tar and `SHA256SUMS` are attached;
   - `sha256sum -c SHA256SUMS` passes for the downloaded files;
   - the unpacked zip prints `k2l 0.2.0`.

   The generated notes list the merged pull requests. Paste the `0.2.0` section of `CHANGELOG.md` above them.
4. **Publish to Maven Central** with the tag checked out (or pass `-Pversion=0.2.0`). Export
   `ORG_GRADLE_PROJECT_mavenCentralUsername`, `ORG_GRADLE_PROJECT_mavenCentralPassword`,
   `ORG_GRADLE_PROJECT_signingInMemoryKey`, `ORG_GRADLE_PROJECT_signingInMemoryKeyId` and
   `ORG_GRADLE_PROJECT_signingInMemoryKeyPassword` first:
   ```sh
   ./gradlew publishToMavenCentral
   ```
   Review and release the deployment at <https://central.sonatype.com/publishing/deployments>. Its validation reports
   missing signatures or license data. To release without the manual review, add
   `-PmavenCentralAutomaticPublishing=true`. Publish the compiler artifacts before the plugin, or together with it: the
   plugin resolves `dev.k2l:compiler:0.2.0` from Maven Central at build time.
5. **Publish the plugin** with `GRADLE_PUBLISH_KEY` and `GRADLE_PUBLISH_SECRET` exported:
   ```sh
   ./gradlew :gradle-plugin:publishPlugins --validate-only   # dry run against the portal
   ./gradlew :gradle-plugin:publishPlugins
   ```
   Gradle reviews the first version of the id `dev.k2l` before it becomes visible.
6. **Verify from outside the build.** In an empty directory, a project with `plugins { id("dev.k2l") version "0.2.0" }`,
   `repositories { mavenCentral() }` and a `src/main/kotlin/main.kt` must pass `gradle compileKotlinToLua`.
   `dev.k2l:compiler:0.2.0` must be listed at <https://central.sonatype.com/artifact/dev.k2l/compiler>; it can take a
   while to show up there.
7. **Open the next version.** Set `version=0.2.1-SNAPSHOT` (or `0.3.0-SNAPSHOT`) in `gradle.properties`, and commit.

Pre-releases need not go to Maven Central; a tag alone gives a GitHub Release.

## What gets published

| Artifact | Where |
|---|---|
| `k2l-<v>.zip`, `k2l-<v>.tar`, `SHA256SUMS` | GitHub Release |
| `dev.k2l:lua-api`, `dev.k2l:compiler` (+ `-runtime-libs.zip`), `dev.k2l:gradle-plugin`, the plugin marker `dev.k2l:dev.k2l.gradle.plugin` | Maven Central |
| plugin `dev.k2l` | Gradle Plugin Portal |

`dev.k2l:compiler` depends on JetBrains artifacts that are not on Maven Central (the Analysis API "for-ide" jars,
IntelliJ core). Its POM and Gradle metadata still list them, so a project using the compiler library directly needs the
two JetBrains repositories from `settings.gradle.kts`. The Gradle plugin avoids this by resolving the
`compiler-<v>-runtime-libs.zip` variant, a self-contained archive, so plugin users only need `mavenCentral()`.
