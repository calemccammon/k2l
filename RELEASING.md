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

## Cutting a release (for example 0.2.0)

1. Set `version=0.2.0` in `gradle.properties`, move the `[Unreleased]` entries of `CHANGELOG.md` under `## [0.2.0]`, and
   commit ("Release 0.2.0") on `main` after CI is green.
2. Check locally:
   ```sh
   export JAVA_HOME=...   # JDK 21
   ./gradlew check :compiler:distZip publishToMavenLocal
   ```
3. Tag and push the tag. This triggers `.github/workflows/release.yml`, which runs `./gradlew check`, builds
   `k2l-0.2.0.zip`/`.tar`, writes `SHA256SUMS`, smoke-tests the zip and creates the GitHub Release (a tag with a
   suffix such as `v0.2.0-rc1` or `v0.2.0-alpha1` is marked as a pre-release):
   ```sh
   git tag v0.2.0 && git push origin v0.2.0
   ```
4. Publish to Maven Central, with the credentials above exported (the tag must be checked out, or pass
   `-Pversion=0.2.0`). Review and release the deployment at <https://central.sonatype.com/publishing/deployments>, or
   add `-PmavenCentralAutomaticPublishing=true` to release without the manual review:
   ```sh
   ./gradlew publishToMavenCentral
   ```
   Publish the compiler artifacts before (or together with) the plugin: the plugin resolves
   `dev.k2l:compiler:0.2.0` from Maven Central at build time.
5. Publish the plugin: `./gradlew :gradle-plugin:publishPlugins`
   (add `--validate-only` for a dry run).
6. Bump `version` in `gradle.properties` to the next `-SNAPSHOT` and commit.

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
