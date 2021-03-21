import 'package:firebase_ml_vision/firebase_ml_vision.dart' show BarcodeFormat;

barcodeFormatToString(BarcodeFormat format) {
  switch (format) {
    case BarcodeFormat.all:
      return 'all';
    case BarcodeFormat.unknown:
      return 'unknown';
    case BarcodeFormat.code128:
      return 'code128';
    case BarcodeFormat.code39:
      return 'code39';
    case BarcodeFormat.code93:
      return 'code93';
    case BarcodeFormat.codabar:
      return 'codabar';
    case BarcodeFormat.dataMatrix:
      return 'dataMatrix';
    case BarcodeFormat.ean13:
      return 'ean13';
    case BarcodeFormat.ean8:
      return 'ean8';
    case BarcodeFormat.itf:
      return 'itf';
    case BarcodeFormat.qrCode:
      return 'qrCode';
    case BarcodeFormat.upca:
      return 'upca';
    case BarcodeFormat.upce:
      return 'upce';
    case BarcodeFormat.pdf417:
      return 'pdf417';
    case BarcodeFormat.aztec:
      return 'aztec';
    default:
      return 'unknown';
  }
}
