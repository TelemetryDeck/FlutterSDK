package com.telemetrydeck.telemetrydecksdk

import androidx.arch.core.executor.testing.InstantTaskExecutorRule
import com.telemetrydeck.sdk.Signal
import com.telemetrydeck.sdk.TelemetryDeck
import com.telemetrydeck.sdk.TelemetryManagerConfiguration
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.UnconfinedTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import kotlinx.serialization.json.jsonPrimitive
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertTrue

@OptIn(ExperimentalCoroutinesApi::class)
class TelemetrydecksdkPluginTest {

    @get:Rule
    val instantTaskExecutorRule = InstantTaskExecutorRule()

    @Before
    fun setUpMainDispatcher() {
        Dispatchers.setMain(UnconfinedTestDispatcher())
    }

    @After
    fun tearDownMainDispatcher() {
        Dispatchers.resetMain()
    }

    private class CapturingResult : MethodChannel.Result {
        var successCalled = false
        var errorCode: String? = null
        var notImplementedCalled = false
        val latch = CountDownLatch(1)

        override fun success(result: Any?) {
            successCalled = true
            latch.countDown()
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            this.errorCode = errorCode
            latch.countDown()
        }

        override fun notImplemented() {
            notImplementedCalled = true
            latch.countDown()
        }
    }

    @Test
    fun testUnknownMethodIsNotImplemented() {
        val plugin = TelemetrydecksdkPlugin()
        val result = CapturingResult()

        plugin.onMethodCall(MethodCall("unknownMethod", null), result)

        assertTrue(result.notImplementedCalled)
    }

    @Test
    fun testStartWithoutAppIdReturnsInvalidArgumentError() {
        val plugin = TelemetrydecksdkPlugin()
        val result = CapturingResult()

        plugin.onMethodCall(MethodCall("start", mapOf("debug" to true)), result)

        assertEquals("INVALID_ARGUMENT", result.errorCode)
    }

    @Test
    fun testNavigateDeliversResultThroughCoroutine() {
        val plugin = TelemetrydecksdkPlugin()
        val result = CapturingResult()
        val args = mapOf("sourcePath" to "/home", "destinationPath" to "/profile")

        plugin.onMethodCall(MethodCall("navigate", args), result)

        assertTrue(result.latch.await(5, TimeUnit.SECONDS))
        assertTrue(result.successCalled)
    }

    @Test
    fun testSignalBasicProperties() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.signal("TestSignal", mapOf("key1" to "value1"))

        val signals = manager.cache?.empty()
        assertNotNull(signals)
        assertTrue(signals.isNotEmpty())

