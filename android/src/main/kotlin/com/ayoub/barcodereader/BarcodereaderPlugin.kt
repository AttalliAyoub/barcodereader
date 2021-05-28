package com.ayoub.barcodereader

import android.util.Log
import androidx.annotation.NonNull
import com.yanzhenjie.zbar.ImageScanner
import com.yanzhenjie.zbar.Image
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlin.math.absoluteValue


/** BarcodereaderPlugin */
class BarcodereaderPlugin: FlutterPlugin , MethodCallHandler {

  private lateinit var channel : MethodChannel
  private lateinit var imageScanner : ImageScanner


  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ayoub.barcodereader")
    channel.setMethodCallHandler(this)
    imageScanner = ImageScanner()
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method) {
      "barcode" -> {
        val height = call.argument<Int>("height")!!
        val width = call.argument<Int>("width")!!
        val bytes = call.argument<ByteArray>("bytes")!!
        val image = Image(width,height, "Y800").also { i -> i.data = bytes }
        try {
          val r = imageScanner.scanImage(image)
          if (r != 0) {
            val results = imageScanner.results.map { result -> mapOf<String, Any>(
              "text" to result.data,
              "format" to result.type.absoluteValue,
              "bounds" to result.bounds.asList(),
              "count" to result.count.absoluteValue,
              "dataBytes" to result.dataBytes.asList(),
              "orientation" to result.orientation.absoluteValue,
              "quality" to result.quality.absoluteValue
            ) }
            result.success(results)
          } else result.success(null)
        } catch(e: Exception) {
          result.error(e.cause.toString(), e.message, e)
        } finally {
          // imageScanner.destroy()
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
