package dev.nukeolay.display_metrics_android

import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Build
import android.util.DisplayMetrics
import android.view.Display
import android.view.WindowManager
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DisplayMetricsAndroidPlugin */
class DisplayMetricsAndroidPlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel

  private lateinit var context: Context

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "display_metrics")
    channel.setMethodCallHandler(this)
  }

  private fun getSize(): Pair<Double, Double> {
    val primary = getDisplays().firstOrNull { it["isPrimary"] == true } ?: return 0.0 to 0.0
    val size = primary["size"] as Map<*, *>
    val width = (size["width"] as Number).toDouble()
    val height = (size["height"] as Number).toDouble()
    return width to height
  }

  private fun getResolution(): Pair<Int, Int> {
    val primary = getDisplays().firstOrNull { it["isPrimary"] == true } ?: return 0 to 0
    val resolution = primary["resolution"] as Map<*, *>
    val width = (resolution["width"] as Number).toInt()
    val height = (resolution["height"] as Number).toInt()
    return width to height
  }

  private fun getDisplays(): List<Map<String, Any>> {
    val displayManager = context.getSystemService(Context.DISPLAY_SERVICE) as DisplayManager
    val displays = displayManager.displays
    val displayList = mutableListOf<Map<String, Any>>()

    for (display in displays) {
      val metrics = DisplayMetrics()
      display.getRealMetrics(metrics)

      val widthPixels = metrics.widthPixels
      val heightPixels = metrics.heightPixels
      val xDpi = metrics.xdpi
      val yDpi = metrics.ydpi

      if (xDpi == 0f || yDpi == 0f) continue

      val widthInches = widthPixels / xDpi
      val heightInches = heightPixels / yDpi

      val sizeMap = mapOf(
       "width" to widthInches,
       "height" to heightInches
      )

      val resolutionMap = mapOf(
        "width" to widthPixels,
        "height" to heightPixels
      )

      val displayMap = mutableMapOf<String, Any>(
        "size" to sizeMap,
        "resolution" to resolutionMap,
        "isPrimary" to (display.displayId == Display.DEFAULT_DISPLAY)
      )

    displayList.add(displayMap)
  }

  return displayList
}

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      "getSize" -> {
        val size = getSize()
        result.success(mapOf("width" to size.first, "height" to size.second))
      }

      "getResolution" -> {
        val resolution = getResolution()
        result.success(mapOf("width" to resolution.first, "height" to resolution.second))
      }

      "getDisplays" -> {
        val displays = getDisplays()
        result.success(displays)
      }

      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
