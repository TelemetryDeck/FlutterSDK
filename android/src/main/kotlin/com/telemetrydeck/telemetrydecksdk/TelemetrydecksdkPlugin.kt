package com.telemetrydeck.telemetrydecksdk

import android.app.Application
import android.content.Context
import com.telemetrydeck.sdk.TelemetryDeck
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

            coroutineScope.launch {
                TelemetryDeck.signal(signalType, clientUser, additionalPayload.orEmpty())

                withContext(Dispatchers.Main) {
                    result.success(null)
                }
            }
        } else {
            result.error("INVALID_ARGUMENT", "signalType must be provided", null)
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
