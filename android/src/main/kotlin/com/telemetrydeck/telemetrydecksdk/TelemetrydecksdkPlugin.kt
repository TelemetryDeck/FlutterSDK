package com.telemetrydeck.telemetrydecksdk

import android.app.Application
import android.content.Context
import com.telemetrydeck.sdk.TelemetryManager

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
class TelemetrydecksdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var applicationContext: Context? = null
  private val coroutineScope = CoroutineScope(Dispatchers.IO) // Coroutine scope for background tasks

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "telemetrydecksdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "start") {
      nativeInitialize(call, result)
    } else if (call.method == "send") {
      // this maps to the queue method which aligns with the behaviour of the iOS SDK
      nativeQueue(call, result)
    } else if (call.method == "generateNewSession") {
      TelemetryManager.newSession()
      result.success(null)
    } else if (call.method == "updateDefaultUser") {
      nativeUpdateDefaultUser(call, result)
    } else {
      result.notImplemented()
    }
  }

  private  fun nativeUpdateDefaultUser(call: MethodCall,
                                       result: Result) {
    val user = call.arguments<String>()

    coroutineScope.launch {
      TelemetryManager.newDefaultUser(user)
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
        TelemetryManager.queue(signalType, clientUser, additionalPayload.orEmpty())

        withContext(Dispatchers.Main) {
          result.success(null)
        }
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


      // initialize the client
      val builder = TelemetryManager.Builder()
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

      val application = applicationContext as Application
      TelemetryManager.start(application, builder)
      result.success(null)
    } else {
      result.error("INVALID_ARGUMENT", "Arguments are not a map", null)
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
