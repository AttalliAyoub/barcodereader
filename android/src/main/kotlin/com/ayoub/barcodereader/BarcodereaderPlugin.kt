package com.ayoub.barcodereader

import android.graphics.ImageFormat
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


import com.google.zxing.BinaryBitmap
import com.google.zxing.MultiFormatReader
import com.google.zxing.NotFoundException
import com.google.zxing.PlanarYUVLuminanceSource
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
        // val path = call.argument<String>("path")!!
        val format = call.argument<Int>("format")!!
        val height = call.argument<Int>("height")!!
        val width = call.argument<Int>("width")!!
        val bytes = call.argument<ByteArray>("bytes")!!
        val rotation = call.argument<Int>("rotation")!!
        var source = PlanarYUVLuminanceSource(bytes, width, height, 0, 0, width, height, false)
        if (source!!.isRotateSupported()) {
          when(rotation) {
            1: -> {
              source = source!!.rotateCounterClockwise()
            }
            2: -> {
              source = source!!.rotateCounterClockwise()
                .rotateCounterClockwise()
            }
            3: -> {
              source = source!!.rotateCounterClockwise()
              !!.rotateCounterClockwise()
              !!.rotateCounterClockwise()
            }
          }
        }
        val bitmap = BinaryBitmap(HybridBinarizer(source!!))
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
