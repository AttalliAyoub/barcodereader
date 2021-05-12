import 'conver_format_ml.dart';

class Barcode {
  String text;
  List<Map<String, double>> resultPoints;
  String format;
  Map<String, dynamic> resultMetadata;
  DateTime timestamp;
  String barcodeType;

  @override
  String toString() => json.toString();

  Barcode({
    this.format,
    this.resultMetadata,
    this.text,
    this.resultPoints,
    this.timestamp,
    this.barcodeType,
  });

  factory Barcode.fromMap(dynamic data) {
    return Barcode(
      text: data['text'],
      resultPoints: data['resultPoints'] != null
          ? List.from(data['resultPoints'])
              .map((p) => Map<String, double>.from(p))
              .toList()
          : null,
      format: data['format'],
      resultMetadata: data['resultMetadata'] != null
          ? Map<String, dynamic>.from(data['resultMetadata'])
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      barcodeType: barcodeType2String(data['barcodeType'])
    );
  }

  Map<String, dynamic> get json => {
        if (text != null) 'text': text,
        if (resultPoints != null) 'resultPoints': resultPoints,
        if (format != null) 'format': format,
        if (resultMetadata != null) 'resultMetadata': resultMetadata,
        if (timestamp != null) 'timestamp': timestamp,
        if (barcodeType != null) 'barcodeType': barcodeType,
      };
}
