import 'dart:typed_data';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart'
    show
        InputImageData,
        InputImagePlaneMetadata,
        InputImageRotation,
        InputImageFormat;

Uint8List concatenatePlanes(List<Plane> planes) {
  final allBytes = WriteBuffer();
  planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
  return allBytes.done().buffer.asUint8List();
}

InputImageData buildMetaData(
  CameraImage image,
  InputImageRotation rotation,
) {
  return InputImageData(
    inputImageFormat: (() {
      if (image.format.group == ImageFormatGroup.yuv420)
        return InputImageFormat.YUV_420_888;
      return InputImageFormat.NV21;
    })(),
    size: Size(image.width.toDouble(), image.height.toDouble()),
    imageRotation: rotation,
    planeData: image.planes
        .map((plane) => InputImagePlaneMetadata(
              bytesPerRow: plane.bytesPerRow,
              height: plane.height,
              width: plane.width,
            ))
        .toList(),
  );
}
