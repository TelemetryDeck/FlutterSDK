package com.telemetrydeck.telemetrydecksdk

import android.app.Application
import android.content.Context
import androidx.annotation.NonNull
import com.telemetrydeck.sdk.TelemetryManager

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** TelemetrydecksdkPlugin */
class TelemetrydecksdkPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private var applicationContext: Context? = null

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "telemetrydecksdk")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "initialize") {
      val arguments = call.arguments as? Map<*, *> // Cast to a Map
      if (arguments != null) {
        // Extract values using the expected keys
        val appID = arguments["appID"] as? String
        val apiBaseURL = arguments["apiBaseURL"] as? String

        if (appID == null || apiBaseURL == null) {
          result.error("INVALID_ARGUMENT", "Expected values appID and apiBaseURL were not found.", null)
          return
        }

        val defaultUser = arguments["defaultUser"] as? String?
        val debug = arguments["debug"] as? Boolean
        val sendNewSessionBeganSignal = arguments["sendNewSessionBeganSignal"] as? Boolean
        val testMode = arguments["testMode"] as? Boolean

        // initialize the client
        val builder = TelemetryManager.Builder()
          .appID(appID)
          .baseURL(apiBaseURL)

        defaultUser?.let {
          builder.defaultUser(it)
        }
        debug?.let {
          builder.showDebugLogs(it)
        }
        sendNewSessionBeganSignal?.let {
          builder.sendNewSessionBeganSignal(it)
        }
        testMode?.let {
          builder.testMode(it)
        }

        val application = applicationContext as Application
        TelemetryManager.start(application, builder)

      } else {
        result.error("INVALID_ARGUMENT", "Arguments are not a map", null)
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
