package com.telemetrydeck.telemetrydecksdk

import android.app.Application
import android.content.Context
import android.util.Log
import com.telemetrydeck.sdk.PurchaseEvent
import com.telemetrydeck.sdk.PurchaseType
import com.telemetrydeck.sdk.TelemetryDeck
import com.telemetrydeck.sdk.params.ErrorCategory
import com.telemetrydeck.sdk.providers.DefaultParameterProvider
import com.telemetrydeck.sdk.providers.DefaultPrefixProvider
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineExceptionHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

private const val LOG_TAG = "TelemetryDeck"

/** TelemetrydecksdkPlugin */
class TelemetrydecksdkPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    internal var applicationContext: Context? = null
    private val coroutineScope = CoroutineScope(
        SupervisorJob() + Dispatchers.IO + CoroutineExceptionHandler { _, e ->
            Log.e(LOG_TAG, "Unhandled error in TelemetryDeck plugin", e)
        }
    )

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        applicationContext = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "telemetrydecksdk")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "start" -> {
                nativeInitialize(call, result)
            }

            "stop" -> {
                nativeStop(result)
            }

            "send" -> {
                nativeSignal(call, result)
            }

            "startDurationSignal" -> {
                nativeStartDurationSignal(call, result)
            }

            "stopAndSendDurationSignal" -> {
                nativeStopAndSendDurationSignal(call, result)
            }

            "generateNewSession" -> {
                runGuarded(result) {
                    TelemetryDeck.newSession()
                }
            }

            "updateDefaultUser" -> {
                nativeUpdateDefaultUser(call, result)
            }

            "navigate" -> {
                nativeNavigate(call, result)
            }

            "navigateToDestination" -> {
                nativeNavigateDestination(call, result)
            }

            "acquiredUser" -> {
                nativeAcquiredUser(call, result)
            }

            "leadStarted" -> {
                nativeLeadStarted(call, result)
            }

            "leadConverted" -> {
                nativeLeadConverted(call, result)
            }

            "onboardingCompleted" -> {
                nativeOnboardingCompleted(call, result)
            }

            "coreFeatureUsed" -> {
                nativeCoreFeatureUsed(call, result)
            }

            "paywallShown" -> {
                nativePaywallShown(call, result)
            }

            "purchaseCompleted" -> {
                nativePurchaseCompleted(call, result)
            }

            "referralSent" -> {
                nativeReferralSent(call, result)
            }

            "userRatingSubmitted" -> {
                nativeUserRatingSubmitted(call, result)
            }

            "errorOccurred" -> {
                nativeErrorOccurred(call, result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    /**
     * Send a signal that represents a navigation event with a source and a destination.
     *
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-events/">Navigation Signals</a>
     * */
    private fun nativeNavigate(call: MethodCall, result: Result) {
        val sourcePath = call.argument<String>("sourcePath")
        val destinationPath = call.argument<String>("destinationPath")
        val clientUser = call.argument<String?>("clientUser")

        if (sourcePath == null || destinationPath == null) {
            result.error("INVALID_ARGUMENT", "sourcePath and destinationPath are required", null)
            return
        }

        runInBackground(result) {
            TelemetryDeck.navigate(sourcePath, destinationPath, clientUser)
        }
    }

    /**
     * Send a signal that represents a navigation event with a destination and a default source.
     *
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-events/">Navigation Signals</a>
     * */
    private fun nativeNavigateDestination(call: MethodCall, result: Result) {
        val destinationPath = call.requiredArgument<String>("destinationPath", result) ?: return
        val clientUser = call.argument<String?>("clientUser")

        runInBackground(result) {
            TelemetryDeck.navigate(destinationPath, clientUser)
        }
    }

    private fun nativeStop(result: Result) {
        runGuarded(result) {
            TelemetryDeck.stop()
        }
    }

    private fun nativeUpdateDefaultUser(
        call: MethodCall,
        result: Result
    ) {
        val user = call.arguments<String>()

        runInBackground(result) {
            TelemetryDeck.newDefaultUser(user)
        }
    }

    private fun nativeSignal(
        call: MethodCall,
        result: Result
    ) {
        val signalType = call.requiredArgument<String>("signalType", result) ?: return
        val clientUser = call.argument<String?>("clientUser")
        val additionalPayload = call.argument<Map<String, String>>("additionalPayload")
        val floatValue = call.argument<Double?>("floatValue")

        runInBackground(result) {
            TelemetryDeck.signal(signalType, additionalPayload.orEmpty(), floatValue, clientUser)
        }
    }

    private fun nativeStartDurationSignal(
        call: MethodCall,
        result: Result
    ) {
        val signalType = call.requiredArgument<String>("signalType", result) ?: return
        val parameters = call.argument<Map<String, String>>("parameters")

        runInBackground(result) {
            TelemetryDeck.startDurationSignal(signalType, parameters.orEmpty())
        }
    }

    private fun nativeStopAndSendDurationSignal(
        call: MethodCall,
        result: Result
    ) {
        val signalType = call.requiredArgument<String>("signalType", result) ?: return
        val parameters = call.argument<Map<String, String>>("parameters")

        runInBackground(result) {
            TelemetryDeck.stopAndSendDurationSignal(signalType, parameters.orEmpty())
        }
    }

    private fun nativeAcquiredUser(call: MethodCall, result: Result) {
        val channel = call.requiredArgument<String>("channel", result) ?: return

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.acquiredUser(channel, params.orEmpty(), customUserID)
        }
    }

    private fun nativeLeadStarted(call: MethodCall, result: Result) {
        val leadId = call.requiredArgument<String>("leadId", result) ?: return

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.leadStarted(leadId, params.orEmpty(), customUserID)
        }
    }

    private fun nativeLeadConverted(call: MethodCall, result: Result) {
        val leadId = call.requiredArgument<String>("leadId", result) ?: return

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.leadConverted(leadId, params.orEmpty(), customUserID)
        }
    }

    private fun nativeOnboardingCompleted(call: MethodCall, result: Result) {
        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.onboardingCompleted(params.orEmpty(), customUserID)
        }
    }

    private fun nativeCoreFeatureUsed(call: MethodCall, result: Result) {
        val featureName = call.requiredArgument<String>("featureName", result) ?: return

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.coreFeatureUsed(featureName, params.orEmpty(), customUserID)
        }
    }

    private fun nativePaywallShown(call: MethodCall, result: Result) {
        val reason = call.requiredArgument<String>("reason", result) ?: return

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.paywallShown(reason, params.orEmpty(), customUserID)
        }
    }

    private fun nativePurchaseCompleted(call: MethodCall, result: Result) {
        val eventString = call.argument<String>("event")
        val countryCode = call.argument<String>("countryCode")
        val productID = call.argument<String>("productID")
        val purchaseTypeString = call.argument<String>("purchaseType")
        val priceAmountMicros = call.argument<Number>("priceAmountMicros")?.toLong()
        val currencyCode = call.argument<String>("currencyCode")

        if (eventString == null || countryCode == null || productID == null ||
            purchaseTypeString == null || priceAmountMicros == null || currencyCode == null) {
            result.error("INVALID_ARGUMENT", "event, countryCode, productID, purchaseType, priceAmountMicros, and currencyCode are required", null)
            return
        }

        val event = when (eventString) {
            "purchaseCompleted" -> PurchaseEvent.PAID_PURCHASE
            "freeTrialStarted" -> PurchaseEvent.STARTED_FREE_TRIAL
            "convertedFromFreeTrial" -> PurchaseEvent.CONVERTED_FROM_TRIAL
            else -> {
                result.error("INVALID_ARGUMENT", "Invalid purchase event: $eventString", null)
                return
            }
        }

        val purchaseType = when (purchaseTypeString) {
            "subscription" -> PurchaseType.SUBSCRIPTION
            "oneTimePurchase" -> PurchaseType.ONE_TIME_PURCHASE
            else -> {
                result.error("INVALID_ARGUMENT", "Invalid purchase type: $purchaseTypeString", null)
                return
            }
        }

        val offerID = call.argument<String?>("offerID")
        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.purchaseCompleted(
                event,
                countryCode,
                productID,
                purchaseType,
                priceAmountMicros,
                currencyCode,
                offerID,
                params.orEmpty(),
                customUserID
            )
        }
    }

    private fun nativeReferralSent(call: MethodCall, result: Result) {
        val receiversCount = call.requiredArgument<Int>("receiversCount", result) ?: return

        val kind = call.argument<String?>("kind")
        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.referralSent(receiversCount, kind, params.orEmpty(), customUserID)
        }
    }

    private fun nativeUserRatingSubmitted(call: MethodCall, result: Result) {
        val rating = call.requiredArgument<Int>("rating", result) ?: return

        val comment = call.argument<String?>("comment")
        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.userRatingSubmitted(rating, comment, params.orEmpty(), customUserID)
        }
    }

    private fun nativeErrorOccurred(call: MethodCall, result: Result) {
        val id = call.requiredArgument<String>("id", result) ?: return

        val categoryString = call.argument<String?>("category")
        val category = when (categoryString) {
            "thrownException" -> ErrorCategory.ThrownException
            "userInput" -> ErrorCategory.UserInput
            "appState" -> ErrorCategory.AppState
            else -> null
        }

        val message = call.argument<String?>("message")
        val parameters = call.argument<Map<String, String>>("parameters")
        val floatValue = call.argument<Double?>("floatValue")
        val customUserID = call.argument<String?>("customUserID")

        runInBackground(result) {
            TelemetryDeck.errorOccurred(id, category, message, parameters.orEmpty(), floatValue, customUserID)
        }
    }

    private fun nativeInitialize(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *>
        if (arguments != null) {
            val appID = arguments["appID"] as? String
            if (appID == null) {
                result.error("INVALID_ARGUMENT", "Expected value appID is not provided.", null)
                return
            }

            val apiBaseURL = arguments["apiBaseURL"] as? String?
            val defaultUser = arguments["defaultUser"] as? String?
            val debug = arguments["debug"] as? Boolean
            val testMode = arguments["testMode"] as? Boolean
            val salt = arguments["salt"] as? String?
            val defaultSignalPrefix = arguments["defaultSignalPrefix"] as? String?
            val defaultParameterPrefix = arguments["defaultParameterPrefix"] as? String?
            val defaultParameters = arguments["defaultParameters"] as? Map<String, String>?
            val namespace = arguments["namespace"] as? String?

            val builder = TelemetryDeck.Builder()
                .appID(appID)

            apiBaseURL?.let {
                builder.baseURL(it)
            }
            defaultUser?.let {
                builder.defaultUser(it)
            }
            debug?.let {
                builder.showDebugLogs(it)
            }
            testMode?.let {
                builder.testMode(it)
            }
            salt?.let {
                builder.salt(it)
            }
            namespace?.let {
                builder.namespace(it)
            }

            if (defaultSignalPrefix != null || defaultParameterPrefix != null) {
                builder.addProvider(DefaultPrefixProvider(defaultSignalPrefix, defaultParameterPrefix))
            }

            if (defaultParameters != null) {
                val isSDKMetadata = { key: String -> key.startsWith(SDKMetadataProvider.PARAMETER_PREFIX) }
                builder.addProvider(DefaultParameterProvider(defaultParameters.filterKeys { !isSDKMetadata(it) }))
                builder.addProvider(SDKMetadataProvider(defaultParameters.filterKeys(isSDKMetadata)))
            }

            runGuarded(result) {
                TelemetryDeck.start(applicationContext as Application, builder)
            }
        } else {
            result.error("INVALID_ARGUMENT", "Arguments are not a map", null)
        }
    }

    private fun runGuarded(result: Result, block: () -> Unit) {
        reply(result, captureFailure(block))
    }

    private fun runInBackground(result: Result, block: () -> Unit) {
        coroutineScope.launch {
            val failure = captureFailure(block)
            withContext(Dispatchers.Main) {
                reply(result, failure)
            }
        }
    }

    private fun <T> MethodCall.requiredArgument(key: String, result: Result): T? =
        argument<T>(key) ?: run {
            result.error("INVALID_ARGUMENT", "$key is required", null)
            null
        }

    private fun captureFailure(block: () -> Unit): Throwable? =
        try {
            block()
            null
        } catch (e: CancellationException) {
            throw e
        } catch (e: Throwable) {
            Log.e(LOG_TAG, "TelemetryDeck call failed", e)
            e
        }

    private fun reply(result: Result, failure: Throwable?) {
        if (failure == null) {
            result.success(null)
        } else {
            result.error("TELEMETRY_ERROR", failure.message ?: failure.toString(), null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
