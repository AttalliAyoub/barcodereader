import 'dart:typed_data';
import 'formats.dart';

class Barcode {
  final String text;
  final Format format;
  final Bounds bounds;
  final int count;
  final Uint8List dataBytes;
  final int orientation;
  final int quality;

  Barcode({
    this.text,
    this.format,
    this.bounds,
    this.count,
    this.dataBytes,
    this.orientation,
    this.quality,
  });

  factory Barcode.fromMap(Map data) {
    return Barcode(
      text: data['text'],
      format: int2format(data['format']),
      bounds: Bounds.fromList(List<int>.from(data['bounds'])),
      count: data['count'],
      dataBytes: Uint8List.fromList(List<int>.from(data['dataBytes'])),
      orientation: data['orientation'],
      quality: data['quality'],
    );
  }

  Map<String, dynamic> get map => {
        'text': text,
        'format': format,
        'bounds': bounds.map,
        'count': count,
        'dataBytes': dataBytes,
        'orientation': orientation,
        'quality': quality,
      };
}

class Bounds {
  final int xmin;
  final int xmax;
  final int ymin;
  final int ymax;
  Bounds({
    this.xmin,
    this.xmax,
    this.ymin,
    this.ymax,
  });

  factory Bounds.fromList(List<int> data) {
    return Bounds(xmin: data[0], xmax: data[2], ymin: data[1], ymax: data[3]);
  }

  Map<String, dynamic> get map => {
        'xmin': xmin,
        'xmax': xmax,
        'ymin': ymin,
        'ymax': ymax,
      };
}
