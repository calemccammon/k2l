package dev.k2l.gradle

import org.gradle.api.attributes.AttributeCompatibilityRule
import org.gradle.api.attributes.AttributeDisambiguationRule
import org.gradle.api.attributes.CompatibilityCheckDetails
import org.gradle.api.attributes.MultipleCandidatesDetails
import org.gradle.api.attributes.Usage

/** The published compiler offers its runtime classpath as a zip, under a usage of its own; accept it for the plain request. */
class ZipUsageCompatibility : AttributeCompatibilityRule<Usage> {
    override fun execute(details: CompatibilityCheckDetails<Usage>) {
        val provided = details.producerValue?.name
        if (details.consumerValue?.name == K2lPlugin.COMPILER_USAGE && provided == K2lPlugin.COMPILER_ZIP_USAGE) {
            details.compatible()
        }
    }
}

/** When a compiler offers both the directory (composite builds) and the zip, take the directory. */
class PreferDirectoryUsage : AttributeDisambiguationRule<Usage> {
    override fun execute(details: MultipleCandidatesDetails<Usage>) {
        if (details.consumerValue?.name != K2lPlugin.COMPILER_USAGE) return
        details.candidateValues.firstOrNull { it.name == K2lPlugin.COMPILER_USAGE }?.let { details.closestMatch(it) }
    }
}
