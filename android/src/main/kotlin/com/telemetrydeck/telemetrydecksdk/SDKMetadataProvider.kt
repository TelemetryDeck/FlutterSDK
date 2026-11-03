package com.telemetrydeck.telemetrydecksdk

import android.content.Context
import com.telemetrydeck.sdk.TelemetryDeckProvider
import com.telemetrydeck.sdk.TelemetryDeckSignalProcessor

/**
 * Adds the Flutter SDK metadata to every signal, replacing the native SDK identification.
 *
 * Must be registered after the native providers so its values take precedence.
 */
internal class SDKMetadataProvider(private val parameters: Map<String, String>) : TelemetryDeckProvider {
    override fun register(ctx: Context?, client: TelemetryDeckSignalProcessor) {}

    override fun stop() {}

    override fun enrich(
        signalType: String,
        clientUser: String?,
        additionalPayload: Map<String, String>
    ): Map<String, String> = additionalPayload + parameters

    companion object {
        const val PARAMETER_PREFIX = "TelemetryDeck.SDK."
    }
}
