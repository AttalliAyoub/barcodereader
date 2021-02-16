package com.ayoub.barcodereader

import android.graphics.BitmapFactory
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

import com.google.zxing.BinaryBitmap
import com.google.zxing.MultiFormatReader
import com.google.zxing.NotFoundException
import com.google.zxing.RGBLuminanceSource
import com.google.zxing.common.HybridBinarizer

/** BarcodereaderPlugin */
class BarcodereaderPlugin: FlutterPlugin, MethodCallHandler {

  private lateinit var channel : MethodChannel
  private lateinit var reader : MultiFormatReader

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ayoub.barcodereader")
    channel.setMethodCallHandler(this)
    reader = MultiFormatReader()
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when(call.method) {
      "barcode" -> {
        val path = call.argument<String>("path")!!
        val image = BitmapFactory.decodeFile(path)
        val pixels = IntArray(image.width * image.height)
        image.getPixels(pixels, 0, image.width, 0, 0, image.width, image.height)
        val source = RGBLuminanceSource(image.width, image.height, pixels)
        val bitmap = BinaryBitmap(HybridBinarizer(source))
        try {
          val r = reader.decode(bitmap)
          if (r != null) {
            val map = HashMap<String, Any?>()
            map["text"] = r.text
            val resultPoints = r.resultPoints?.map { p ->
              hashMapOf<String, Double>("x" to p.x.toDouble(), "y" to p.y.toDouble())
            }
            map["resultPoints"] = resultPoints
            map["format"] = r.barcodeFormat.toString()
            val resultMetadata = HashMap<String, Any>()
            if (r.resultMetadata != null) {
              for (v in r.resultMetadata) {
                resultMetadata["v.key.toString()"] = v.value
              }
              map["resultMetadata"] = resultMetadata
            }
            map["timestamp"] = r.timestamp
            result.success(map)
          } else result.success(null)
        } catch (e: NotFoundException) {
          result.success(null)
        } finally {
          reader.reset()
        }
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
