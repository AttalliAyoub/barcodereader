package com.ayoub.barcodereader

import android.graphics.*
import android.util.Log
import androidx.annotation.NonNull
import com.yanzhenjie.zbar.Image
import com.yanzhenjie.zbar.ImageScanner
import com.google.zxing.MultiFormatReader
import com.yanzhenjie.zbar.BuildConfig
import com.yanzhenjie.zbar.Config
import com.yanzhenjie.zbar.Modifier
import com.yanzhenjie.zbar.Symbol
import com.yanzhenjie.zbar.SymbolIterator
import com.yanzhenjie.zbar.SymbolSet
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer
import kotlin.math.absoluteValue


/** BarcodereaderPlugin */
class BarcodereaderPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private val imageScanner = ImageScanner()


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.ayoub.barcodereader")
        channel.setMethodCallHandler(this)
        imageScanner.enableCache(false)
    }

    private fun qsdlkmfj() {
        val reader = MultiFormatReader()
        // reader.
    }


    private fun encodeYUV420SP(yuv420sp: ByteArray, argb: IntArray, width: Int, height: Int) {
        val frameSize = width * height
        var yIndex = 0
        var uvIndex = frameSize
        var a: Int
        var R: Int
        var G: Int
        var B: Int
        var Y: Int
        var U: Int
        var V: Int
        var index = 0
        for (j in 0 until height) {
            for (i in 0 until width) {
                a = argb[index] and -0x1000000 shr 24 // a is not used obviously
                R = argb[index] and 0xff0000 shr 16
                G = argb[index] and 0xff00 shr 8
                B = argb[index] and 0xff shr 0

                // well known RGB to YUV algorithm
                Y = (66 * R + 129 * G + 25 * B + 128 shr 8) + 16
                U = (-38 * R - 74 * G + 112 * B + 128 shr 8) + 128
                V = (112 * R - 94 * G - 18 * B + 128 shr 8) + 128

                // NV21 has a plane of Y and interleaved planes of VU each sampled by a factor of 2
                //    meaning for every 4 Y pixels there are 1 V and 1 U.  Note the sampling is every other
                //    pixel AND every other scanline.
                yuv420sp[yIndex++] = (if (Y < 0) 0 else if (Y > 255) 255 else Y).toByte()
                if (j % 2 == 0 && index % 2 == 0) {
                    yuv420sp[uvIndex++] = (if (V < 0) 0 else if (V > 255) 255 else V).toByte()
                    yuv420sp[uvIndex++] = (if (U < 0) 0 else if (U > 255) 255 else U).toByte()
                }
                index++
            }
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "barcode" -> {
                val height = call.argument<Int>("height")!!
                val width = call.argument<Int>("width")!!
                val bytes = call.argument<ByteArray>("bytes")!!
                var image: Image = Image(width, height, "Y800").also { i -> i.data = bytes }
                if (width > height) {
                    val out = ByteArrayOutputStream()
                    YuvImage(bytes, ImageFormat.NV21, width, height, null)
                        .also { i -> i.compressToJpeg(Rect(0, 0, width, height), 100, out) }
                    val rotatedImage = out.toByteArray().let { jpgBytes ->
                        val matrix = Matrix().also { m -> m.postRotate(90f) }
                        val jpegImage = BitmapFactory.decodeByteArray(jpgBytes, 0, jpgBytes.size)
                        Bitmap.createBitmap(
                            jpegImage, 0, 0,
                            jpegImage.width, jpegImage.height, matrix, true
                        )
                    }
                    image = Image(rotatedImage.width, rotatedImage.height, "Y800").also { i ->
                        val argb = IntArray(rotatedImage.width * rotatedImage.height)
                        rotatedImage.getPixels(argb, 0, rotatedImage.width, 0, 0, rotatedImage.width, rotatedImage.height)
                        val yuv = ByteArray(rotatedImage.width * rotatedImage.height * 3 / 2)
                        encodeYUV420SP(yuv, argb, rotatedImage.width, rotatedImage.height)
                        rotatedImage.recycle()
                        i.data = yuv
                        /*
                        val buffer = ByteBuffer.allocate(rotatedImage.byteCount)
                        rotatedImage.copyPixelsToBuffer(buffer)
                        i.data = buffer.array()
                        */
                    }
                }
                try {
                    val r = imageScanner.scanImage(image)
                    if (r != 0) {
                        val results = imageScanner.results.map { scanResult ->
                            mapOf<String, Any>(
                                "text" to scanResult.data,
                                "format" to scanResult.type.absoluteValue,
                                "bounds" to scanResult.bounds.asList(),
                                "count" to scanResult.count.absoluteValue,
                                "dataBytes" to scanResult.dataBytes.asList(),
                                "orientation" to scanResult.orientation.absoluteValue,
                                "quality" to scanResult.quality.absoluteValue
                            )
                        }
                        result.success(results)
                    } else result.success(null)
                } catch (e: Exception) {
                    result.error(e.cause.toString(), e.message, e)
                } finally {
                    image.destroy()
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        imageScanner.destroy()
    }
}