        val signal = signals.first()
        assertEquals("TestSignal", signal.type)
    }

    @Test
    fun testSignalWithFloatValue() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.signal("MetricSignal", emptyMap(), 42.5)

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("MetricSignal", signal.type)
        assertEquals(42.5, signal.floatValue)
    }

    @Test
    fun testSignalWithCustomUser() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.signal("UserSignal", emptyMap(), null, "test-user-123")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("UserSignal", signal.type)
        assertNotNull(signal.clientUser)
    }

    @Test
    fun testMultipleSignalsInCache() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.signal("Signal1", emptyMap())
        manager.signal("Signal2", emptyMap())
        manager.signal("Signal3", emptyMap())

        val signals = manager.cache?.empty()
        assertNotNull(signals)
        assertEquals(3, signals.size)

        val types = signals.map { it.type }
        assertTrue(types.contains("Signal1"))
        assertTrue(types.contains("Signal2"))
        assertTrue(types.contains("Signal3"))
    }

    @Test
    fun testCacheClearedAfterEmpty() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.signal("TestSignal1", mapOf("key1" to "value1"))

        val firstRead = manager.cache?.empty()
        assertNotNull(firstRead)
        assertTrue(firstRead.isNotEmpty())

        val secondRead = manager.cache?.empty()
        assertNotNull(secondRead)
        assertTrue(secondRead.isEmpty())
    }

    @Test
    fun testSignalPayloadFormat() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.signal("TestSignal", mapOf("customParam" to "customValue"))

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)

        assertEquals("customValue", signal.payload["customParam"]?.jsonPrimitive?.content)
    }

    @Test
    fun testNavigationSignalStructure() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.navigate("/home", "/profile", "nav-user-789")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("TelemetryDeck.Navigation.pathChanged", signal.type)

        assertEquals("/home", signal.payload["TelemetryDeck.Navigation.sourcePath"]?.jsonPrimitive?.content)
        assertEquals("/profile", signal.payload["TelemetryDeck.Navigation.destinationPath"]?.jsonPrimitive?.content)
    }

    @Test
    fun testSignalWithComplexPayload() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        val complexPayload = mapOf(
            "feature" to "export",
            "format" to "pdf",
            "pages" to "10",
            "quality" to "high"
        )

        manager.signal("Export.Completed", complexPayload, 123.45, "user-456")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("Export.Completed", signal.type)
        assertEquals(123.45, signal.floatValue)

        assertEquals("export", signal.payload["feature"]?.jsonPrimitive?.content)
        assertEquals("pdf", signal.payload["format"]?.jsonPrimitive?.content)
        assertEquals("10", signal.payload["pages"]?.jsonPrimitive?.content)
        assertEquals("high", signal.payload["quality"]?.jsonPrimitive?.content)
    }

    @Test
    fun testTestModeEnabled() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val manager = TelemetryDeck.Builder()
            .appID(appID)
            .testMode(true)
            .build(null)

        manager.signal("TestSignal", emptyMap())

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("true", signal.isTestMode)
    }

    @Test
    fun testTestModeDisabled() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val manager = TelemetryDeck.Builder()
            .appID(appID)
            .testMode(false)
            .build(null)

        manager.signal("TestSignal", emptyMap())

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("false", signal.isTestMode)
    }

    @Test
    fun testCustomSaltApplied() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val config = TelemetryManagerConfiguration(appID)
        config.salt = "my salt"
        val manager = TelemetryDeck.Builder().configuration(config).build(null)

        manager.signal("TestSignal", "clientUser", emptyMap())

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("9a68a3790deb1db66f80855b8e7c5a97df8002ef90d3039f9e16c94cfbd11d99", signal.clientUser)
    }

    @Test
    fun testAcquiredUserSignal() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val manager = TelemetryDeck.Builder().appID(appID).build(null)

        manager.acquiredUser("channel 1")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("TelemetryDeck.Acquisition.userAcquired", signal.type)
        assertEquals("channel 1", signal.payload["TelemetryDeck.Acquisition.channel"]?.jsonPrimitive?.content)
    }

    @Test
    fun testLeadStartedSignal() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val manager = TelemetryDeck.Builder().appID(appID).build(null)

        manager.leadStarted("lead 1")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("TelemetryDeck.Acquisition.leadStarted", signal.type)
        assertEquals("lead 1", signal.payload["TelemetryDeck.Acquisition.leadID"]?.jsonPrimitive?.content)
    }

    @Test
    fun testLeadConvertedSignal() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val manager = TelemetryDeck.Builder().appID(appID).build(null)

        manager.leadConverted("lead 1")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("TelemetryDeck.Acquisition.leadConverted", signal.type)
        assertEquals("lead 1", signal.payload["TelemetryDeck.Acquisition.leadID"]?.jsonPrimitive?.content)
    }

    @Test
    fun testCoreFeatureUsedSignal() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val manager = TelemetryDeck.Builder().appID(appID).build(null)

        manager.coreFeatureUsed("feature 1")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("TelemetryDeck.Activation.coreFeatureUsed", signal.type)
        assertEquals("feature 1", signal.payload["TelemetryDeck.Activation.featureName"]?.jsonPrimitive?.content)
    }

    @Test
    fun testPaywallShownSignal() {
        val appID = "32CB6574-6732-4238-879F-582FEBEB6536"
        val manager = TelemetryDeck.Builder().appID(appID).build(null)

        manager.paywallShown("trial_ended")

        val signal = manager.cache?.empty()?.first()
        assertNotNull(signal)
        assertEquals("TelemetryDeck.Revenue.paywallShown", signal.type)
        assertEquals("trial_ended", signal.payload["TelemetryDeck.Revenue.paywallShowReason"]?.jsonPrimitive?.content)
    }
}
