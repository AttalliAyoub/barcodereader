// import 'package:firebase_ml_vision/firebase_ml_vision.dart' show BarcodeFormat;
import 'package:google_ml_kit/google_ml_kit.dart'
    show BarcodeType, Barcode, BarcodeRawOnly;

String barcodeType2String(int type) {
  switch (type) {
    case BarcodeType.TYPE_UNKNOWN:
      return 'TYPE_UNKNOWN';
    case BarcodeType.TYPE_CONTACT_INFO:
      return 'TYPE_CONTACT_INFO';
    case BarcodeType.TYPE_EMAIL:
      return 'TYPE_EMAIL';
    case BarcodeType.TYPE_ISBN:
      return 'TYPE_ISBN';
    case BarcodeType.TYPE_PHONE:
      return 'TYPE_PHONE';
    case BarcodeType.TYPE_PRODUCT:
      return 'TYPE_PRODUCT';
    case BarcodeType.TYPE_SMS:
      return 'TYPE_SMS';
    case BarcodeType.TYPE_TEXT:
      return 'TYPE_TEXT';
    case BarcodeType.TYPE_URL:
      return 'TYPE_URL';
    case BarcodeType.TYPE_WIFI:
      return 'TYPE_WIFI';
    case BarcodeType.TYPE_GEO:
      return 'TYPE_GEO';
    case BarcodeType.TYPE_CALENDAR_EVENT:
      return 'TYPE_CALENDAR_EVENT';
    case BarcodeType.TYPE_DRIVER_LICENSE:
      return 'TYPE_DRIVER_LICENSE';
    default:
      return 'unknown';
  }
}

BarcodeRawOnly barcodeData(Barcode barcode) {
  switch (barcode.barcodeType) {
    case BarcodeType.TYPE_UNKNOWN:
    case BarcodeType.TYPE_ISBN:
    case BarcodeType.TYPE_TEXT:
    case BarcodeType.TYPE_PRODUCT:
    case BarcodeType.TYPE_CONTACT_INFO:
      return barcode.barcodeContactInfo;
    case BarcodeType.TYPE_EMAIL:
      return barcode.barcodeEmail;
    case BarcodeType.TYPE_PHONE:
      return barcode.barcodePhone;
    case BarcodeType.TYPE_SMS:
      return barcode.barcodeSMS;
    case BarcodeType.TYPE_URL:
      return barcode.barcodeUrl;
    case BarcodeType.TYPE_WIFI:
      return barcode.barcodeWifi;
    case BarcodeType.TYPE_GEO:
      return barcode.barcodeGeo;
    case BarcodeType.TYPE_CALENDAR_EVENT:
      return barcode.barcodeCalenderEvent;
    case BarcodeType.TYPE_DRIVER_LICENSE:
      return barcode.barcodeDriverLicense;
    default:
      return barcode.barcodeUnknown;
  }
}
