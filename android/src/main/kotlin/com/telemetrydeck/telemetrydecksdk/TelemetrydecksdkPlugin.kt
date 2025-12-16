package com.telemetrydeck.telemetrydecksdk

import android.app.Application
import android.content.Context
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
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** TelemetrydecksdkPlugin */
class TelemetrydecksdkPlugin : FlutterPlugin, MethodCallHandler {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private var applicationContext: Context? = null
    private val coroutineScope =
        CoroutineScope(Dispatchers.IO) // Coroutine scope for background tasks

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
                // this maps to the queue method which aligns with the behaviour of the iOS SDK
                nativeQueue(call, result)
            }

            "startDurationSignal" -> {
                // this maps to the queue method which aligns with the behaviour of the iOS SDK
                nativeStartDurationSignal(call, result)
            }

            "stopAndSendDurationSignal" -> {
                // this maps to the queue method which aligns with the behaviour of the iOS SDK
                nativeStopAndSendDurationSignal(call, result)
            }

            "generateNewSession" -> {
                TelemetryDeck.newSession()
                result.success(null)
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
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-signals/">Navigation Signals</a>
     * */
    private fun nativeNavigate(call: MethodCall, result: Result) {
        val sourcePath = call.argument<String>("sourcePath")
        val destinationPath = call.argument<String>("destinationPath")
        val clientUser = call.argument<String?>("clientUser")

        if (sourcePath == null || destinationPath == null) {
            result.error("INVALID_ARGUMENT", "sourcePath and destinationPath are required", null)
            return
        }

        coroutineScope.launch {
            TelemetryDeck.navigate(sourcePath, destinationPath, clientUser)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    /**
     * Send a signal that represents a navigation event with a destination and a default source.
     *
     * @see <a href="https://telemetrydeck.com/docs/articles/navigation-signals/">Navigation Signals</a>
     * */
    private fun nativeNavigateDestination(call: MethodCall, result: Result) {
        val destinationPath = call.argument<String>("destinationPath")
        val clientUser = call.argument<String?>("clientUser")

        if (destinationPath == null) {
            result.error("INVALID_ARGUMENT", "destinationPath is required", null)
            return
        }

        coroutineScope.launch {
            TelemetryDeck.navigate(destinationPath, clientUser)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeStop(result: Result) {
        TelemetryDeck.stop()
        result.success(null)
    }

    private fun nativeUpdateDefaultUser(
        call: MethodCall,
        result: Result
    ) {
        val user = call.arguments<String>()

        coroutineScope.launch {
            TelemetryDeck.newDefaultUser(user)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeQueue(
        call: MethodCall,
        result: Result
    ) {
        val signalType = call.argument<String>("signalType")
        if (signalType != null) {
            val clientUser = call.argument<String?>("clientUser")
            val additionalPayload = call.argument<Map<String, String>>("additionalPayload")
            val floatValue = call.argument<Double?>("floatValue")

            coroutineScope.launch {
                TelemetryDeck.signal(signalType, additionalPayload.orEmpty(), floatValue, clientUser)

                withContext(Dispatchers.Main) {
                    result.success(null)
                }
            }
        } else {
            result.error("INVALID_ARGUMENT", "signalType must be provided", null)
        }
    }

    private fun nativeStartDurationSignal(
        call: MethodCall,
        result: Result
    ) {
        val signalType = call.argument<String>("signalType")
        if (signalType != null) {
            val parameters = call.argument<Map<String, String>>("parameters")

            coroutineScope.launch {
                TelemetryDeck.startDurationSignal(signalType, parameters.orEmpty())

                withContext(Dispatchers.Main) {
                    result.success(null)
                }
            }
        } else {
            result.error("INVALID_ARGUMENT", "signalType must be provided", null)
        }
    }

    private fun nativeStopAndSendDurationSignal(
        call: MethodCall,
        result: Result
    ) {
        val signalType = call.argument<String>("signalType")
        if (signalType != null) {
            val parameters = call.argument<Map<String, String>>("parameters")

            coroutineScope.launch {
                TelemetryDeck.stopAndSendDurationSignal(signalType, parameters.orEmpty())

                withContext(Dispatchers.Main) {
                    result.success(null)
                }
            }
        } else {
            result.error("INVALID_ARGUMENT", "signalType must be provided", null)
        }
    }

    private fun nativeAcquiredUser(call: MethodCall, result: Result) {
        val channel = call.argument<String>("channel")
        if (channel == null) {
            result.error("INVALID_ARGUMENT", "channel is required", null)
            return
        }

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.acquiredUser(channel, params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeLeadStarted(call: MethodCall, result: Result) {
        val leadId = call.argument<String>("leadId")
        if (leadId == null) {
            result.error("INVALID_ARGUMENT", "leadId is required", null)
            return
        }

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.leadStarted(leadId, params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeLeadConverted(call: MethodCall, result: Result) {
        val leadId = call.argument<String>("leadId")
        if (leadId == null) {
            result.error("INVALID_ARGUMENT", "leadId is required", null)
            return
        }

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.leadConverted(leadId, params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeOnboardingCompleted(call: MethodCall, result: Result) {
        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.onboardingCompleted(params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeCoreFeatureUsed(call: MethodCall, result: Result) {
        val featureName = call.argument<String>("featureName")
        if (featureName == null) {
            result.error("INVALID_ARGUMENT", "featureName is required", null)
            return
        }

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.coreFeatureUsed(featureName, params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativePaywallShown(call: MethodCall, result: Result) {
        val reason = call.argument<String>("reason")
        if (reason == null) {
            result.error("INVALID_ARGUMENT", "reason is required", null)
            return
        }

        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.paywallShown(reason, params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativePurchaseCompleted(call: MethodCall, result: Result) {
        val eventString = call.argument<String>("event")
        val countryCode = call.argument<String>("countryCode")
        val productID = call.argument<String>("productID")
        val purchaseTypeString = call.argument<String>("purchaseType")
        val priceAmountMicros = call.argument<Long>("priceAmountMicros")
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

        coroutineScope.launch {
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
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeReferralSent(call: MethodCall, result: Result) {
        val receiversCount = call.argument<Int>("receiversCount")
        if (receiversCount == null) {
            result.error("INVALID_ARGUMENT", "receiversCount is required", null)
            return
        }

        val kind = call.argument<String?>("kind")
        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.referralSent(receiversCount, kind, params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeUserRatingSubmitted(call: MethodCall, result: Result) {
        val rating = call.argument<Int>("rating")
        if (rating == null) {
            result.error("INVALID_ARGUMENT", "rating is required", null)
            return
        }

        val comment = call.argument<String?>("comment")
        val params = call.argument<Map<String, String>>("params")
        val customUserID = call.argument<String?>("customUserID")

        coroutineScope.launch {
            TelemetryDeck.userRatingSubmitted(rating, comment, params.orEmpty(), customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeErrorOccurred(call: MethodCall, result: Result) {
        val id = call.argument<String>("id")
        if (id == null) {
            result.error("INVALID_ARGUMENT", "id is required", null)
            return
        }

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

        coroutineScope.launch {
            TelemetryDeck.errorOccurred(id, category, message, parameters.orEmpty(), floatValue, customUserID)
            withContext(Dispatchers.Main) {
                result.success(null)
            }
        }
    }

    private fun nativeInitialize(call: MethodCall, result: Result) {
        val arguments = call.arguments as? Map<*, *> // Cast to a Map
        if (arguments != null) {
            // Extract values using the expected keys
            // we extract the required appID parameter
            val appID = arguments["appID"] as? String
            if (appID == null) {
                result.error("INVALID_ARGUMENT", "Expected value appID is not provided.", null)
                return
            }

            // additional optional parameters
            val apiBaseURL = arguments["apiBaseURL"] as? String?
            val defaultUser = arguments["defaultUser"] as? String?
            val debug = arguments["debug"] as? Boolean
            val testMode = arguments["testMode"] as? Boolean
            val salt = arguments["salt"] as? String?
            val defaultSignalPrefix = arguments["defaultSignalPrefix"] as? String?
            val defaultParameterPrefix = arguments["defaultParameterPrefix"] as? String?
            val defaultParameters = arguments["defaultParameters"] as? Map<String, String>?
            val namespace = arguments["namespace"] as? String?


            // Initialize the client
            // Do not activate the lifecycle provider
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
                builder.addProvider(DefaultParameterProvider(defaultParameters))
            }

            val application = applicationContext as Application
            TelemetryDeck.start(application, builder)
            result.success(null)
        } else {
            result.error("INVALID_ARGUMENT", "Arguments are not a map", null)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
